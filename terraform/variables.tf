variable "harbor_url" {
  description = "Base URL to Harbor (e.g.,harbor.local)"
  type        = string
  default     = "harbor.local"
}

variable "harbor_internal_url" {
  description = "kubernetes url"
  type        = string
  default     = "harbor.harbor.svc.cluster.local"
}

variable "harbor_admin_user" {
  description = "Harbor admin username"
  type        = string
  default     = "admin"
}

variable "harbor_admin_password" {
  description = "Harbor admin password"
  type        = string
  sensitive   = true
}


variable "kubernetes_namespace" {
  type        = string
  description = "The Kubernetes namespace to create the secret in."
  default     = "psp"
}

