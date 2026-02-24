resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.zone # Regional for Production HA
  project  = var.project

  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id

  remove_default_node_pool = true
  initial_node_count       = 2
  deletion_protection      = true

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods-range"
    services_secondary_range_name = "services-range"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "prod-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.gke.name
  
  autoscaling {
    min_node_count = 2
    max_node_count = 5
  }

  node_config {
    machine_type    = "e2-standard-4"
    service_account = google_service_account.gke_nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = { environment = "production" }
    tags   = ["gke-node"]
  }
}
