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
  module_common_tags = merge(var.common_tags, { TerraformBuildingBlockName = "container/kubernetes/foundation" })
}

module network {
  source                = "../../../../../iac-tf-az-cloudtrain-modules//modules/network/vnet"
  region_name = var.region_name
  region_code = var.region_code
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
  resource_group_id = var.resource_group_id
  network_name = var.kubernetes_cluster_name
  network_cidr = var.network_cidr
  subnet_templates = [
    {
      name = "systempool"
      accessibility = "private"
      role = "SystemPoolContainer"
      newbits = 4
    },
    {
      name = "userpool"
      accessibility = "private"
      role = "UserPoolContainer"
      newbits = 4
    },
    {
      name = "endpoints"
      accessibility = "private"
      role = "PrivateEndpointContainer"
      newbits = 4
    },
    {
      name = "resources"
      accessibility = "private"
      role = "ResourceContainer"
      newbits = 4
    },
    {
      name = "web"
      accessibility = "public"
      role = "InternetFacingContainer"
      newbits = 8
    },
    {
      name = "loadbalancer"
      accessibility = "private"
      role = "InternalLoadBalancerContainer"
      newbits = 8
    }
  ]
}

locals {
  system_pool_subnet_id = [ for sn in module.network.subnets : sn.subnet_id if sn.role == "SystemPoolContainer" ][0]
  user_pool_subnet_id = [ for sn in module.network.subnets : sn.subnet_id if sn.role == "UserPoolContainer" ][0]
  loadbalancer_subnet_id = [ for sn in module.network.subnets : sn.subnet_id if sn.role == "InternalLoadBalancerContainer" ][0]
}

module "cluster" {
  source                = "../../../../../iac-tf-az-cloudtrain-modules//modules/container/aks/cluster"
  region_name           = var.region_name
  region_code = var.region_code
  solution_name         = var.solution_name
  solution_stage        = var.solution_stage
  solution_fqn          = var.solution_fqn
  common_tags           = local.module_common_tags
  resource_group_id = var.resource_group_id
  kubernetes_api_access_cidrs = var.kubernetes_api_access_cidrs
  kubernetes_cluster_name = var.kubernetes_cluster_name
  kubernetes_version = var.kubernetes_version
  vnet_id = module.network.vnet_id
  system_pool_subnet_id = local.system_pool_subnet_id
  user_pool_subnet_id = local.user_pool_subnet_id
  loadbalancer_subnet_id = local.loadbalancer_subnet_id
  node_pool_templates = var.node_group_templates
  zones_to_span = var.zones_to_span
  key_vault_id = var.key_vault_id
  aks_disk_encryption_enabled = true
  log_analytics_workspace_id = var.log_analytics_workspace_id
  aks_addon_aad_rbac_enabled = true
  aks_addon_aad_rbac_admin_group_ids = var.kubernetes_admin_group_ids
}
