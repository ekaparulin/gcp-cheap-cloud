resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_network
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name          = var.vpc_subnetwork
  ip_cidr_range = var.vpc_subnetwork_cidr
  network       = google_compute_network.vpc_network.id
  # secondary_ip_range {
  #   range_name    = "tf-test-secondary-range-update1"
  #   ip_cidr_range = "192.168.10.0/24"
  # }
}