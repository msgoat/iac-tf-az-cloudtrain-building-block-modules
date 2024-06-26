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

module "region" {
  source      = "../../../../../iac-tf-az-cloudtrain-modules//modules/base/region"
  region_name = var.region_name
}

# Network --------------------------------------------------------------------

module "network" {
  source            = "../../../../../iac-tf-az-cloudtrain-modules//modules/network/vnet"
  region_name       = var.region_name
  region_code       = module.region.region_info.region_code
  solution_fqn      = var.solution_fqn
  solution_name     = var.solution_name
  solution_stage    = var.solution_stage
  common_tags       = local.module_common_tags
  resource_group_id = var.resource_group_id
  network_name      = var.kubernetes_cluster_name
  network_cidr      = var.network_cidr
  subnet_templates = [
    {
      name          = "systempool"
      accessibility = "private"
      role          = "SystemPoolContainer"
      newbits       = 4
    },
    {
      name          = "userpool"
      accessibility = "private"
      role          = "UserPoolContainer"
      newbits       = 4
    },
    {
      name          = "endpoints"
      accessibility = "private"
      role          = "PrivateEndpointContainer"
      newbits       = 4
    },
    {
      name          = "resources"
      accessibility = "private"
      role          = "ResourceContainer"
      newbits       = 4
    },
    {
      name          = "web"
      accessibility = "public"
      role          = "InternetFacingContainer"
      newbits       = 8
    },
    {
      name          = "loadbalancer"
      accessibility = "private"
      role          = "InternalLoadBalancerContainer"
      newbits       = 8
    }
  ]
}

locals {
  system_pool_subnet_id         = [for sn in module.network.subnets : sn.subnet_id if sn.role == "SystemPoolContainer"][0]
  user_pool_subnet_id           = [for sn in module.network.subnets : sn.subnet_id if sn.role == "UserPoolContainer"][0]
  loadbalancer_subnet_id        = [for sn in module.network.subnets : sn.subnet_id if sn.role == "InternalLoadBalancerContainer"][0]
  application_gateway_subnet_id = [for sn in module.network.subnets : sn.subnet_id if sn.role == "InternetFacingContainer"][0]
}

# TLS certificate for load balancer ------------------------------------------

# @TODO

# Load balancer --------------------------------------------------------------

module "loadbalancer" {
  source                     = "../../../../../iac-tf-az-cloudtrain-modules//modules/network/application-gateway-agic"
  region_name                = var.region_name
  region_code                = module.region.region_info.region_code
  solution_name              = var.solution_name
  solution_stage             = var.solution_stage
  solution_fqn               = var.solution_fqn
  common_tags                = local.module_common_tags
  resource_group_id          = var.resource_group_id
  application_gateway_name   = var.kubernetes_cluster_name
  subnet_id                  = local.application_gateway_subnet_id
  public_dns_zone_id         = var.public_dns_zone_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  names_of_zones_to_span     = var.zones_to_span
  host_names                 = var.host_names
}

# Kubernetes cluster ---------------------------------------------------------

locals {
  node_group_subnet_ids = [for sn in module.network.subnets : sn.subnet_id if sn.role == "NodeGroupContainer"]
  az_image_types = {
    "X86_64" = "BOTTLEROCKET_x86_64"
    "ARM_64" = "BOTTLEROCKET_ARM_64"
  }
  az_node_group_role = {
    "MASTER" = "system"
    "WORKER" = "user"
  }

  az_node_group_templates = [for ngt in var.node_group_templates : {
    enabled            = ngt.enabled
    name               = ngt.name
    role               = local.az_node_group_role[ngt.role]
    kubernetes_version = ngt.kubernetes_version
    min_size           = ngt.min_size
    max_size           = ngt.max_size
    desired_size       = ngt.desired_size
    disk_size          = ngt.disk_size
    instance_type      = ngt.instance_types[0]
    labels             = ngt.labels
    taints             = ngt.taints
  }]
}

module "cluster" {
  source                                = "../../../../../iac-tf-az-cloudtrain-modules//modules/container/aks/cluster"
  region_name                           = var.region_name
  region_code                           = module.region.region_info.region_code
  solution_name                         = var.solution_name
  solution_stage                        = var.solution_stage
  solution_fqn                          = var.solution_fqn
  common_tags                           = local.module_common_tags
  resource_group_id                     = var.resource_group_id
  kubernetes_api_access_cidrs           = var.kubernetes_api_access_cidrs
  kubernetes_cluster_name               = var.kubernetes_cluster_name
  kubernetes_version                    = var.kubernetes_version
  vnet_id                               = module.network.vnet_id
  system_pool_subnet_id                 = local.system_pool_subnet_id
  user_pool_subnet_id                   = local.user_pool_subnet_id
  loadbalancer_subnet_id                = local.loadbalancer_subnet_id
  node_pool_templates                   = local.az_node_group_templates
  zones_to_span                         = var.zones_to_span
  key_vault_id                          = var.key_vault_id
  log_analytics_workspace_id            = var.log_analytics_workspace_id
  aks_addon_aad_rbac_enabled            = true
  aks_addon_aad_rbac_admin_group_ids    = var.admin_principal_ids
  encryption_at_host_enabled            = false
  aks_addon_agic_enabled                = false
  aks_addon_agic_application_gateway_id = ""
}
