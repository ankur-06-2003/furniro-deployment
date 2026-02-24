variable "project" {
  description = "this is gcp project-id"
  type        = string

}

variable "region" {
  description = "this is gcp region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "this is gcp zone"
  type        = string
  default     = "us-central1-a"
}

variable "K8s_version" {
  description = "this is the gke version"
  type        = string
  default     = "1.31.6-gke.1020000"
}
variable "cluster_name" {
  description = "GKE Cluster Name"
  type        = string
  default     = "prod-gke-cluster"
}
variable "bucket_name" {
  description = "GCS bucket name for Terraform state"
  type        = string
}


