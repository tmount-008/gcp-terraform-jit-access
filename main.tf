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


## Create IAP Brand
resource "google_iap_brand" "iap_brand" {
  depends_on = [
    module.jit_services
  ]
  support_email     = var.iap_support_email
  application_title = "Just-In-Time Access"
  project           = var.jit_deployment_project
}

module "appengine" {
  source = "./modules/appengine"
  count  = var.jit_deployment_type == "appengine" ? 1 : 0
  depends_on = [
    module.jit_services,
    module.jit_sa,
    google_iap_brand.iap_brand
  ]

  jit_deployment_project       = var.jit_deployment_project
  jit_deployment_version       = var.jit_deployment_version
  jit_deployment_region        = var.jit_deployment_region
  jit_scope                    = var.jit_scope
  jit_deployment_env_variables = var.jit_deployment_env_variables
  jit_scope_id                 = var.jit_scope_id
  iap_support_email            = var.iap_support_email
  gcs_bucket_location          = var.gcs_bucket_location
  provisioner_interpreter      = var.provisioner_interpreter
  jit_sa_email                 = module.jit_sa.email

}


## Staged for future use
# module "cloudrun" {
#   source = "./modules/cloudrun"
#   count  = var.jit_deployment_type == "cloudrun" ? 1 : 0
#   depends_on = [
#     module.jit_services,
#     module.jit_sa,
#     google_iap_brand.iap_brand
#   ]

# }
