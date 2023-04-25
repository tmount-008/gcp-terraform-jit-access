locals {
  jit_deployment_env_variables = merge({ RESOURCE_SCOPE = "${var.jit_scope}/${var.jit_scope_id}" }, var.jit_deployment_env_variables)
  jit_source_download_command  = var.provisioner_interpreter == "cmd" ? "git clone https://github.com/GoogleCloudPlatform/jit-access.git && move jit-access jit-access-${random_string.jit_source.id} && cd jit-access-${random_string.jit_source.id}/sources && git checkout latest && zip -r ../../jit-${random_string.jit_source.id}.zip . && cd ../.." : "git clone https://github.com/GoogleCloudPlatform/jit-access.git && mv jit-access jit-access-${random_string.jit_source.id} && cd jit-access-${random_string.jit_source.id}/sources && git checkout latest && zip -r ../../jit-${random_string.jit_source.id}.zip . && cd ../.."
  jit_source_cleanup_command   = var.provisioner_interpreter == "cmd" ? "rmdir /s /q jit-access-${random_string.jit_source.id} & del jit-${random_string.jit_source.id}.zip" : "rm -rf jit-access-${random_string.jit_source.id} & rm -f jit-${random_string.jit_source.id}.zip"
}


## Deploy AppEngine Application
resource "google_app_engine_application" "jit" {
  project     = var.jit_deployment_project
  location_id = var.jit_deployment_region
}

## Deploy empty default service to AppEngine 
resource "google_app_engine_standard_app_version" "default_service" {
  depends_on = [
    google_app_engine_application.jit
  ]

  version_id = "1"
  project    = var.jit_deployment_project
  service    = "default"
  runtime    = "nodejs12"
  entrypoint {
    shell = ""
  }
  deployment {
    files {
      name       = "index.html"
      source_url = "https://storage.googleapis.com/${google_storage_bucket.jit_source.name}/${google_storage_bucket_object.default_service_index_html.name}"
    }
  }
}

## Deploy Version of Service to AppEngine 
resource "google_app_engine_standard_app_version" "jit" {
  depends_on = [
    google_app_engine_standard_app_version.default_service,
    google_app_engine_application.jit
  ]
  service        = "jit"
  version_id     = var.jit_deployment_version
  runtime        = "java11"
  instance_class = "F2"
  project        = var.jit_deployment_project

  entrypoint {
    shell = ""
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.jit_source.name}/${google_storage_bucket_object.jit_source.name}"
    }
  }

  env_variables             = local.jit_deployment_env_variables
  delete_service_on_destroy = false
  service_account           = var.jit_sa_email
}

## Create random string
resource "random_string" "jit_source" {
  length  = 16
  special = false
  upper   = false
}


## Create GCS bucket
resource "google_storage_bucket" "jit_source" {
  name          = "just-in-time-access-provisioning-source-${random_string.jit_source.id}"
  project       = var.jit_deployment_project
  location      = var.gcs_bucket_location
  force_destroy = true

  uniform_bucket_level_access = true
}


## Grant SA permission to GCS bucket
resource "google_storage_bucket_iam_member" "jit_source" {
  bucket = google_storage_bucket.jit_source.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${var.jit_sa_email}"
}


## Download source content from Github Repo
resource "null_resource" "jit_source" {
  triggers = {
    # always_run = "${timestamp()}"
    version = var.jit_deployment_version
  }
  provisioner "local-exec" {
    command = <<EOD
      ${local.jit_source_download_command}
    EOD
  }
}


## Upload jit source content to GCS bucket
resource "google_storage_bucket_object" "jit_source" {
  name   = "jit.zip"
  source = "jit-${random_string.jit_source.id}.zip"
  bucket = google_storage_bucket.jit_source.name
  depends_on = [
    null_resource.jit_source
  ]
  lifecycle {
    ignore_changes = [
      detect_md5hash
    ]
    replace_triggered_by = [
      null_resource.jit_source
    ]
  }
}


## Upload default service source content to GCS bucket
resource "google_storage_bucket_object" "default_service_index_html" {
  name   = "default_service_index.html"
  source = "index.html"
  bucket = google_storage_bucket.jit_source.name

}

## Clean up artifacts
resource "null_resource" "jit_source_cleanup" {
  depends_on = [
    google_app_engine_standard_app_version.jit,
    google_storage_bucket_object.jit_source
  ]
  triggers = {
    version = var.jit_deployment_version
    # always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOD
      ${local.jit_source_cleanup_command}
    EOD
  }
}

