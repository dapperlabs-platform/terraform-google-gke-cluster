locals {
  profiles = flatten([
    for namespace, service_accounts in var.workload_identity_profiles :
    [for gsa in service_accounts : { gsa : gsa, namespace : namespace }]
  ])
  workload_identity_profiles = { for profile in local.profiles : "${profile.namespace}/${profile.gsa}" => profile }
}

resource "kubernetes_service_account" "service_accounts" {
  depends_on = [
    kubernetes_namespace.namespaces
  ]
  for_each                        = local.workload_identity_profiles
  automount_service_account_token = true
  metadata {
    name      = element(split("@", each.value.gsa), 0)
    namespace = each.value.namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = each.value.gsa
    }
  }
}

# Allow the KSA to impersonate the GSA by creating IAM policy binding between them
resource "google_service_account_iam_member" "main" {
  for_each = local.workload_identity_profiles
  depends_on = [
    kubernetes_service_account.service_accounts
  ]
  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value.gsa}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${each.value.namespace}/${kubernetes_service_account.service_accounts[each.key].metadata[0].name}]"
}
