variable "region_name" {
  description = "The name of the region to deploy into."
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

variable "resource_group_id" {
  description = "The unique identifier of the resource group supposed to own all allocated resources"
  type        = string
}

variable "k8s_cluster_id" {
  description = "Unique identifier of the Kubernetes cluster to bootstrap."
  type        = string
}

variable "kubernetes_cluster_architecture" {
  description = "Processor architecture of the worker nodes of the target Kubernetes cluster; allowed values are: `X86_64` (default), `ARM_64`"
  type        = string
  validation {
    condition     = var.kubernetes_cluster_architecture == "X86_64" || var.kubernetes_cluster_architecture == "ARM_64"
    error_message = "The kubernetes_cluster_architecture must be either `X86_64` (Intel-based 64 bit) or `ARM_64` (ARM-based 64 bit)"
  }
}

variable "key_vault_id" {
  description = "Unique identifier of the Key Vault managing the encryption keys"
  type        = string
}

variable "public_dns_zone_id" {
  description = "Unique identifier of a public DNS supposed contain all public DNS records to route traffic to the Kubernetes cluster"
  type        = string
}

variable "letsencrypt_account_name" {
  description = "Lets Encrypt Account name to be used to request certificates"
  type        = string
}

variable "loadbalancer_id" {
  description = "Unique identifier of the load balancer supposed to route traffic to the Kubernetes cluster"
  type        = string
}

variable "host_names" {
  description = "Host names of all hosts whose traffic should be routed to this solution"
  type        = list(string)
  default     = []
}

variable "opentelemetry_enabled" {
  description = "Controls if OpenTelemetry support should be enabled"
  type        = bool
}

variable "opentelemetry_collector_host" {
  description = "Host name of the OpenTelemetry collector endpoint; required if `opentelemetry_enabled` is true"
  type        = string
}

variable "opentelemetry_collector_port" {
  description = "Port number of the OpenTelemetry collector endpoint; required if `opentelemetry_enabled` is true"
  type        = number
}

variable "kubernetes_namespace_templates" {
  description = "Templates for the Kubernetes namespaces to create"
  type = list(object({
    name                    = string
    labels                  = optional(map(string), {})
    network_policy_enforced = optional(bool, false)
  }))
}
