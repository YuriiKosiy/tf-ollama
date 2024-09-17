variable "GOOGLE_PROJECT" {
  type        = string
  description = "GCP project name"
}

variable "GOOGLE_REGION" {
  type        = string
  default     = "us-central1-c"
  description = "GCP region to use"
}

variable "GKE_MACHINE_TYPE" {
  type        = string
  default     = "e2-standard-8"
  description = "Machine type"
}

variable "GITHUB_OWNER" {
  type        = string
  description = "The GitHub owner"
}

variable "GITHUB_TOKEN" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "FLUX_GITHUB_REPO" {
  description = "Name of the GitHub repository used by Flux"
  type        = string
  default     = "flux-gitops"
}

variable "FLUX_GITHUB_TARGET_PATH" {
  type        = string
  default     = "clusters"
  description = "Flux manifests subdirectory"
}

variable "GKE_CLUSTER_NAME" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "kbot"
}