locals {
  profiles = flatten([
    for namespace, service_accounts in var.workload_identity_profiles :
    [for config in service_accounts : {
      name : element(split("@", config.email), 0)
      email : config.email,
      automount_service_account_token : config.automount_service_account_token,
      namespace : namespace,
      project_id : element(split(".", element(split("@", config.email), 1)), 0)
    }]
  ])
  workload_identity_profiles = { for profile in local.profiles : "${profile.namespace}/${profile.email}" => profile }
}

# Service account tokens
resource "kubernetes_secret_v1" "tokens" {
  for_each = local.workload_identity_profiles

  metadata {
    name = "${each.value.name}-service-account-token"
    annotations = {
      "kubernetes.io/service-account.name" = each.value.name
    }
    namespace = each.value.namespace
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_manifest" "service_accounts" {
  depends_on = [
    kubernetes_namespace.namespaces,
    kubernetes_secret_v1.tokens,
  ]
  for_each = local.workload_identity_profiles

  manifest = {
    apiVersion                   = "v1"
    kind                         = "ServiceAccount"
    automountServiceAccountToken = each.value.automount_service_account_token
    secrets = [{
      name = "${each.value.name}-service-account-token"
    }]
    metadata = {
      name      = each.value.name
      namespace = each.value.namespace
      annotations = {
        "iam.gke.io/gcp-service-account" = each.value.email
      }
    }
  }
}

# Allow the KSA to impersonate the GSA by creating IAM policy binding between them
resource "google_service_account_iam_member" "main" {
  for_each = local.workload_identity_profiles
  depends_on = [
    kubernetes_manifest.service_accounts
  ]
  # service account id references service account project
  service_account_id = "projects/${each.value.project_id}/serviceAccounts/${each.value.email}"
  role               = "roles/iam.workloadIdentityUser"
  # workload identity pool for GKE's GCP project
  member = "serviceAccount:${var.project_id}.svc.id.goog[${each.value.namespace}/${each.value.name}]"
}
