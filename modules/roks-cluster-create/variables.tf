variable "ibmcloud_api_key" {
  description = "IBM Cloud API key"
  type        = string
  sensitive   = true
}

variable "ibmcloud_cluster_region" {
  description = "IBM Cloud region where the ROKS cluster will be created"
  type        = string
}

variable "ibmcloud_resource_group" {
  description = "IBM Cloud resource group used for the cluster and COS lookup"
  type        = string
  default     = "default"
}

variable "roks_cluster_name" {
  description = "Name of the IBM ROKS cluster to create"
  type        = string
}

variable "ibmcloud_cos_instance_name" {
  description = "Name of the existing IBM Cloud Object Storage instance used for the OpenShift registry"
  type        = string
}

variable "workers_per_zone" {
  description = "Worker node count per zone"
  type        = number
  default     = 2
}

variable "openshift_cluster_version" {
  description = "Desired OpenShift major.minor version"
  type        = string
  default     = "4.18"
}

variable "min_worker_vcpu_count" {
  description = "Minimum vCPU count used when auto-selecting a worker flavor"
  type        = number
  default     = 16
}

variable "min_worker_memory_gb" {
  description = "Minimum worker memory in GB used when auto-selecting a worker flavor"
  type        = number
  default     = 64
}

variable "worker_flavor" {
  description = "Optional explicit worker flavor override"
  type        = string
  default     = ""
}

variable "cluster_vpc_name" {
  description = "Optional VPC name override for the cluster VPC"
  type        = string
  default     = ""
}

variable "cluster_vpc_cidr" {
  description = "Base CIDR for the cluster VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "zones" {
  description = "Optional explicit zone list. Defaults to the first three VPC zones in the selected region."
  type        = list(string)
  default     = []
}
