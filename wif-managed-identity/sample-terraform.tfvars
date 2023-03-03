azure_tenant_id       = "<azure_tenant_id>"
azure_subscription_id = "<azure_subscription_id>"

azure_resource_group_name       = "gcp-wif-rg-2"
azure_resource_group_location   = "northeurope"
azure_network_name              = "gcp-wif-network"
azure_subnet_name               = "gcp-wif-subnet"
azure_vm_network_interface_name = "gcp-wif-ni"
azure_vm_name                   = "gcp-wif-test-vm"
azure_vm_ssh_private_key_name   = "az_vm.pem"
azure_ad_group_name             = "gcp-wif"
azure_application_name          = "gcp-wif-app"
azure_managed_identity_name     = "gcp-wif-umi"
azure_vm_admin_user_name        = "adminuser"

gcp_project_id                                         = "<gcp_project_id>"
gcp_workload_identity_pool_name                        = "azure-mi-test-pool"
gcp_workload_identity_pool_display_name                = "azure-mi-test-pool"
gcp_workload_identity_pool_provider_id                 = "azure-mi-test-pool-provider"
gcp_workload_identity_pool_provider_attribute_mappings = {
  "google.subject" = "assertion.sub"
  "google.groups"  = "assertion.groups"
  "attribute.tid"  = "assertion.tid"
}