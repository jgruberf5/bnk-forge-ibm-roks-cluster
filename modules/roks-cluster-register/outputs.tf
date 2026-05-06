output "cluster_id" {
  value = data.ibm_container_vpc_cluster.existing_cluster.id
}

output "cluster_name" {
  value = data.ibm_container_vpc_cluster.existing_cluster.name
}

output "cluster_endpoint" {
  value = data.ibm_container_vpc_cluster.existing_cluster.public_service_endpoint_url
}

output "openshift_cluster_id" {
  value = data.ibm_container_vpc_cluster.existing_cluster.id
}

output "openshift_cluster_name" {
  value = data.ibm_container_vpc_cluster.existing_cluster.name
}

output "openshift_cluster_crn" {
  value = data.ibm_container_vpc_cluster.existing_cluster.crn
}

output "openshift_cluster_public_endpoint" {
  value = data.ibm_container_vpc_cluster.existing_cluster.public_service_endpoint_url
}

output "region" {
  value = var.ibmcloud_cluster_region
}

output "kube_host" {
  value = data.ibm_container_cluster_config.cluster_config.host
}

output "kubeconfig" {
  value     = base64encode(data.local_file.kubeconfig.content)
  sensitive = true
}
