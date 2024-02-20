region_name    = "westeurope"
region_code    = "weu"
solution_name  = "iactrain"
solution_stage = "dev"
solution_fqn   = "iactrain-dev"
common_tags = {
  Organization = "msg systems ag"
  BusinessUnit = "Branche Automotive"
  Department   = "PG Cloud"
  ManagedBy    = "Terraform"
}
network_cidr                     = "10.17.0.0/16"
kubernetes_version               = "1.28"
kubernetes_cluster_name          = "k8stst2024"
kubernetes_api_access_cidrs      = ["0.0.0.0/0"]
kubernetes_workload_access_cidrs = ["0.0.0.0/0"]
node_group_templates = [
  {
    name          = "sysblue" # logical name of this nodegroup
    role          = "system"
    min_size      = 2                   # minimum size of this node group
    max_size      = 4                   # maximum size of this node group
    desired_size  = 2                   # desired size of this node group; will default to min_size if set to 0
    disk_size     = 64                  # size of attached root volume in GB
    capacity_type = "SPOT"              # defines the purchasing option for the virtual machine instances in all node groups
    instance_type = "Standard_D4pls_v5" # virtual machine instance type which should be used for the worker node groups
    image_type    = "AL2_ARM_64"
  },
  {
    name          = "appsblue" # logical name of this nodegroup
    role          = "user"
    min_size      = 2                   # minimum size of this node group
    max_size      = 10                  # maximum size of this node group
    desired_size  = 2                   # desired size of this node group; will default to min_size if set to 0
    disk_size     = 64                  # size of attached root volume in GB
    capacity_type = "SPOT"              # defines the purchasing option for the virtual machine instances in all node groups
    instance_type = "Standard_D8pls_v5" # virtual machine instance type which should be used for the worker node groups
    image_type    = "AL2_ARM_64"
  }
]
kubernetes_admin_group_ids = ["485ed2bc-f530-4bc7-8d1c-9ee57999a4f1"]
parent_dns_zone_id         = "/subscriptions/227d5934-f446-4e1b-b8d2-06f2942b64cb/resourceGroups/rg-eu-west-cloudtrain-core/providers/Microsoft.Network/dnszones/k8s.azure.msgoat.eu"
names_of_zones_to_span     = ["1", "2"]
encryption_at_host_enabled = false # must explicitly switch off encryption at host, since our subscription does not support it!