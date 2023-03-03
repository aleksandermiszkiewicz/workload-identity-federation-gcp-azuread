output "vm_public_ip" {
  value = azurerm_linux_virtual_machine.az_test_vm.public_ip_address
}

output "vm_ssh_privet_key_name" {
  value = local_file.save_azure_ssh_key.filename
}