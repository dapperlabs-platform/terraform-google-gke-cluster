# GKE cluster module

This module allows simplified creation and management of GKE clusters and should be used together with the GKE nodepool module, as the default nodepool is turned off here and cannot be re-enabled. Some sensible defaults are set initially, in order to allow less verbose usage for most use cases.

## Example

### GKE Cluster

```hcl
module "cluster-1" {
  source                    = "github.com/dapperlabs-platform/terraform-google-gke-cluster?ref=tag"
  project_id                = "myproject"
  name                      = "cluster-1"
  location                  = "europe-west1-b"
  network                   = var.vpc.self_link
  subnetwork                = var.subnet.self_link
  secondary_range_pods      = "pods"
  secondary_range_services  = "services"
  default_max_pods_per_node = 32
  master_authorized_ranges = {
    internal-vms = "10.0.0.0/8"
  }
  private_cluster_config = {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "192.168.0.0/28"
    master_global_access    = false
  }
  labels = {
    environment = "dev"
  }
}
# tftest:modules=1:resources=1
```

### GKE Cluster with Dataplane V2 enabled

```hcl
module "cluster-1" {
  source                    = "github.com/dapperlabs-platform/terraform-google-gke-cluster?ref=tag"
  project_id                = "myproject"
  name                      = "cluster-1"
  location                  = "europe-west1-b"
  network                   = var.vpc.self_link
  subnetwork                = var.subnet.self_link
  secondary_range_pods      = "pods"
  secondary_range_services  = "services"
  default_max_pods_per_node = 32
  enable_dataplane_v2       = true
  master_authorized_ranges = {
    internal-vms = "10.0.0.0/8"
  }
  private_cluster_config = {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "192.168.0.0/28"
    master_global_access    = false
  }
  labels = {
    environment = "dev"
  }
}
# tftest:modules=1:resources=1
```

<!-- BEGIN TFDOC -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.6 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.0.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.30.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | 4.30.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.12.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_container_cluster.cluster](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_container_cluster) | resource |
| [google_compute_network_peering_routes_config.gke_master](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering_routes_config) | resource |
| [google_service_account_iam_member.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [kubernetes_namespace.namespaces](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service_account.service_accounts](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addons"></a> [addons](#input\_addons) | Addons enabled in the cluster (true means enabled). | <pre>object({<br>    cloudrun_config            = bool<br>    dns_cache_config           = bool<br>    horizontal_pod_autoscaling = bool<br>    http_load_balancing        = bool<br>    istio_config = object({<br>      enabled = bool<br>      tls     = bool<br>    })<br>    network_policy_config                 = bool<br>    gce_persistent_disk_csi_driver_config = bool<br>  })</pre> | <pre>{<br>  "cloudrun_config": false,<br>  "dns_cache_config": false,<br>  "gce_persistent_disk_csi_driver_config": false,<br>  "horizontal_pod_autoscaling": true,<br>  "http_load_balancing": true,<br>  "istio_config": {<br>    "enabled": false,<br>    "tls": false<br>  },<br>  "network_policy_config": true<br>}</pre> | no |
| <a name="input_authenticator_security_group"></a> [authenticator\_security\_group](#input\_authenticator\_security\_group) | RBAC security group for Google Groups for GKE, format is gke-security-groups@yourdomain.com. | `string` | `null` | no |
| <a name="input_cluster_autoscaling"></a> [cluster\_autoscaling](#input\_cluster\_autoscaling) | Enable and configure limits for Node Auto-Provisioning with Cluster Autoscaler. | <pre>object({<br>    enabled    = bool<br>    cpu_min    = number<br>    cpu_max    = number<br>    memory_min = number<br>    memory_max = number<br>  })</pre> | <pre>{<br>  "cpu_max": 0,<br>  "cpu_min": 0,<br>  "enabled": false,<br>  "memory_max": 0,<br>  "memory_min": 0<br>}</pre> | no |
| <a name="input_database_encryption"></a> [database\_encryption](#input\_database\_encryption) | Enable and configure GKE application-layer secrets encryption. | <pre>object({<br>    enabled  = bool<br>    state    = string<br>    key_name = string<br>  })</pre> | <pre>{<br>  "enabled": false,<br>  "key_name": null,<br>  "state": "DECRYPTED"<br>}</pre> | no |
| <a name="input_default_max_pods_per_node"></a> [default\_max\_pods\_per\_node](#input\_default\_max\_pods\_per\_node) | Maximum number of pods per node in this cluster. | `number` | `110` | no |
| <a name="input_description"></a> [description](#input\_description) | Cluster description. | `string` | `null` | no |
| <a name="input_enable_autopilot"></a> [enable\_autopilot](#input\_enable\_autopilot) | Create cluster in autopilot mode. With autopilot there's no need to create node-pools and some features are not supported (e.g. setting default\_max\_pods\_per\_node) | `bool` | `false` | no |
| <a name="input_enable_dataplane_v2"></a> [enable\_dataplane\_v2](#input\_enable\_dataplane\_v2) | Enable Dataplane V2 on the cluster, will disable network\_policy addons config | `bool` | `false` | no |
| <a name="input_enable_intranode_visibility"></a> [enable\_intranode\_visibility](#input\_enable\_intranode\_visibility) | Enable intra-node visibility to make same node pod to pod traffic visible. | `bool` | `null` | no |
| <a name="input_enable_shielded_nodes"></a> [enable\_shielded\_nodes](#input\_enable\_shielded\_nodes) | Enable Shielded Nodes features on all nodes in this cluster. | `bool` | `null` | no |
| <a name="input_enable_tpu"></a> [enable\_tpu](#input\_enable\_tpu) | Enable Cloud TPU resources in this cluster. | `bool` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Cluster resource labels. | `map(string)` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Cluster zone or region. | `string` | n/a | yes |
| <a name="input_logging_service"></a> [logging\_service](#input\_logging\_service) | Logging service (disable with an empty string). | `string` | `"none"` | no |
| <a name="input_maintenance_start_time"></a> [maintenance\_start\_time](#input\_maintenance\_start\_time) | Maintenance start time in RFC3339 format 'HH:MM', where HH is [00-23] and MM is [00-59] GMT. | `string` | `"03:00"` | no |
| <a name="input_master_authorized_ranges"></a> [master\_authorized\_ranges](#input\_master\_authorized\_ranges) | External Ip address ranges that can access the Kubernetes cluster master through HTTPS. | `map(string)` | `{}` | no |
| <a name="input_min_master_version"></a> [min\_master\_version](#input\_min\_master\_version) | Minimum version of the master, defaults to the version of the most recent official release. | `string` | `null` | no |
| <a name="input_monitoring_service"></a> [monitoring\_service](#input\_monitoring\_service) | Monitoring service | `string` | `"none"` | no |
| <a name="input_name"></a> [name](#input\_name) | Cluster name. | `string` | n/a | yes |
| <a name="input_namespace_protection"></a> [namespace\_protection](#input\_namespace\_protection) | If true - mark namespace with annotation so it can't be deleted see: https://github.com/dapperlabs/kyverno-policies/tree/main/policies/deny-protected-deletes | `bool` | `true` | no |
| <a name="input_namespaces"></a> [namespaces](#input\_namespaces) | Namespaces to add to the cluster | `list(string)` | `[]` | no |
| <a name="input_network"></a> [network](#input\_network) | Name or self link of the VPC used for the cluster. Use the self link for Shared VPC. | `string` | n/a | yes |
| <a name="input_node_locations"></a> [node\_locations](#input\_node\_locations) | Zones in which the cluster's nodes are located. | `list(string)` | `[]` | no |
| <a name="input_peering_config"></a> [peering\_config](#input\_peering\_config) | Configure peering with the master VPC for private clusters. | <pre>object({<br>    export_routes = bool<br>    import_routes = bool<br>    project_id    = string<br>  })</pre> | `null` | no |
| <a name="input_pod_security_policy"></a> [pod\_security\_policy](#input\_pod\_security\_policy) | Enable the PodSecurityPolicy feature. | `bool` | `null` | no |
| <a name="input_private_cluster_config"></a> [private\_cluster\_config](#input\_private\_cluster\_config) | Enable and configure private cluster, private nodes must be true if used. | <pre>object({<br>    enable_private_nodes    = bool<br>    enable_private_endpoint = bool<br>    master_ipv4_cidr_block  = string<br>    master_global_access    = bool<br>  })</pre> | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Cluster project id. | `string` | n/a | yes |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel) | Release channel for GKE upgrades. | `string` | `null` | no |
| <a name="input_resource_usage_export_config"></a> [resource\_usage\_export\_config](#input\_resource\_usage\_export\_config) | Configure the ResourceUsageExportConfig feature. | <pre>object({<br>    enabled = bool<br>    dataset = string<br>  })</pre> | <pre>{<br>  "dataset": null,<br>  "enabled": null<br>}</pre> | no |
| <a name="input_secondary_range_pods"></a> [secondary\_range\_pods](#input\_secondary\_range\_pods) | Subnet secondary range name used for pods. | `string` | n/a | yes |
| <a name="input_secondary_range_services"></a> [secondary\_range\_services](#input\_secondary\_range\_services) | Subnet secondary range name used for services. | `string` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | VPC subnetwork name or self link. | `string` | n/a | yes |
| <a name="input_vertical_pod_autoscaling"></a> [vertical\_pod\_autoscaling](#input\_vertical\_pod\_autoscaling) | Enable the Vertical Pod Autoscaling feature. | `bool` | `null` | no |
| <a name="input_workload_identity"></a> [workload\_identity](#input\_workload\_identity) | Enable the Workload Identity feature. | `bool` | `true` | no |
| <a name="input_workload_identity_profiles"></a> [workload\_identity\_profiles](#input\_workload\_identity\_profiles) | Namespace-keyed map of GCP Service Account emails to create K8S Service Accounts for. | `map(list(string))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_certificate"></a> [ca\_certificate](#output\_ca\_certificate) | Public certificate of the cluster (base64-encoded). |
| <a name="output_cluster"></a> [cluster](#output\_cluster) | Cluster resource. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Cluster endpoint. |
| <a name="output_location"></a> [location](#output\_location) | Cluster location. |
| <a name="output_master_version"></a> [master\_version](#output\_master\_version) | Master version. |
| <a name="output_name"></a> [name](#output\_name) | Cluster name. |
<!-- END TFDOC -->
