provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "desafio" {
  name     = "desafio-resource-group"
  location = "eastus"
}

resource "azurerm_virtual_network" "desafio" {
  name                = "desafio-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.desafio.location
  resource_group_name = azurerm_resource_group.desafio.name
}

resource "azurerm_subnet" "desafio" {
  name                 = "desafio-subnet"
  resource_group_name  = azurerm_resource_group.desafio.name
  virtual_network_name = azurerm_virtual_network.desafio.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "desafio" {
  count               = 2
  name                = "desafio-nic-${count.index}"
  location            = azurerm_resource_group.desafio.location
  resource_group_name = azurerm_resource_group.desafio.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.desafio.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "desafio" {
  count               = 2
  name                = "desafio-vm-${count.index}"
  location            = azurerm_resource_group.desafio.location
  resource_group_name = azurerm_resource_group.desadfio.name
  network_interface_ids = [
    azurerm_network_interface.desafio[count.index].id,
  ]

  vm_size = "Standard_D2_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "desafio-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "desafiovm${count.index}"
    admin_username = "root"
    admin_password = "prueba123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
