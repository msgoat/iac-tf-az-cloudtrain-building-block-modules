variable "region_name" {
  description = "The name of the region to deploy into."
  type        = string
}

variable "region_code" {
  description = "The unique code of the region to deploy into."
  type        = string
}

variable "solution_name" {
  description = "The name of the cloud solution that owns all cloud resources."
  type        = string
}

variable "solution_stage" {
  description = "The name of the current solution stage."
  type        = string
}

variable "solution_fqn" {
  description = "The fully qualified name of the cloud solution."
  type        = string
}

variable "common_tags" {
  description = "Common tags to be attached to all cloud resources"
  type        = map(string)
}

variable resource_group_id {
  description = "The unique identifier of the resource group supposed to own all allocated resources"
  type = string
}

variable "k8s_cluster_id" {
  description = "Unique identifier of the Kubernetes cluster to bootstrap."
  type        = string
}

variable key_vault_id {
  description = "Unique identifier of the Key Vault managing the encryption keys"
  type = string
}

variable "dns_zone_id" {
  description = "Unique identifier of a public DNS supposed contain all public DNS records to route traffic to the Kubernetes cluster"
  type = string
}

variable "letsencrypt_account_name" {
  description = "Lets Encrypt Account name to be used to request certificates"
  type = string
}
