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
variable "wildcard_certificate" {}
variable "cert_email" {}
variable "mail_host_name" {}

