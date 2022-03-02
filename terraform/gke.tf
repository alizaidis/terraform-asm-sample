resource "null_resource" "previous" {}

resource "time_sleep" "wait_120_seconds" {
  depends_on = [null_resource.enable_mesh]

  create_duration = "120s"
}

resource "null_resource" "enable_mesh" {

  provisioner "local-exec" {
    when    = create
    command = "echo y | gcloud container hub mesh enable --project ${var.project_id}"
  }

  depends_on = [null_resource.previous]
}

module "enabled_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 10.0"

  project_id                  = var.project_id
  disable_services_on_destroy = false

  activate_apis = [
    "compute.googleapis.com",
    "anthos.googleapis.com",
    "mesh.googleapis.com"
  ]
 
}



# google_client_config and kubernetes provider must be explicitly specified like the following.

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  depends_on                 = [time_sleep.wait_120_seconds]
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version                    = "~> 16.0"
  project_id                 = module.enabled_google_apis.project_id
  name                       = "asm-cluster-1"
  release_channel            = var.gke_channel
  region                     = var.region
  zones                      = [var.zone]
  initial_node_count         = 4
  network                    = var.vpc
  subnetwork                 = var.subnet_name
  ip_range_pods              = "${var.subnet_name}-pod-cidr"
  ip_range_services          = "${var.subnet_name}-svc1-cidr"
  config_connector           = true
  enable_private_endpoint    = false
  enable_private_nodes       = true
  master_ipv4_cidr_block     = "172.16.0.0/28"
}

module "workload_identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version             = "~> 16.0.1"
  gcp_sa_name         = "cnrmsa"
  cluster_name        = module.gke.name
  name                = "cnrm-controller-manager"
  location            = var.zone
  use_existing_k8s_sa = true
  annotate_k8s_sa     = false
  namespace           = "cnrm-system"
  project_id          = module.enabled_google_apis.project_id
  roles               = ["roles/owner"]
}
