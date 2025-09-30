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
  url      = var.harbor_url
  username = var.harbor_admin_user
  password = var.harbor_admin_password
}

provider "kubernetes" {}

resource "harbor_project" "psp" {
  name   = "psp"
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
  description = "robot to psp namespace to pull images"
  duration    = -1            
  level       = "project"     

  permissions {
    kind      = "project"
    namespace = harbor_project.psp.name   

    access {
      resource = "repository"
      action   = "pull"
      effect   = "allow"
    }
    
  }
}

# resource "kubernetes_secret" "example" {
#   metadata {
#     name = "basic-auth"
#   }

#   data = {
#     username = "admin"
#     password = "P4ssw0rd"
#   }

#   type = "kubernetes.io/basic-auth"
# }
# resource "kubernetes_secret" "harbor_pull_secret" {
#   metadata {
#     name      = "harbor-creds"
#     namespace = var.kubernetes_namespace
#   }

#   type = "kubernetes.io/dockerconfigjson"

#   data = {
#     ".dockerconfigjson" = jsonencode({
#       auths = {
#         "${var.harbor_url}" = {
#           auth = base64encode("${harbor_robot_account.pull.name}:${harbor_robot_account.pull.secret}")
#         }
#       }
#     })
#   }

#   depends_on = [harbor_robot_account.pull]
# }

# resource "kubernetes_service_account" "psp_default" {
#   metadata {
#     name      = "default"
#     namespace = "psp"
#   }

#   automount_service_account_token = true

#   image_pull_secret {
#     name = kubernetes_secret.harbor_pull_secret.metadata[0].name
#   }

#   depends_on = [kubernetes_secret.harbor_pull_secret]
# }


resource "kubernetes_secret" "harbor_creds" {
  metadata {
    name      = "harbor-creds"
    namespace = var.kubernetes_namespace
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.harbor_url}" = {
          auth = base64encode("${harbor_robot_account.cd.name}:${harbor_robot_account.cd.secret}")
        }
      }
    })
  }
}


