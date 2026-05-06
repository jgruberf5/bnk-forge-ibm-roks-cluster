output "cluster_id" {
  value = ibm_container_vpc_cluster.openshift_cluster.id
}

output "cluster_name" {
  value = ibm_container_vpc_cluster.openshift_cluster.name
}

output "cluster_endpoint" {
  value = ibm_container_vpc_cluster.openshift_cluster.public_service_endpoint_url
}

output "openshift_cluster_id" {
  value = ibm_container_vpc_cluster.openshift_cluster.id
}

output "openshift_cluster_name" {
  value = ibm_container_vpc_cluster.openshift_cluster.name
}

output "openshift_cluster_crn" {
  value = ibm_container_vpc_cluster.openshift_cluster.crn
}

output "openshift_cluster_public_endpoint" {
  value = ibm_container_vpc_cluster.openshift_cluster.public_service_endpoint_url
}

output "region" {
  value = var.ibmcloud_cluster_region
}

output "cluster_vpc_id" {
  value = ibm_is_vpc.cluster_vpc.id
}

output "cos_instance_name" {
  value = data.ibm_resource_instance.registry_cos.name
}

output "kubeconfig" {
  value     = base64encode(data.local_file.kubeconfig.content)
  sensitive = true
}
