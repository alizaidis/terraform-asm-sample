variable "project_id" {
  type        = string
  description = "the GCP project where the cluster will be created"
}

variable "region" {
  type        = string
  description = "the GCP region where the cluster will be created"
  default = "us-central1"
}

variable "zone" {
  type        = string
  description = "the GCP zone in the region where the cluster will be created"
}
