# Artifact Registry for container images
resource "google_artifact_registry_repository" "furniro" {
  project       = var.project
  location      = var.region
  repository_id = "furniro"
  description   = "Artifact Registry for furniro container images"
  format        = "DOCKER"
}
resource "google_storage_bucket" "tf_state_bucket" {
  name     = "furniro-terraform-state-${var.project}"
  location = var.region

  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 365
    }
  }
}

# Optional: restrict access to only project editors/service accounts via IAM
resource "google_storage_bucket_iam_binding" "state_admins" {
  bucket = google_storage_bucket.tf_state_bucket.name
  role   = "roles/storage.objectAdmin"
  members = [
    "projectEditor:${var.project}",
  ]
}
