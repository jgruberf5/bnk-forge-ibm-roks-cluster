output "namespace" {
  description = "Namespace where cert-manager is deployed."
  value       = kubernetes_namespace_v1.cert_manager.metadata[0].name
}

output "namespace_id" {
  description = "Kubernetes namespace UID."
  value       = kubernetes_namespace_v1.cert_manager.metadata[0].uid
}

output "helm_release_name" {
  description = "Name of the cert-manager Helm release."
  value       = helm_release.cert_manager.name
}

output "helm_release_version" {
  description = "Installed cert-manager Helm chart version."
  value       = helm_release.cert_manager.version
}

output "crd_ready" {
  description = "True once the post-deployment delay has elapsed and cert-manager CRDs are expected to be registered."
  value       = true
  depends_on  = [time_sleep.cert_manager_ready]
}

output "cluster_id" {
  description = "Cluster ID (passthrough for downstream wiring)."
  value       = data.ibm_container_vpc_cluster.existing_cluster.id
}

output "cluster_name" {
  description = "Cluster name (passthrough for downstream wiring)."
  value       = data.ibm_container_vpc_cluster.existing_cluster.name
}
