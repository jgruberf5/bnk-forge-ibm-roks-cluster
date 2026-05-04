output "cluster_id" {
  value = module.cluster.cluster_id
}

output "cluster_name" {
  value = module.cluster.cluster_name
}

output "openshift_cluster_id" {
  value = module.cluster.openshift_cluster_id
}

output "openshift_cluster_name" {
  value = module.cluster.openshift_cluster_name
}

output "openshift_cluster_crn" {
  value = module.cluster.openshift_cluster_crn
}

output "openshift_cluster_public_endpoint" {
  value = module.cluster.openshift_cluster_public_endpoint
}

output "region" {
  value = var.ibmcloud_cluster_region
}

output "cos_instance_name" {
  value = local.cos_instance_name
}

output "transit_gateway_name" {
  value = local.transit_gateway_name
}
