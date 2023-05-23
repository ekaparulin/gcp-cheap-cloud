module "vpc" {
    source        = "../../modules/vpc"
    gcp_project   = var.gcp_project
    gcp_region        = var.gcp_region
    vpc_network       = var.vpc_network
    vpc_subnetwork    = var.vpc_subnetwork
    vpc_subnetwork_cidr  = var.vpc_subnetwork_cidr
}
module "firewall" {
    source        = "../../modules/firewall"
    gcp_project   = var.gcp_project
    gcp_region    = var.gcp_region
    network       = var.vpc_network
    source_cidr   = "0.0.0.0/0"
}

module "compute" {
    source        = "../../modules/compute"

    instance_count = var.instance_count
    image          = var.image

    gcp_project   = var.gcp_project
    gcp_region    = var.gcp_region

    schedule_count = var.schedule_enabled
    schedule_start = var.instance_start
    schedule_stop  = var.instance_stop
    schedule_tz    = var.time_zone

    instance_name  = var.instance_name
    machine_type   = var.machine_type
    tags           = var.tags

    vpc_network       = var.vpc_network
    vpc_subnetwork    = var.vpc_subnetwork

    dns_zone       = var.dns_zone
    dns_names      = join(",", var.dns_names)

}