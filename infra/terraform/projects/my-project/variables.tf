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

variable instance_count {}
variable "schedule_enabled" {
  default = 0
}

variable instance_start {}
variable instance_stop {}
variable time_zone {}
variable instance_name {}
variable machine_type {}
variable image {}
variable tags {}
variable "dns_zone" {}
variable "dns_names" {}
