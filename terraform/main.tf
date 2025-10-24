terraform {
  required_providers {
    harbor = {
      source  = "goharbor/harbor"
      version = ">= 3.10.0"
    }
      kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.38.0"
    }
  }
}

provider "harbor" {
  url      = "http://${var.harbor_url}"
  username = var.harbor_admin_user
  password = var.harbor_admin_password
}

provider "kubernetes" {
  # config_path    = "~/.kube/config"
}

resource "harbor_project" "psp" {
  name   = "psp"
  public = false
  vulnerability_scanning = true
  deployment_security = "high"
  enable_content_trust_cosign = true
}

resource "harbor_project" "psp_solvers" {
  name   = "psp-solvers"
  public = false
  vulnerability_scanning = true
  deployment_security = "high"
  enable_content_trust_cosign = true
}

resource "harbor_interrogation_services" "main" {
  default_scanner = "Trivy"
  vulnerability_scan_policy = "Daily"
}


resource "harbor_robot_account" "cd" {
  name        = "cd"
  description = "CD robot with push permission"
  duration    = -1            
  level       = "project"     

  permissions {
    kind      = "project"
    namespace = harbor_project.psp.name   

    access {
      resource = "repository"
      action   = "push"
      effect   = "allow"
    }
    
  }
}

output "robot_name" {
  value = harbor_robot_account.cd.name    
}

output "robot_secret" {
  value     = harbor_robot_account.cd.secret
  sensitive = true
}




resource "harbor_robot_account" "pull" {
  name        = "pull"
  description = "robot to pull images from psp and psp-solvers projects"
  duration    = -1
  level       = "system"

  permissions {
    kind      = "project"
    namespace = harbor_project.psp.name

    access {
      resource = "repository"
      action   = "pull"
      effect   = "allow"
    }

    access {
      resource = "repository"
      action   = "list"
      effect   = "allow"
    }
  }

  permissions {
    kind      = "project"
    namespace = harbor_project.psp_solvers.name

    access {
      resource = "repository"
      action   = "pull"
      effect   = "allow"
    }

    access {
      resource = "repository"
      action   = "list"
      effect   = "allow"
    }
  }
}



resource "kubernetes_secret" "harbor-creds" {
  metadata {
    name      = "harbor-creds"
    namespace = var.kubernetes_namespace
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.harbor_url}" = {
          auth = base64encode(format("%s%s", "robot$", "${harbor_robot_account.pull.name}:${harbor_robot_account.pull.secret}"))
        }
      }
    })
  }
}


