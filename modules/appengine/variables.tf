variable "jit_deployment_project" {
  type = string
}

variable "jit_sa_email" {
  type        = string
  description = "Email of service account to use for JIT deployment"

}

variable "jit_deployment_region" {
  type = string
}

variable "jit_scope" {
  type        = string
  description = "One of \"projects\", \"folders\" or \"organizations\"."
  validation {
    condition = anytrue([
      var.jit_scope == "projects",
      var.jit_scope == "folders",
      var.jit_scope == "organizations"
    ])
    error_message = "Just-in-Time scope must be one of \"projects\", \"folders\" or \"organizations\"."
  }
}

variable "jit_deployment_env_variables" {
  default = {
    ELEVATION_DURATION    = "60"
    JUSTIFICATION_HINT    = "Bug or case number"
    JUSTIFICATION_PATTERN = ".*"
  }
  description = "Reference: https://github.com/GoogleCloudPlatform/jit-access/wiki/Configuration"
}


variable "jit_scope_id" {
  type        = string
  description = "project id, folder id, or organization id depending on the jit_scope being applied"
}

variable "iap_support_email" {
  type        = string
  description = ""
}

variable "gcs_bucket_location" {
  type        = string
  description = ""
}

variable "provisioner_interpreter" {
  type        = string
  description = "'sh' for Linux(default), 'cmd' for Windows"
  validation {
    condition = anytrue([
      var.provisioner_interpreter == "cmd",
      var.provisioner_interpreter == "sh",
    ])
    error_message = "'sh' for Linux, 'cmd' for Windows"
  }

  default = "sh"
}