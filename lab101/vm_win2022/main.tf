terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.99.0"
    }
  }
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "dev" {
    name = "dev"
    location = "canadacentral"
}

resource "azurerm_storage_account" "storagedev001" {
  name                     = "devstoragedev001"
  resource_group_name      = "dev"
  location                 = "canadacentral"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_resource_group" "example" {
  name     = "dev"
  location = "canadacentral"
}

resource "azurerm_virtual_network" "example" {
  name                = "mynetwork"
  address_space       = ["10.0.0.0/16"]
  location            = "canadacentral"
  resource_group_name = "dev"
}

resource "azurerm_subnet" "example" {
  name                 = "mysubnet"
  resource_group_name  = "dev"
  virtual_network_name = "mynetwork"
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "mypublicip"
  location            = "canadacentral"
  resource_group_name = "dev"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "example" {
  name                = "mynic"
  location            = "canadacentral"
  resource_group_name = "dev"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "winserv01"
  resource_group_name = "dev"
  location            = "canadacentral"
  size                = "Standard_F2"
  admin_username      = "azureuser01"
  admin_password      = "P@ssw0rd!123"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
