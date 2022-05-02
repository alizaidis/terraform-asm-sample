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

variable "project_id" {
  type        = string
  description = "The GCP project where the cluster will be created"
}

variable "region" {
  type        = string
  description = "The GCP region where the cluster will be created"
  default = "us-central1"
}

variable "zone" {
  type        = string
  description = "The GCP zone in the region where the cluster will be created"
  default     = "us-central1-c"
}

variable "vpc" {
  type        = string
  description = "The VPC network where the cluster will be created"
  default     = "asm-tutorial"
}

variable "subnet_name" {
  type        = string
  description = "The subnet where the cluster will be created"
  default = "subnet-01"
}

variable "subnet_ip" {
  type    = string
  default = "10.0.0.0/20"
}

variable "pod_cidr" {
  type        = string
  description = "CIDR range for Pods"
  default = "10.10.0.0/20"
}

variable "svc1_cidr" {
  type        = string
  description = "CIDR range for services"
  default = "10.100.0.0/24"
}

variable "svc2_cidr" {
  type        = string
  description = "CIDR range for services"
  default = "10.100.1.0/24"
}

variable "gke_channel" {
  type = string
  default = "REGULAR"
}

variable "enable_cni" {
  type = bool
  default = "true"
}
