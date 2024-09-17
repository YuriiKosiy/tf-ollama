terraform {
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = "1.2"
    }
  }
}

module "github_repository" {
  source                   = "github.com/den-vasyliev/tf-github-repository"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux-ssh-pub"
}

module "tls_private_key" {
  source = "github.com/den-vasyliev/tf-hashicorp-tls-keys"
}

module "gke_cluster" {
  source           = "github.com/YuriiKosiy/tf-google-gke-cluster"
  GOOGLE_REGION    = var.GOOGLE_REGION
  GOOGLE_PROJECT   = var.GOOGLE_PROJECT
  GKE_NUM_NODES    = 1
  GKE_MACHINE_TYPE = var.GKE_MACHINE_TYPE
  GKE_CLUSTER_NAME = var.GKE_CLUSTER_NAME
}

provider "flux" {
  kubernetes = {
    config_path = module.gke_cluster.kubeconfig
  }
  git = {
    url = "https://github.com/${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}.git"
    http = {
      username = "git"
      password = var.GITHUB_TOKEN
    }
  }
}

module "flux_bootstrap" {
  source            = "github.com/YuriiKosiy/tf-fluxcd-flux-bootstrap"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  private_key       = module.tls_private_key.private_key_pem
  target_path       = "clusters/p72-flux"
  config_path       = module.gke_cluster.kubeconfig
  depends_on        = [module.gke_cluster]
}

module "gke-workload-identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version             = "33.0.0"
  use_existing_k8s_sa = true
  name                = "kustomize-controller"
  namespace           = "flux-system"
  project_id          = var.GOOGLE_PROJECT
  cluster_name        = "kbot"
  location            = var.GOOGLE_REGION
  annotate_k8s_sa     = true
  roles               = ["roles/cloudkms.cryptoKeyEncrypterDecrypter"]
}

module "kms" {
  source          = "github.com/YuriiKosiy/terraform-google-kms"
  project_id      = var.GOOGLE_PROJECT
  keyring         = "sops-flux1"
  location        = "global"
  keys            = ["sops-key-flux"]
  prevent_destroy = false
}
