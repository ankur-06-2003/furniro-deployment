resource "google_service_account" "gke_nodes" {
  account_id   = "gke-nodes-sa"
  display_name = "Service Account for GKE Nodes"
}

resource "google_project_iam_member" "node_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/artifactregistry.reader",
    "roles/storage.objectViewer"
  ])
  project = var.project
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}