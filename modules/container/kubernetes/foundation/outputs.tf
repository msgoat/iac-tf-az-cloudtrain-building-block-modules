output "k8s_cluster_id" {
  description = "Unique identifier of the Kubernetes cluster"
  value       = module.cluster.aks_cluster_id
}

output "k8s_cluster_fqn" {
  description = "Fully qualified name of the Kubernetes cluster"
  value       = module.cluster.aks_cluster_name
}

output "network_id" {
  description = "Unique identifier name of the network hosting the Kubernetes cluster"
  value       = module.network.vnet_id
}

output "network_fqn" {
  description = "Fully qualified name of the network hosting the Kubernetes cluster"
  value       = module.network.vnet_name
}