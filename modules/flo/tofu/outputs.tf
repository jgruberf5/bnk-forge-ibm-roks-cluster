output "target_cluster_name_or_id" {
  value = var.roks_cluster_name_or_id
}

output "flo_release_name" {
  value = module.flo.flo_release_name
}

output "flo_namespace" {
  value = module.flo.flo_namespace
}

output "flo_utils_namespace" {
  value = module.flo.f5_utils_namespace
}

output "flo_version" {
  value = module.flo.flo_version
}

output "flo_extracted_flo_version" {
  value = module.flo.extracted_flo_version
}

output "flo_trusted_profile_id" {
  value = module.flo.trusted_profile_id
}

output "flo_pod_deployment_status" {
  value = module.flo.flo_pod_deployment_status
}

output "flo_cluster_issuer_name" {
  value = module.flo.cluster_issuer_name
}

output "cneinstance_network_attachments" {
  value = module.flo.cneinstance_network_attachments
}
