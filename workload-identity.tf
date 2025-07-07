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

# Allow the KSA to impersonate the GSA by creating IAM policy binding between them
resource "google_service_account_iam_member" "main" {
  # We dont want to create these IAM bindings for each region, only the original cluster in an environment
  for_each = var.secondary_region == true ? {} : local.workload_identity_profiles
  depends_on = [
    google_container_cluster.cluster,
  ]
  # service account id references service account project
  service_account_id = "projects/${each.value.project_id}/serviceAccounts/${each.value.email}"
  role               = "roles/iam.workloadIdentityUser"
  # workload identity pool for GKE's GCP project
  member = "serviceAccount:${var.project_id}.svc.id.goog[${each.value.namespace}/${each.value.name}]"
}
