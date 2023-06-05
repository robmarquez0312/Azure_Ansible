# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "my_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096

}


resource "azurerm_managed_disk" "my_disk" {
  count                = var.count_vm_instance
  name                 = "datadisk_existing_${count.index}"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "30"
}

resource "azurerm_availability_set" "my_avset" {
  name                         = "my_avset"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  platform_fault_domain_count  = var.count_vm_instance
  platform_update_domain_count = var.count_vm_instance
  managed                      = true
}


# Create virtual machine
  resource "azurerm_linux_virtual_machine" "srmgpl002v001" {
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  availability_set_id   = azurerm_availability_set.my_avset.id
  network_interface_ids = [element(azurerm_network_interface.my_nic.*.id, count.index)]
  size                  = "Standard_DS1_v2"
  
  resource "azurerm_linux_virtual_machine" "srapdl001v030" {
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  availability_set_id   = azurerm_availability_set.my_avset.id
  network_interface_ids = [element(azurerm_network_interface.my_nic.*.id, count.index)]
  size                  = "Standard_DS1_v2"
  
  resource "azurerm_linux_virtual_machine" "vm01" {
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  availability_set_id   = azurerm_availability_set.my_avset.id
  network_interface_ids = [element(azurerm_network_interface.my_nic.*.id, count.index)]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "30"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

 
  # Generate ssh key pair for the VM and user
  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }
}
