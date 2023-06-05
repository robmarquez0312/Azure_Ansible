# Create Load Balancer
resource "azurerm_lb" "my_balancer" {
  name                = "loadBalancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "publicIPAddress"
    public_ip_address_id = azurerm_public_ip.my_public_ip.id
  }
}

# Create Load Balancer Backend Address Pool
resource "azurerm_lb_backend_address_pool" "lb-adress-pool-test" {
  loadbalancer_id = azurerm_lb.my_lb.id
  virtual_network_id    = azurerm_virtual_network.default.id  
  name            = "BE_POOL"
  
}



# Create public IPs
resource "azurerm_public_ip" "my_public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}