# gcp-terraform-jit-access

<!-- BEGIN_TF_DOCS -->
## Requirements

Terraform runner requires these tools to be installed
- git
- zip

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.62.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_jit_sa"></a> [jit\_sa](#module\_jit\_sa) | terraform-google-modules/service-accounts/google | ~> 4.2 |
| <a name="module_jit_services"></a> [jit\_services](#module\_jit\_services) | terraform-google-modules/project-factory/google//modules/project_services | ~> 14.2 |

## Resources

| Name | Type |
|------|------|
| [google_app_engine_application.jit](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/app_engine_application) | resource |
| [google_app_engine_standard_app_version.default_service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/app_engine_standard_app_version) | resource |
| [google_app_engine_standard_app_version.jit](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/app_engine_standard_app_version) | resource |
| [google_folder_iam_member.cloudasset_viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_member) | resource |
| [google_folder_iam_member.iam_securityAdmin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_member) | resource |
| [google_iap_brand.iap_brand](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iap_brand) | resource |
| [google_organization_iam_member.cloudasset_viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.iam_securityAdmin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_project_iam_member.cloudasset_viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.iam_securityAdmin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_storage_bucket.jit_source](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.jit_source](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_object.default_service_index_html](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [google_storage_bucket_object.jit_source](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [null_resource.jit_source](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.jit_source_cleanup](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.jit_source](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gcs_bucket_location"></a> [gcs\_bucket\_location](#input\_gcs\_bucket\_location) | n/a | `string` | `"US-CENTRAL1"` | no |
| <a name="input_iap_support_email"></a> [iap\_support\_email](#input\_iap\_support\_email) | n/a | `string` | n/a | yes |
| <a name="input_jit_deployment_env_variables"></a> [jit\_deployment\_env\_variables](#input\_jit\_deployment\_env\_variables) | Reference: https://github.com/GoogleCloudPlatform/jit-access/wiki/Configuration | `map` | <pre>{<br>  "ELEVATION_DURATION": "60",<br>  "JUSTIFICATION_HINT": "Bug or case number",<br>  "JUSTIFICATION_PATTERN": ".*"<br>}</pre> | no |
| <a name="input_jit_deployment_project"></a> [jit\_deployment\_project](#input\_jit\_deployment\_project) | n/a | `string` | n/a | yes |
| <a name="input_jit_deployment_region"></a> [jit\_deployment\_region](#input\_jit\_deployment\_region) | n/a | `string` | n/a | yes |
| <a name="input_jit_deployment_type"></a> [jit\_deployment\_type](#input\_jit\_deployment\_type) | One of "appengine" or "cloudrun". | `string` | `"appengine"` | no |
| <a name="input_jit_deployment_version"></a> [jit\_deployment\_version](#input\_jit\_deployment\_version) | n/a | `string` | `"v1"` | no |
| <a name="input_jit_sa_description"></a> [jit\_sa\_description](#input\_jit\_sa\_description) | n/a | `string` | `"Just-In-Time Access"` | no |
| <a name="input_jit_sa_display_name"></a> [jit\_sa\_display\_name](#input\_jit\_sa\_display\_name) | n/a | `string` | `"Just-In-Time Access"` | no |
| <a name="input_jit_sa_name"></a> [jit\_sa\_name](#input\_jit\_sa\_name) | n/a | `list(string)` | <pre>[<br>  "jitaccess"<br>]</pre> | no |
| <a name="input_jit_scope"></a> [jit\_scope](#input\_jit\_scope) | One of "projects", "folders" or "organizations". | `string` | n/a | yes |
| <a name="input_jit_scope_id"></a> [jit\_scope\_id](#input\_jit\_scope\_id) | project id, folder id, or organization id depending on the jit\_scope being applied | `string` | n/a | yes |
| <a name="input_provisioner_interpreter"></a> [provisioner\_interpreter](#input\_provisioner\_interpreter) | 'sh' for Linux(default), 'cmd' for Windows | `string` | `"sh"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->