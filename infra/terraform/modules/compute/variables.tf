variable gcp_project {
    description = "GCP project name"
}

variable gcp_region {
    description = "GCP Region"
}

variable instance_name {
    description = "Instance name"
}

variable machine_type {
    description = "Machine type"
} 

variable tags {
    description = "Instance tags"
}

variable vpc_network {
    description = "GCP VPC network"
}
variable vpc_subnetwork {
    description = "GCP VPC subnetwork"
}

variable image {}

variable instance_count {}

variable "script_bucket" {
  
}

variable "dns_zone" {
  
}

variable "dns_names" {}
variable "wildcard_certificate" {}
variable "cert_email" {}
variable "mail_host_name" {}

# variable network {
#     description = "GCP network"
# }

# variable cluster_name {
#     description = "GKE cluster name"
# } 

# variable cluster_ipv4_cidr_block {
#     description = "GKE cluster IPV4 CIDR block"
# }

variable schedule_start {}
variable schedule_stop {}
variable schedule_tz {}
