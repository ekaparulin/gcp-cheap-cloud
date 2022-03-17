provider "google" {
    project = var.gcp_project
    region  = var.gcp_region
}
data "google_project" "project" {
}
data "google_compute_zones" "available" {
}