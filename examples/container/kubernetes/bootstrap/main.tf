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

module k8s_bootstrap {
  source                = "../../../..//modules/container/kubernetes/bootstrap"
  region_name           = var.region_name
  region_code           = var.region_code
  solution_name         = var.solution_name
  solution_stage        = var.solution_stage
  solution_fqn          = var.solution_fqn
  common_tags           = var.common_tags
  resource_group_id     = var.resource_group_id
  k8s_cluster_id        = var.k8s_cluster_id
  key_vault_id          = var.key_vault_id
  dns_zone_id = var.dns_zone_id
  letsencrypt_account_name = var.letsencrypt_account_name
}
