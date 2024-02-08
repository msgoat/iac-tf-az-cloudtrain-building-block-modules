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
      source = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# -- Initialize Kubernetes and Helm provider

locals {
  k8s_cluster_id_parts = split("/", var.k8s_cluster_id)
  k8s_cluster_name = local.k8s_cluster_id_parts[8]
  k8s_cluster_resource_group_name = local.k8s_cluster_id_parts[4]
  k8s_cluster_subscription = local.k8s_cluster_id_parts[2]
}

# retrieve target Kubernetes cluster
data azurerm_kubernetes_cluster cluster {
  name = local.k8s_cluster_name
  resource_group_name = local.k8s_cluster_resource_group_name
}

provider kubernetes {
  host                   = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host
  username               = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.username
  password               = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.password
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.cluster_ca_certificate)
}

# configuration of the Helm provider
provider helm {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host
    username               = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.username
    password               = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.password
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.cluster_ca_certificate)
  }
}

locals {
  module_common_tags = merge(var.common_tags, { TerraformBuildingBlockName = "container/kubernetes/bootstrap" })
}

module addons {
  source                = "../../../../../iac-tf-az-cloudtrain-modules//modules/container/aks/addons"
  region_name = var.region_name
  region_code = var.region_code
  solution_fqn = var.solution_fqn
  solution_name = var.solution_name
  solution_stage = var.solution_stage
  common_tags = var.common_tags
  resource_group_id = var.resource_group_id
  aks_cluster_id = var.k8s_cluster_id
  key_vault_id = var.key_vault_id
  dns_zone_id = var.dns_zone_id
  letsencrypt_account_name = var.letsencrypt_account_name
}
