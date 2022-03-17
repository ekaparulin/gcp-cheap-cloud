variable gcp_project {
    description = "GCP project name"
}

variable gcp_region {
    description = "GCP Region"
}

variable vpc_network {
    description = "GCP VPC network"
}

variable vpc_subnetwork {
    description = "Subnetwork name to create"
}
variable vpc_subnetwork_cidr {
    description = "Subnetwork CIDR block to create"
}

variable instance_start {}
variable instance_stop {}
variable time_zone {}
variable instance_name {}
variable machine_type {}
variable tags {
    description = "Instance tags"
}

variable image {}
variable instance_count {}
variable "init_scripts" {
  
}

variable "dns_zone" {
  
}

variable "dns_names" {}

# variable cluster_name {
#     description = "GKE cluster name"
# }

# variable node_count {
#     description = "GKE node pool node count"
# }

# variable image_type {
#     description = "GKE node pool node image type"
# }

# variable machine_type {
#     description = "GKE node pool node machine type"
# }

# variable preemptible {
#     description = "Use preemptible machines in the node pool"
#     default     = "false"
# }

# variable cluster_ipv4_cidr_block {
#     description = "GKE cluster IPV4 CIDR block"
# }

# variable services_ipv4_cidr_block {
#     description = "GKE services IPV4 CIDR block"
# }

# variable master_ipv4_cidr_block {
#     description = "GKE master IPV4 CIDR block"
# }

# variable ksa_backend_namespaces {
#     description = "Namespaces using ksa-backend service account (list)"
#     type = list
# }

# variable ksa_frontend_namespaces {
#     description = "Namespaces using ksa-frontend service account (list)"
#     type = list
# }