output "cneinstance_id" {
  description = "Name of the CNEInstance resource."
  value       = module.cneinstance.cneinstance_id
}

output "cneinstance_namespace" {
  description = "Namespace where CNEInstance is deployed."
  value       = module.cneinstance.cneinstance_namespace
}

output "cneinstance_pod_deployment_status" {
  description = "Pod deployment status after CNEInstance readiness validation."
  value       = module.cneinstance.pod_deployment_status
}

output "cluster_id" {
  description = "Cluster ID (passthrough for downstream wiring)."
  value       = data.ibm_container_vpc_cluster.cluster.id
}

output "cluster_name" {
  description = "Cluster name (passthrough for downstream wiring)."
  value       = data.ibm_container_vpc_cluster.cluster.name
}
