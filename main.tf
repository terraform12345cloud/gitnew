provider "azurerm" {
  features{}
}

resource "azurerm_resource_group" "name" {
  name = "git1"
  location = "eastus"
}
resource "azurerm_virtual_network" "Vnet" {
  name                = "Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.name.location
  resource_group_name = azurerm_resource_group.name.name
}

resource "azurerm_subnet" "SpokeSubnet" {
  name                 = "Subnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes     = ["10.0.1.0/24"] 
}

resource "azurerm_network_interface" "SpokeNic" {
  name                = "Nic"
  location            = azurerm_resource_group.name.location
  resource_group_name = azurerm_resource_group.name.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SpokeSubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "lvm1" {
  name                            = "lvm1"
  resource_group_name             = azurerm_resource_group.name.name
  location                        = azurerm_resource_group.name.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "Chinmay@12345"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.SpokeNic.id,
  ]



  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

output "subnet_id" {
  value = azurerm_subnet.SpokeSubnet.id
}

output "spokeremoteid" {
  description = "SpokeVnet id :-"
  value = azurerm_virtual_network.Vnet.id
}