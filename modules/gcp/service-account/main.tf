locals {
  service_accounts       = {for id, service_account in var.service_accounts : id => service_account}
  service_accounts_roles = flatten([
  for service_account in local.service_accounts : [
  for role in service_account["sa_roles"] : {
    account_id = service_account["sa_name"]
    role       = role
  }
  ]
  ])

  service_accounts_wif = {for id, service_account in local.service_accounts : id => service_account if service_account["wif"] == true}
}

resource "google_service_account" "service_account" {
  for_each = local.service_accounts

  project      = var.project_id
  account_id   = each.value["sa_name"]
  display_name = format("%s-%s", "Terraform managed service account", each.value["sa_name"])
}

resource "google_project_iam_member" "roles_binding" {
  for_each = {for id, service_account in local.service_accounts_roles : "${service_account["account_id"]}_${service_account["role"]}" => service_account}

  project = var.project_id
  role    = each.value["role"]
  member  = "serviceAccount:${each.value["account_id"]}@${var.project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.service_account]
}

resource "google_service_account_iam_member" "workload_identity_user_role_binding" {
  for_each = local.service_accounts_wif

  service_account_id = "projects/${var.project_id}/serviceAccounts/${each.value["sa_name"]}@${var.project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.workloadIdentityUser"
  member             = each.value["member"]

  depends_on = [google_service_account.service_account]
}