locals {
  profiles = flatten([
    for namespace, service_accounts in var.workload_identity_profiles :
    [for config in service_accounts : {
      name : element(split("@", config.email), 0)
      email : config.email,
      automount_service_account_token : config.automount_service_account_token,
      create_service_account_token : config.create_service_account_token,
      namespace : namespace,
      project_id : element(split(".", element(split("@", config.email), 1)), 0)
    }]
  ])
  workload_identity_profiles = { for profile in local.profiles : "${profile.namespace}/${profile.email}" => profile }
}

# Service account tokens
resource "kubernetes_secret_v1" "tokens" {
  depends_on = [
    kubernetes_service_account.service_accounts
  ]
  for_each = { for k, v in local.workload_identity_profiles : k => v if v.automount_service_account_token && v.create_service_account_token }

  metadata {
    name = "${each.value.name}-service-account-token"
    annotations = {
      "kubernetes.io/service-account.name" = each.value.name
    }
    namespace = each.value.namespace
  }

  type = "kubernetes.io/service-account-token"
}

resource "kubernetes_service_account" "service_accounts" {
  depends_on = [
    kubernetes_namespace.namespaces,
  ]
  for_each = local.workload_identity_profiles

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = each.value.email
    }
  }

  automount_service_account_token = each.value.automount_service_account_token
}

# Allow the KSA to impersonate the GSA by creating IAM policy binding between them
resource "google_service_account_iam_member" "main" {
  # We dont want to create these IAM bindings for each region, only the original cluster in an environment
  for_each = var.secondary_region == true ? {} : local.workload_identity_profiles
  depends_on = [
    kubernetes_service_account.service_accounts
  ]
  # service account id references service account project
  service_account_id = "projects/${each.value.project_id}/serviceAccounts/${each.value.email}"
  role               = "roles/iam.workloadIdentityUser"
  # workload identity pool for GKE's GCP project
  member = "serviceAccount:${var.project_id}.svc.id.goog[${each.value.namespace}/${each.value.name}]"
}
