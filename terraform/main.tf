terraform {
  required_version = "~> 0.12"
  backend "gcs" {}
}

locals {
  gcp_location_parts = split("-", var.gcp_location)
  gcp_region         = format("%s-%s", local.gcp_location_parts[0], local.gcp_location_parts[1])
}

provider "google" {
  version = "3.5.0"
  project = var.gcp_project_id
  region  = local.gcp_region
}

resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_network_name
  auto_create_subnetworks = "false"
  project                 = var.gcp_project_id
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name    = var.vpc_subnetwork_name
  region  = local.gcp_region
  project = var.gcp_project_id
  ip_cidr_range = var.vpc_subnetwork_cidr_range
  network = var.vpc_network_name
  secondary_ip_range {
    range_name    = var.cluster_secondary_range_name
    ip_cidr_range = var.cluster_secondary_range_cidr
  }
  secondary_ip_range {
    range_name    = var.services_secondary_range_name
    ip_cidr_range = var.services_secondary_range_cidr
  }
  private_ip_google_access = true
  depends_on = [
    google_compute_network.vpc_network,
  ]
}


resource "google_compute_router" "router" {
  count   = var.enable_cloud_nat ? 1 : 0
  name    = format("%s-router", var.cluster_name)
  region  = local.gcp_region
  network = google_compute_network.vpc_network.self_link
}

resource "google_compute_router_nat" "nat" {
  count = var.enable_cloud_nat ? 1 : 0
  name  = format("%s-nat", var.cluster_name)
  router = google_compute_router.router[0].name
  region = google_compute_router.router[0].region
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = var.enable_cloud_nat_logging
    filter = var.cloud_nat_logging_filter
  }
}

module "cluster" {
  source  = "./cluster"

  # These values are set from the terrafrom.tfvas file
  gcp_project_id                         = var.gcp_project_id
  cluster_name                           = var.cluster_name
  gcp_location                           = var.gcp_location
  daily_maintenance_window_start_time    = var.daily_maintenance_window_start_time
  node_pools                             = var.node_pools
  cluster_secondary_range_name           = var.cluster_secondary_range_name
  services_secondary_range_name          = var.services_secondary_range_name
  master_ipv4_cidr_block                 = var.master_ipv4_cidr_block
  access_private_images                  = var.access_private_images
  http_load_balancing_disabled           = var.http_load_balancing_disabled
  master_authorized_networks_cidr_blocks = var.master_authorized_networks_cidr_blocks
  private_nodes                          = var.private_nodes
  private_endpoint                       = var.private_endpoint
  pod_security_policy_enabled            = var.pod_security_policy_enabled
  identity_namespace                     = var.identity_namespace

  vpc_network_name    = google_compute_network.vpc_network.name
  vpc_subnetwork_name = google_compute_subnetwork.vpc_subnetwork.name
}
