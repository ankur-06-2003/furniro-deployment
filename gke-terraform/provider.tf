terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    bucket = var.bucket_name
    prefix = "terraform/state"
  }
}

provider "google" {
  project     = var.project
  region      = var.region
  zone        = var.zone
}
