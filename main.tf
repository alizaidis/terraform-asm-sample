# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Resource to create Fleet memebership for the GKE cluster
resource "google_gke_hub_membership" "membership" {
  provider      = google-beta
  
  membership_id = "membership-hub-${module.gke.name}"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${module.gke.cluster_id}"
    }
  }
  depends_on = [module.gke.name, module.enabled_google_apis.activate_apis] 
}

# Module to install ASM on the GKE cluster
module "asm" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/asm"
  version = "20.0.0"
  cluster_name     = module.gke.name
  cluster_location = var.region
  project_id = module.enabled_google_apis.project_id
  enable_cni = var.enable_cni
}
