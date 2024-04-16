# ----------------------------------------------------------------------------
# main.tf
# ----------------------------------------------------------------------------

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

locals {
  module_common_tags = merge(var.common_tags, { TerraformBuildingBlockName = "container/kubernetes/bootstrap" })
}

module "region" {
  source      = "../../../../../iac-tf-az-cloudtrain-modules//modules/base/region"
  region_name = var.region_name
}

locals {
  public_dns_zone_id_parts        = split("/", var.public_dns_zone_id)
  public_dns_zone_subscription_id = local.public_dns_zone_id_parts[2]
  public_dns_zone_rg_name         = local.public_dns_zone_id_parts[4]
  public_dns_zone_name            = local.public_dns_zone_id_parts[8]
}

data "azurerm_dns_zone" "given" {
  name                = local.public_dns_zone_name
  resource_group_name = local.public_dns_zone_rg_name
}

module "k8s_addons" {
  source                          = "../../../../../iac-tf-az-cloudtrain-modules//modules/container/aks/addons"
  region_name                     = var.region_name
  region_code                     = module.region.region_info.region_code
  solution_fqn                    = var.solution_fqn
  solution_name                   = var.solution_name
  solution_stage                  = var.solution_stage
  common_tags                     = var.common_tags
  resource_group_id               = var.resource_group_id
  aks_cluster_id                  = var.k8s_cluster_id
  key_vault_id                    = var.key_vault_id
  public_dns_zone_id              = var.public_dns_zone_id
  letsencrypt_account_name        = var.letsencrypt_account_name
  loadbalancer_id                 = var.loadbalancer_id
  kubernetes_cluster_architecture = var.kubernetes_cluster_architecture
  host_names                      = var.host_names
  opentelemetry_enabled           = var.opentelemetry_enabled
  opentelemetry_collector_host    = var.opentelemetry_collector_host
  opentelemetry_collector_port    = var.opentelemetry_collector_port
}

module "k8s_tools" {
  source                             = "../../../../../iac-tf-az-cloudtrain-modules//modules/container/aks/tools"
  region_name                        = var.region_name
  region_code                        = module.region.region_info.region_code
  solution_name                      = var.solution_name
  solution_stage                     = var.solution_stage
  solution_fqn                       = var.solution_fqn
  common_tags                        = local.module_common_tags
  resource_group_id                  = var.resource_group_id
  cert_manager_enabled               = true
  cert_manager_cluster_issuer_name   = module.k8s_addons.production_cluster_certificate_issuer_name
  aks_cluster_id                     = var.k8s_cluster_id
  kubernetes_ingress_class_name      = module.k8s_addons.kubernetes_ingress_class_name
  kubernetes_ingress_controller_type = module.k8s_addons.kubernetes_ingress_controller_type
  grafana_host_name                  = data.azurerm_dns_zone.given.name
  grafana_path                       = "/grafana"
  prometheus_host_name               = data.azurerm_dns_zone.given.name
  prometheus_path                    = "/prometheus"
  kibana_host_name                   = data.azurerm_dns_zone.given.name
  kibana_path                        = "/kibana"
  jaeger_host_name                   = data.azurerm_dns_zone.given.name
  jaeger_path                        = "/jaeger"
  key_vault_id                       = var.key_vault_id
  kubernetes_storage_class_name      = module.k8s_addons.kubernetes_storage_class_name
  depends_on                         = [module.k8s_addons]
}

