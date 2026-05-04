output "target_cluster_name_or_id" {
  value = var.roks_cluster_name_or_id
}

output "cneinstance_enabled" {
  value = module.cneinstance.cneinstance_enabled
}

output "cneinstance_name" {
  value = module.cneinstance.cneinstance_name
}

output "cneinstance_id" {
  value = module.cneinstance.cneinstance_id
}

output "cneinstance_namespace" {
  value = module.cneinstance.cneinstance_namespace
}

output "cneinstance_manifest" {
  value = module.cneinstance.cneinstance_manifest
}

output "cneinstance_scc_policies_applied" {
  value = module.cneinstance.cneinstance_scc_policies_applied
}

output "flo_namespace_pods_count" {
  value = module.cneinstance.flo_namespace_pods_count
}

output "utils_namespace_pods_count" {
  value = module.cneinstance.utils_namespace_pods_count
}

output "pod_deployment_status" {
  value = module.cneinstance.pod_deployment_status
}
