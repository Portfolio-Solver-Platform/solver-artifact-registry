variable "harbor_url" {
  description = "Base URL to Harbor (e.g., http://harbor.local)"
  type        = string
  default     = "http://harbor.local"
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
