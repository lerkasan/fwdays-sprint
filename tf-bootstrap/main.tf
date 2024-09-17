terraform {
  required_version = ">= 1.7.0"

  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.3.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.1"
    }
    kind = {
      source  = "tehcyx/kind"
      version = ">= 0.4"
    }
  }
}

# ==========================================
# Construct KinD cluster
# ==========================================

resource "kind_cluster" "this" {
  name           = "flux"
  wait_for_ready = true

  kubeconfig_path = abspath("${path.root}/.terraform/kubeconfig")

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    networking {
      ip_family = "ipv4"
    }
  }
}

# ==========================================
# Initialise a Github project
# ==========================================

resource "github_repository" "this" {
  name        = var.github_repository
  description = var.github_repository
  visibility  = "private"
  auto_init   = true

  # Enable vulnerability alerts
  vulnerability_alerts = true
}

resource "github_branch_protection" "this" {
  repository_id = github_repository.this.id
  pattern       = "main"

  enforce_admins = true
  allows_force_pushes = false
  allows_deletions    = false

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = var.required_approving_review_count_for_main_branch
  }
}

# ==========================================
# Bootstrap Flux
# ==========================================

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository.this]

  embedded_manifests = true
  path               = "clusters/kind"
}
