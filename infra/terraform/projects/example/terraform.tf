terraform {
    required_version = ">= 1.1.7"
    backend "gcs" {
        bucket  = "eugener-one-terraform-state"
        prefix  = "terraform"
    }
}