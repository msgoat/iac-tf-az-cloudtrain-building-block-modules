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

locals {
  module_common_tags = merge(var.common_tags, { TerraformBuildingBlockName = "stage/shared" })
}

module region {
  source = "../../../../iac-tf-az-cloudtrain-modules//modules/base/region"
  region_name = var.region_name
}

locals {
  resource_group_name = "rg-${module.region.region_info.region_code}-${var.solution_fqn}-${var.resource_group_name}"
}

resource "azurerm_resource_group" "owner" {
  name     = local.resource_group_name
  location = var.region_name
  tags     = var.common_tags
}

# -- We need to provide a DNS zone for all DNS records referring to workload on the cluster
module "public_dns" {
  source             = "../../../../iac-tf-az-cloudtrain-modules//modules/dns/public-dns-zone"
  region_name        = var.region_name
  solution_fqn       = var.solution_fqn
  solution_name      = var.solution_name
  solution_stage     = var.solution_stage
  common_tags        = var.common_tags
  resource_group_id  = azurerm_resource_group.owner.id
  dns_zone_name      = var.public_dns_zone_name
  parent_dns_zone_id = var.parent_dns_zone_id
}

# -- We need to provide a shared key vault which manages all secrets
module "key_vault" {
  source            = "../../../../iac-tf-az-cloudtrain-modules//modules/security/key-vault"
  region_name       = var.region_name
  solution_fqn      = var.solution_fqn
  solution_name     = var.solution_name
  solution_stage    = var.solution_stage
  common_tags       = var.common_tags
  resource_group_id = azurerm_resource_group.owner.id
  key_vault_name    = "shared"
  key_vault_admin_group_ids = var.admin_principal_ids
}

# -- We need to provide a shared log analytics workspace which manages all monitoring data
module "log_analytics_workspace" {
  source            = "../../../../iac-tf-az-cloudtrain-modules//modules/monitoring/log-analytics-workspace"
  region_name       = var.region_name
  solution_fqn      = var.solution_fqn
  solution_name     = var.solution_name
  solution_stage    = var.solution_stage
  common_tags       = var.common_tags
  resource_group_id = azurerm_resource_group.owner.id
  workspace_name    = "shared"
}
