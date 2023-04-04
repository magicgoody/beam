resource "google_cloudfunctions_function" "playground_functions" {
  count = length(var.function_names)

  name        = "playground-function-${var.function_names[count.index]}"
  description = var.function_description
  runtime     = "go120"
  entry_point = var.function_names[count.index]
  source_archive_bucket = var.gkebucket
  source_archive_object = "cloudfunction.zip"
  trigger_http = true

  environment_variables = {
    GOOGLE_CLOUD_PROJECT = var.project_id
  }

  timeout = "540"
  available_memory_mb = 2048
  service_account_email = var.service_account_email
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  count = length(var.function_names)

  project        = google_cloudfunctions_function.playground_functions[count.index].project
  region         = google_cloudfunctions_function.playground_functions[count.index].region
  cloud_function = google_cloudfunctions_function.playground_functions[count.index].name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}