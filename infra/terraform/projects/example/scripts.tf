resource "google_storage_bucket" "scripts" {
  name          = "${var.gcp_project}-vm-scripts"
  location      = "EUROPE-NORTH1"

}

resource "google_storage_bucket_object" "startup" {
  name   = "${var.instance_name}/startup.sh"
  source = "${path.cwd}/scripts/startup.sh"
  bucket = google_storage_bucket.scripts.name
}

resource "google_storage_bucket_object" "init" {
  count = length(var.init_scripts)
  name   = "${var.instance_name}/init/${var.init_scripts[count.index]}"
  source = "${path.cwd}/scripts/init/${var.init_scripts[count.index]}"
  bucket = google_storage_bucket.scripts.name
}

resource "google_storage_bucket_object" "shutdown" {
  name   = "${var.instance_name}/shutdown.sh"
  source = "${path.cwd}/scripts/shutdown.sh"
  bucket = google_storage_bucket.scripts.name
}