locals {
  jit_deployment_env_variables = merge({ RESOURCE_SCOPE = "${var.jit_scope}/${var.jit_scope_id}" }, { "IAP_BACKEND_SERVICE_ID" = "placeholder" }, var.jit_deployment_env_variables)
  jit_env_variables_list = [
    for k, v in local.jit_deployment_env_variables : { name = k, value = v }
  ]
}


# # Grant the Cloud Run Invoker role (roles/run.invoker) to the service agent that's used by IAP:
# # Configure a load balancer

data "google_project" "project" {
  project_id = var.jit_deployment_project
}



resource "google_cloud_run_v2_service" "jit" {
  name     = var.jit_deployment_name
  project  = var.jit_deployment_project
  location = var.jit_deployment_region
  ingress  = "INGRESS_TRAFFIC_ALL"
  lifecycle {
    ignore_changes = [
      template[0].labels
    ]
  }
  template {
    labels = {
      "cloud.googleapis.com/location" = var.jit_deployment_region
    }
    service_account = var.jit_sa_email
    containers {
      image = var.jit_cloudrun_image

      dynamic "env" {
        for_each = local.jit_env_variables_list
        content {
          name  = env.value["name"]
          value = env.value["value"]
        }
      }
    }
  }
}

# resource "google_iap_client" "project_client" {
#   display_name = "Test Client"
#   brand        = var.jit_iap_brand
#   # project      = var.jit_deployment_project
# }

# resource "google_project_iam_member" "jit_iap" {
#   project = var.jit_deployment_project
#   role    = "roles/run.invoker"
#   member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-iap.iam.gserviceaccount.com"
# }



# data "google_iap_client" "project_client" {
#   brand     = "projects/${data.google_project.project.number}/brands/[BRAND_NUMBER]"
#   client_id = FOO.apps.googleusercontent.com
# }

# module "gce-lb-http" {
#   source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
#   version = "~> 9.0"
#   # lifecycle {
#   #   ignore_changes = [
#   #     backends.default.iap
#   #   ]
#   # }
#   project = var.jit_deployment_project
#   name    = "${var.jit_deployment_name}-lb"
#   # target_tags                     = [module.mig1.target_tags, module.mig2.target_tags]
#   ssl                             = true
#   managed_ssl_certificate_domains = ["${var.jit_deployment_project}.tmount008.com"]
#   https_redirect                  = true
#   backends = {
#     default = {
#       description = null
#       groups = [
#         {
#           group = google_compute_region_network_endpoint_group.jit_sl_neg.id
#         }
#       ]
#       enable_cdn              = false
#       edge_security_policy    = null
#       security_policy         = null
#       custom_request_headers  = null
#       custom_response_headers = null

#       iap_config = {
#         enable               = false
#         oauth2_client_id     = null
#         oauth2_client_secret = null
#       }
#       log_config = {
#         enable      = false
#         sample_rate = null
#       }
#       protocol         = null
#       port_name        = null
#       compression_mode = null
#     }
#   }
# }

resource "google_compute_backend_service" "jit" {
  project = var.jit_deployment_project
  name    = "${var.jit_deployment_name}-backend"
  backend {
    group = google_compute_region_network_endpoint_group.jit_sl_neg.id
  }
  # provisioner "local-exec" {
  #   command = "gcloud compute backend-services describe ${self.name} --global --format 'value(id)' > ${path.module}/backend-id.txt"
  # }
}

data "external" "example" {
  # program = ["gcloud compute backend-services describe ${google_compute_backend_service.jit.name} --global --format 'value(id)'"]
  program = ["cmd.exe", "/C", "gcloud compute backend-services describe ${google_compute_backend_service.jit.name} --global --project=${var.jit_deployment_project} --format=json"]
  # program = ["cmd.exe", "/C", "gcloud compute backend-services describe ${google_compute_backend_service.jit.name} --global --project=${var.jit_deployment_project} --format=json | jq -r \".id\""]
  depends_on = [
    google_compute_backend_service.jit
  ]

}


output "test" {
  value = local.jit_deployment_env_variables
}

resource "google_compute_region_network_endpoint_group" "jit_sl_neg" {
  project               = var.jit_deployment_project
  name                  = "${var.jit_deployment_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.jit_deployment_region
  cloud_run {
    service = var.jit_deployment_name
  }
}

resource "google_compute_url_map" "urlmap" {
  project     = var.jit_deployment_project
  name        = "${var.jit_deployment_name}-map"
  description = "a description"

  default_service = google_compute_backend_service.jit.id

}

resource "google_compute_managed_ssl_certificate" "default" {
  project = var.jit_deployment_project
  name    = "${var.jit_deployment_name}-ssl"
  managed {
    domains = ["${var.jit_deployment_project}.tmount008.com."]
  }
}

resource "google_compute_target_https_proxy" "default" {
  project          = var.jit_deployment_project
  name             = "${var.jit_deployment_name}-proxy"
  url_map          = google_compute_url_map.urlmap.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_global_forwarding_rule" "google_compute_forwarding_rule" {
  project               = var.jit_deployment_project
  name                  = "${var.jit_deployment_name}-https"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
  target                = google_compute_target_https_proxy.default.id
}
