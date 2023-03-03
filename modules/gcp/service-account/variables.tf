variable "service_accounts" {
  type = list(object({
    sa_name : string
    sa_roles : list(string)
    member : optional(string)
    wif : bool
  }))
  description = "List of service account to create. For service account which should not has WIF configured, 'wif' variable should be set to false"
}

variable project_id {
  type        = string
  description = "GCP project id in which resources should be created"
}
