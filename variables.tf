/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "addons" {
  description = "Addons enabled in the cluster (true means enabled)."
  type = object({
    cloudrun_config            = optional(bool, false)
    dns_cache_config           = optional(bool, false)
    horizontal_pod_autoscaling = optional(bool, true)
    http_load_balancing        = optional(bool, true)
    istio_config = optional(object({
      enabled = optional(bool, false)
      tls     = optional(bool, false)
    }), {})
    network_policy_config                 = optional(bool, true)
    gce_persistent_disk_csi_driver_config = optional(bool, true)
    gcp_filestore_csi_driver_config = optional(object({
      enabled = optional(bool, false)
      tier    = optional(string, "standard")
    }), {})
  })
  default = {}
}

variable "enable_dataplane_v2" {
  description = "Enable Dataplane V2 on the cluster, will disable network_policy addons config"
  type        = bool
  default     = false
}

variable "authenticator_security_group" {
  description = "RBAC security group for Google Groups for GKE, format is gke-security-groups@yourdomain.com."
  type        = string
  default     = null
}

variable "cluster_autoscaling" {
  description = "Enable and configure limits for Node Auto-Provisioning with Cluster Autoscaler."
  type = object({
    enabled    = bool
    cpu_min    = number
    cpu_max    = number
    memory_min = number
    memory_max = number
  })
  default = {
    enabled    = false
    cpu_min    = 0
    cpu_max    = 0
    memory_min = 0
    memory_max = 0
  }
}

variable "database_encryption" {
  description = "Enable and configure GKE application-layer secrets encryption."
  type = object({
    enabled  = bool
    state    = string
    key_name = string
  })
  default = {
    enabled  = false
    state    = "DECRYPTED"
    key_name = null
  }
}

variable "default_max_pods_per_node" {
  description = "Maximum number of pods per node in this cluster."
  type        = number
  default     = 110
}

variable "description" {
  description = "Cluster description."
  type        = string
  default     = null
}

variable "enable_intranode_visibility" {
  description = "Enable intra-node visibility to make same node pod to pod traffic visible."
  type        = bool
  default     = null
}

variable "enable_shielded_nodes" {
  description = "Enable Shielded Nodes features on all nodes in this cluster."
  type        = bool
  default     = null
}

variable "enable_tpu" {
  description = "Enable Cloud TPU resources in this cluster."
  type        = bool
  default     = null
}

variable "labels" {
  description = "Cluster resource labels."
  type        = map(string)
  default     = null
}

variable "location" {
  description = "Cluster zone or region."
  type        = string
}

variable "logging_service" {
  description = "Logging service (disable with an empty string)."
  type        = string
  default     = "none"
}

variable "maintenance_start_time" {
  description = "Maintenance start time in RFC3339 format 'HH:MM', where HH is [00-23] and MM is [00-59] GMT."
  type        = string
  default     = "03:00"
}

variable "master_authorized_ranges" {
  description = "External Ip address ranges that can access the Kubernetes cluster master through HTTPS."
  type        = map(string)
  default     = {}
}

variable "min_master_version" {
  description = "Minimum version of the master, defaults to the version of the most recent official release."
  type        = string
  default     = null
}

variable "monitoring_service" {
  description = "Monitoring service"
  type        = string
  default     = "none"
}

variable "name" {
  description = "Cluster name."
  type        = string
}

variable "network" {
  description = "Name or self link of the VPC used for the cluster. Use the self link for Shared VPC."
  type        = string
}

variable "node_locations" {
  description = "Zones in which the cluster's nodes are located."
  type        = list(string)
  default     = []
}

variable "peering_config" {
  description = "Configure peering with the master VPC for private clusters."
  type = object({
    export_routes = bool
    import_routes = bool
    project_id    = string
  })
  default = null
}

variable "pod_security_policy" {
  description = "Enable the PodSecurityPolicy feature."
  type        = bool
  default     = null
}

variable "private_cluster_config" {
  description = "Enable and configure private cluster, private nodes must be true if used."
  type = object({
    enable_private_nodes    = bool
    enable_private_endpoint = bool
    master_ipv4_cidr_block  = string
    master_global_access    = bool
  })
  default = null
}

variable "project_id" {
  description = "Cluster project id."
  type        = string
}

variable "release_channel" {
  description = "Release channel for GKE upgrades."
  type        = string
  default     = null
}

variable "resource_usage_export_config" {
  description = "Configure the ResourceUsageExportConfig feature."
  type = object({
    enabled = bool
    dataset = string
  })
  default = {
    enabled = null
    dataset = null
  }
}

variable "secondary_range_pods" {
  description = "Subnet secondary range name used for pods."
  type        = string
}

variable "secondary_range_services" {
  description = "Subnet secondary range name used for services."
  type        = string
}

variable "subnetwork" {
  description = "VPC subnetwork name or self link."
  type        = string
}

variable "vertical_pod_autoscaling" {
  description = "Enable the Vertical Pod Autoscaling feature."
  type        = bool
  default     = null
}

variable "workload_identity" {
  description = "Enable the Workload Identity feature."
  type        = bool
  default     = true
}

variable "enable_autopilot" {
  description = "Create cluster in autopilot mode. With autopilot there's no need to create node-pools and some features are not supported (e.g. setting default_max_pods_per_node)"
  type        = bool
  default     = false
}

variable "workload_identity_profiles" {
  description = <<EOF
  Namespace-keyed map of GCP Service Account to create K8S Service Accounts for.
  EOF
  type = map(
    list(
      object(
        {
          email                           = string
          create_service_account_token    = optional(bool, false)
          automount_service_account_token = optional(bool, false)
        }
      )
    )
  )
  default = {}
}

variable "namespaces" {
  description = "Namespaces to add to the cluster"
  type        = list(string)
  default     = []
}

variable "namespace_protection" {
  description = "If true - mark namespace with annotation so it can't be deleted see: https://github.com/dapperlabs/kyverno-policies/tree/main/policies/deny-protected-deletes"
  type        = bool
  default     = true
}

variable "enable_asm" {
  description = "Determines if Anthos Service Mesh should be enabled"
  type        = bool
  default     = false
}

variable "create_cpr" {
  description = "Determines if the control plane revision should be installed"
  type        = bool
  default     = false
}

variable "backup_configs" {
  description = "Configuration for Backup for GKE."
  type = object({
    enable_backup_agent = optional(bool, false)
    backup_plans = optional(map(object({
      region                            = string
      applications                      = optional(map(list(string)))
      encryption_key                    = optional(string)
      include_secrets                   = optional(bool, true)
      include_volume_data               = optional(bool, true)
      labels                            = optional(map(string))
      namespaces                        = optional(list(string))
      schedule                          = optional(string)
      retention_policy_days             = optional(number)
      retention_policy_lock             = optional(bool, false)
      retention_policy_delete_lock_days = optional(number)
    })), {})
  })
  default  = {}
  nullable = false
}

variable "monitoring_components" {
  description = "List of monitoring components to enable. Supported values include: SYSTEM_COMPONENTS, APISERVER, SCHEDULER, CONTROLLER_MANAGER, STORAGE, HPA, POD, DAEMONSET, DEPLOYMENT, STATEFULSET"
  type        = list(string)
  default     = null
}

variable "secondary_region" {
  type        = bool
  description = "Set to true if this is used for a non-default region deployment. This is needed to we don't recreate the workloadIdentityUser IAM binding each time we create a new region."
  default     = false
}
