output "target_cluster_name_or_id" {
  value = var.roks_cluster_name_or_id
}

output "license_id" {
  value = module.license.license_id
}

output "license_namespace" {
  value = module.license.license_namespace
}
