output "service_accounts_emails" {
  value = [for sa in local.service_accounts : format("%s%s%s%s", sa["sa_name"], "@", var.project_id, ".iam.gserviceaccount.com")]
}