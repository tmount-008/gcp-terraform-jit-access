resource "google_folder_iam_member" "iam_securityAdmin" {
  count  = var.jit_scope == "folders" ? 1 : 0
  folder = "folders/${var.jit_scope_id}"
  role   = "roles/iam.securityAdmin"
  member = "serviceAccount:${module.jit_sa.email}"
}

resource "google_folder_iam_member" "cloudasset_viewer" {
  count  = var.jit_scope == "folders" ? 1 : 0
  folder = "folders/${var.jit_scope_id}"
  role   = "roles/cloudasset.viewer"
  member = "serviceAccount:${module.jit_sa.email}"
}
