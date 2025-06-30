locals {
  cloudflare_account_id = "ea64206f699cea3433e5d8460ca5d791"
}

data "cloudflare_list" "bypass_list" {
  account_id = local.cloudflare_account_id
  name       = "dapperlabs_bypass_list"
}

# Adds the NAT ips of the GKE cluster to the global Cloudflare bypass list
# This enables traffic from these clusters to bypass WAF for our products
# Such as Dapper or Studio platform infra
resource "cloudflare_list_item" "bypass_list_additions" {
  for_each   = module.gke_vpc_nat_addresses.external_addresses
  account_id = local.cloudflare_account_id
  list_id    = data.cloudflare_list.bypass_list.id
  comment    = "${var.project_id} ${each.key}"
  ip         = each.value.address
}

