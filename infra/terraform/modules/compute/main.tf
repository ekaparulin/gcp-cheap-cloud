resource "google_compute_resource_policy" "policy" {
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
      script_bucket = var.script_bucket
      dns_zone = var.dns_zone
      dns_names = var.dns_names
      wildcard_certificate = var.wildcard_certificate
      cert_email = var.cert_email
      mail_host_name = var.mail_host_name

      startup-script-url = "${var.script_bucket}/${var.instance_name}/startup.sh"
      shutdown-script-url = "${var.script_bucket}/${var.instance_name}/shutdown.sh"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  =  google_service_account.service_account.email
    scopes = ["cloud-platform"]
  }
 
   resource_policies = [
       google_compute_resource_policy.policy.self_link
    ]

}