## Enable APIs required for both AppEngine and CloudRun deployment types
module "jit_services" {
  source     = "terraform-google-modules/project-factory/google//modules/project_services"
  version    = "~> 14.2"
  project_id = var.jit_deployment_project
  activate_apis = [
    "cloudasset.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iap.googleapis.com",
    "cloudbuild.googleapis.com",
    "containerregistry.googleapis.com",
    "appengine.googleapis.com",
    "compute.googleapis.com",
    "run.googleapis.com"
  ]
  disable_services_on_destroy = false
}

## Create service account
module "jit_sa" {
  source  = "terraform-google-modules/service-accounts/google"
  version = "~> 4.2"
  depends_on = [
    module.jit_services
  ]
  project_id   = var.jit_deployment_project
  names        = var.jit_sa_name
  display_name = var.jit_sa_display_name
  description  = var.jit_sa_description
  project_roles = [
    "${var.jit_deployment_project}=>roles/clouddebugger.agent",
  ]
}

## Create random string
resource "random_string" "jit_source" {
  length  = 16
  special = false
  upper   = false
}

## Create IAP Brand
resource "google_iap_brand" "iap_brand" {
  support_email     = var.iap_support_email
  application_title = "Just-In-Time Access"
  project           = var.jit_deployment_project
}
