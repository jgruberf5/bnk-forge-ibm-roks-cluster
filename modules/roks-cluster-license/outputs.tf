output "license_id" {
  description = "Name of the License custom resource."
  value       = module.license.license_id
}

output "license_namespace" {
  description = "Namespace where the License CR is deployed."
  value       = module.license.license_namespace
}

output "cluster_id" {
  description = "Cluster ID (passthrough for downstream wiring)."
  value       = data.ibm_container_cluster_config.cluster_config.cluster_name_id
}
