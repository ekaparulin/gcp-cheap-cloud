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


variable "dns_zone" {
  
}

variable "dns_names" {}

variable schedule_count {
    default = 0
}
variable schedule_start {}
variable schedule_stop {}
variable schedule_tz {}
