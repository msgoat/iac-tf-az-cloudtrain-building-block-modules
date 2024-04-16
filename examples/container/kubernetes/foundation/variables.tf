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

variable "network_cidr" {
  description = "The CIDR range of the network hosting the Kubernetes cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version of the Kubernetes cluster"
  type        = string
}

variable "kubernetes_cluster_name" {
  description = "Logical name of the Kubernetes cluster"
  type        = string
}

variable "kubernetes_api_access_cidrs" {
  description = "CIDR blocks defining source IP ranges allowed to access the Kubernetes API"
  type        = list(string)
}

variable "kubernetes_workload_access_cidrs" {
  description = "CIDR blocks defining source IP ranges allowed to access workload on the Kubernetes cluster"
  type        = list(string)
}

variable "names_of_zones_to_span" {
  description = "Names of availability zones the AKS cluster is supposed to span"
  type        = list(string)
}

variable "node_group_templates" {
  description = "Templates for node groups attached to the Kubernetes cluster, will be replicated for each spanned zone"
  type = list(object({
    enabled            = optional(bool, true)      # controls if this node group gets actually created
    managed            = optional(bool, true)      # controls if this node group is a managed or unmanaged node group
    name               = string                    # logical name of this nodegroup
    role               = string                    # role of the node group; must be either "user" or "system"
    kubernetes_version = optional(string, null)    # Kubernetes version of this node group; will default to kubernetes_version of the cluster, if not specified but may differ from kubernetes_version during cluster upgrades
    min_size           = number                    # minimum size of this node group
    max_size           = number                    # maximum size of this node group
    desired_size       = optional(number, 0)       # desired size of this node group; will default to min_size if set to 0
    disk_size          = number                    # size of attached root volume in GB
    capacity_type      = string                    # defines the purchasing option for the VM instances in all node groups
    instance_type      = string                    # virtual machine instance type which should be used for the AWS EKS worker node groups ordered descending by preference
    labels             = optional(map(string), {}) # Kubernetes labels to be attached to each worker node
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])                                    # Kubernetes taints to be attached to each worker node
    image_type = optional(string, "X86_64")     # Type of OS images to be used for VM instances; possible values are: X86_64 | ARM_64
  }))
}

variable "kubernetes_admin_group_ids" {
  description = "List of group object IDs whose members are allowed to administrate the Kubernetes cluster"
  type        = list(string)
}

variable "parent_dns_zone_id" {
  description = "Unique identifier of a public parent DNS zone the newly created DNS zone should be linked with"
  type        = string
}

variable "encryption_at_host_enabled" {
  description = "Controls if encryption at host should be enabled on all AKS worker nodes (default: true). Attention: current subscription must support it!"
  type        = bool
}
