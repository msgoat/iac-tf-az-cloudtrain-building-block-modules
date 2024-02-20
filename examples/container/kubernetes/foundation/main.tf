# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  resource_group_name = "rg-${var.region_code}-${var.solution_fqn}-${var.kubernetes_cluster_name}"
}

resource "azurerm_resource_group" "owner" {
  name     = local.resource_group_name
  location = var.region_name
  tags     = var.common_tags
}

# -- We need to provide a DNS zone for all DNS records referring to workload on the cluster
module "public_dns" {
  source             = "../../../../../iac-tf-az-cloudtrain-modules//modules/dns/public-dns-zone"
  region_name        = var.region_name
  region_code        = var.region_code
  solution_fqn       = var.solution_fqn
  solution_name      = var.solution_name
  solution_stage     = var.solution_stage
  common_tags        = var.common_tags
  resource_group_id  = azurerm_resource_group.owner.id
  dns_zone_name      = "${var.solution_fqn}.k8s.azure.msgoat.eu"
  parent_dns_zone_id = var.parent_dns_zone_id
}

# -- We need to provide a shared key vault which manages all secrets
module "key_vault" {
  source            = "../../../../../iac-tf-az-cloudtrain-modules//modules/security/key-vault"
  region_name       = var.region_name
  region_code       = var.region_code
  solution_fqn      = var.solution_fqn
  solution_name     = var.solution_name
  solution_stage    = var.solution_stage
  common_tags       = var.common_tags
  resource_group_id = azurerm_resource_group.owner.id
  key_vault_name    = "shared"
}

# -- We need to provide a shared log analytics workspace which manages all monitoring data
module "log_analytics_workspace" {
  source            = "../../../../../iac-tf-az-cloudtrain-modules//modules/monitoring/log-analytics-workspace"
  region_name       = var.region_name
  region_code       = var.region_code
  solution_fqn      = var.solution_fqn
  solution_name     = var.solution_name
  solution_stage    = var.solution_stage
  common_tags       = var.common_tags
  resource_group_id = azurerm_resource_group.owner.id
  workspace_name    = "shared"
}

module "k8s_foundation" {
  source                           = "../../../..//modules/container/kubernetes/foundation"
  region_name                      = var.region_name
  region_code                      = var.region_code
  solution_name                    = var.solution_name
  solution_stage                   = var.solution_stage
  solution_fqn                     = var.solution_fqn
  resource_group_id                = azurerm_resource_group.owner.id
  key_vault_id                     = module.key_vault.key_vault_id
  log_analytics_workspace_id       = module.log_analytics_workspace.log_analytics_workspace_id
  common_tags                      = var.common_tags
  network_cidr                     = var.network_cidr
  names_of_zones_to_span           = var.names_of_zones_to_span
  kubernetes_api_access_cidrs      = var.kubernetes_api_access_cidrs
  kubernetes_workload_access_cidrs = var.kubernetes_workload_access_cidrs
  kubernetes_cluster_name          = var.kubernetes_cluster_name
  kubernetes_version               = var.kubernetes_version
  node_group_templates             = var.node_group_templates
  kubernetes_admin_group_ids       = var.kubernetes_admin_group_ids
  encryption_at_host_enabled       = var.encryption_at_host_enabled
  public_dns_zone_id               = module.public_dns.dns_zone_id
}
