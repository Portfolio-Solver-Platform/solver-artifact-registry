terraform {
  required_providers {
    harbor = {
      source  = "goharbor/harbor"
      version = ">= 3.10.0"
    }
  }
}

provider "harbor" {
  url      = var.harbor_url
  username = var.harbor_admin_user
  password = var.harbor_admin_password
}

resource "harbor_project" "psp" {
  name   = "psp"
  public = false

  vulnerability_scanning = true

  deployment_security = "high"
}

resource "harbor_interrogation_services" "main" {
  default_scanner           = "Trivy"  
  vulnerability_scan_policy  = "Daily"  
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
    access {
      resource = "repository"
      action   = "pull"
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