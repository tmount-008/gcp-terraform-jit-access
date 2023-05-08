# # Create a backend service
# # Build the application and push the container image to Container Registry - seperate from this module
# # Create a configuration file for the Just-In-Time Access application
# # Deploy the application
# # Grant the Cloud Run Invoker role to allUsers
# # Configure a load balancer
# jit_deployment_env_variables = merge({ RESOURCE_SCOPE = "${var.jit_scope}/${var.jit_scope_id}" }, var.jit_deployment_env_variables)

# module "jit" {
#   source  = "GoogleCloudPlatform/cloud-run/google"
#   version = "~> 0.6.0"

#   # Required variables
#   service_name           = "jit"
#   project_id             = var.jit_deployment_project
#   env_vars = local.jit_deployment_env_variables
#   location               = var.jit_deployment_region
#   image                  = "trav880/jit-access:latest"

# }

# resource "google_cloud_run_v2_service" "jit" {
#   name     = "jit"
#   location = "us-central1"
#   ingress  = "INGRESS_TRAFFIC_ALL"

#   template {


#     containers {
#       image = "us-docker.pkg.dev/cloudrun/container/hello"

#       env {
#         name  = "FOO"
#         value = "bar"
#       }

#       }

#     }

#   traffic {
#     type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
#     percent = 100
#   }

# }