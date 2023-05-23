resource "google_compute_resource_policy" "policy" {
  count = var.schedule_count
  name   = var.instance_name
  region = var.gcp_region
  description = "Start and stop instances"
  instance_schedule_policy {
    vm_start_schedule {
      schedule = var.schedule_start
    }
    vm_stop_schedule {
      schedule = var.schedule_stop
    }
    time_zone = var.schedule_tz
  }
}

resource "google_compute_instance" "instance" {
  count = var.instance_count
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = element(data.google_compute_zones.available.names, count.index)

  tags = var.tags

  boot_disk {
    initialize_params {
      image = var.image
      size = 10
      type = "pd-standard"
    }
  }

  network_interface {
    network = var.vpc_network
    subnetwork = var.vpc_subnetwork

    access_config {
      // Ephemeral public IP
    }
  }

  scheduling {
      preemptible = true
      automatic_restart = false
  }

  labels = {
      project = var.gcp_project
  }

  metadata = {
      project = var.gcp_project
      dns_zone = var.dns_zone
      dns_names = var.dns_names
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  =  google_service_account.service_account.email
    scopes = ["cloud-platform"]
  }

}
