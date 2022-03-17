resource "google_service_account" "service_account" {
  project = data.google_project.project.project_id
  account_id   = join("-", [ "sa-compute", var.instance_name ])
  display_name = "Service Account for ${var.instance_name}"
}

resource "google_project_iam_member" "storage_object_viewer" {
  project = data.google_project.project.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "secretmanager_secret_accessor" {
  project = data.google_project.project.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "logs_writer" {
  project = data.google_project.project.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "monitoring_metric_writer" {
  project = data.google_project.project.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_project_iam_member" "dns_admin" {
  project = data.google_project.project.project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}


# resource "google_project_iam_member" "logging_log_writer" {
#   role    = "roles/logging.logWriter"
#   member  = "serviceAccount:${google_service_account.service_account.email}"
# }

# resource "google_project_iam_member" "logging_metric_writer" {
#   role    = "roles/monitoring.metricWriter"
#   member  = "serviceAccount:${google_service_account.service_account.email}"
# }

# resource "google_project_iam_member" "cloud_sql_client" {
#   role    = "roles/cloudsql.client"
#   member  = "serviceAccount:${google_service_account.service_account.email}"
# }

# resource "google_project_iam_member" "secretmanager_secret_accessor" {
#   role    = "roles/secretmanager.secretAccessor"
#   member  = "serviceAccount:${google_service_account.service_account.email}"
# }