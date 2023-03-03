data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "az_vpc" {
  name                = var.network_name
  address_space       = var.network_addresses_ranges
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "az_subnet" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.az_vpc.name
  address_prefixes     = var.subnet_addresses_ranges
}

resource "azurerm_public_ip" "az_public_ip" {
  name                = var.vm_public_ip_name
  allocation_method   = "Static"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
}

resource "azurerm_network_security_group" "az_ssh_allow_rule" {
  name                = var.ingress_ssh_allow_rule_name
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "az_network_interface" {
  name                = var.vm_network_interface_name
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.az_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.az_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "az_ni_to_nsg_association" {
  network_interface_id      = azurerm_network_interface.az_network_interface.id
  network_security_group_id = azurerm_network_security_group.az_ssh_allow_rule.id
}

resource "tls_private_key" "az_test_vm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "az_test_vm" {
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  name                = var.vm_name

  admin_username        = var.vm_admin_user_name
  network_interface_ids = [azurerm_network_interface.az_network_interface.id]

  size = "Standard_DS1_v2"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 50
  }

  admin_ssh_key {
    public_key = tls_private_key.az_test_vm_ssh.public_key_openssh
    username   = var.vm_admin_user_name
  }

  source_image_reference {
    offer     = "UbuntuServer"
    publisher = "Canonical"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  dynamic identity {
    for_each = var.vm_identities
    content {
      type         = identity.value["type"]
      identity_ids = identity.value["identities_ids"]
    }
  }
}

resource "local_file" "save_azure_ssh_key" {
  filename = var.vm_ssh_private_key_file_name
  content  = tls_private_key.az_test_vm_ssh.private_key_pem
}

resource "null_resource" "ssh_key" {
  provisioner "local-exec" {
    command = "chmod 400 ${local_file.save_azure_ssh_key.filename}"
  }
}

resource "null_resource" "configure_vm" {
  connection {
    type        = "ssh"
    user        = var.vm_admin_user_name
    private_key = file(local_file.save_azure_ssh_key.filename)
    host        = azurerm_linux_virtual_machine.az_test_vm.public_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get install -y apt-transport-https ca-certificates gnupg curl lsb-release",
      "echo \"deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main\" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list",
      "curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.gpg > /dev/null",
      "sudo mkdir -p /etc/apt/keyrings && curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null && sudo chmod go+r /etc/apt/keyrings/microsoft.gpg",
      "AZ_REPO=$(lsb_release -cs) && echo \"deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main\" | sudo tee /etc/apt/sources.list.d/azure-cli.list",
      "sudo apt-get update -y && sudo apt-get install -y google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin azure-cli jq",
    ]
  }
  depends_on = [local_file.save_azure_ssh_key]
}
