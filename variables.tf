variable "jit_deployment_project" {
  type = string
}

variable "jit_deployment_name" {
  type    = string
  default = "jit"
}

variable "jit_deployment_type" {
  type = string
  # description = "One of \"appengine\" or \"cloudrun\"."
  description = "\"appengine\"."
  validation {
    condition = anytrue([
      var.jit_deployment_type == "appengine",
      var.jit_deployment_type == "cloudrun",
    ])
    error_message = "Just-in-Time deployment type must be one of \"appengine\" or \"cloudrun\"."
  }
  default = "appengine"
}

variable "jit_deployment_version" {
  type    = string
  default = "v1"
}

variable "jit_deployment_region" {
  type        = string
  description = "Region to deploy appengine or cloudrun resources. Region selected must be one that supports the corresponding service."
}

variable "jit_sa_name" {
  type    = list(string)
  default = ["jitaccess"]
}

variable "jit_sa_display_name" {
  type    = string
  default = "Just-In-Time Access"
}

variable "jit_sa_description" {
  type    = string
  default = "Just-In-Time Access"
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
    # RESOURCE_SCOPE        = "${var.jit_scope}/${var.jit_scope_id}"
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

variable "jit_cloudrun_image" {
  type        = string
  description = "Image name and tag to use for cloud run deployment"
  default     = null
}