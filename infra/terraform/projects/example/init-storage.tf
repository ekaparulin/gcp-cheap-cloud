resource "google_storage_bucket" "script" {
  name          = "${var.gcp_project}-vm-init-scripts"
  location      = "EUROPE-NORTH1"

}

resource "google_storage_bucket_object" "init" {
  count = length(var.init_scripts)
  name   = "${var.instance_name}/${var.init_scripts[count.index]}"
  source = "${path.cwd}/init-scripts/${var.init_scripts[count.index]}"
  bucket = google_storage_bucket.script.name
}
