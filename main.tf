terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.12"
    }
  }
}

resource "random_password" "vmpasswd" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "vmpasswdINPUT" {
  name         = "vmpasswd"
  value        = random_password.vmpasswd.result
  key_vault_id = var.kvid
}

data "azurerm_key_vault_secret" "vmpasswd" {
  name         = "vmpasswd"
  key_vault_id = var.kvid
  depends_on = [
    azurerm_key_vault_secret.vmpasswdINPUT,
  ]
}

locals {
  dmzvmname = format("%s%s%s", "vmdmz", var.enviro, var.prjnum)
  intvmname = format("%s%s%s", "vmint", var.enviro, var.prjnum)
} 

resource "azurerm_network_interface" "nicdmzvm" {
  name                = format("%s%s%s%s", "nicdmzvm", var.prjname, var.enviro, var.prjnum)
  location            = var.location
  resource_group_name = var.rgname

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.dmzsubnetID
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Environment   = var.enviro
  }
}

resource "azurerm_network_interface" "nicintvm" {
  name                = format("%s%s%s%s", "nicintvm", var.prjname, var.enviro, var.prjnum)
  location            = var.location
  resource_group_name = var.rgname

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.intsubnetID
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Environment   = var.enviro
  }
}

resource "azurerm_windows_virtual_machine" "vmdmz" {
  name                            = local.dmzvmname
  resource_group_name             = var.rgname
  location                        = var.location
  size                            = var.vmsku
  admin_username                  = "azureuser"
  admin_password                  = data.azurerm_key_vault_secret.vmpasswd.value
  //disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nicdmzvm.id]
  #delete_os_disk_on_termination  = "true"

  os_disk {
    #name              = format("%s%s", resource.azurerm_virtual_machine.vmweb.name, "-osdsk")   #format("%s%s", "disk1_", local.vmname)
    #create_option     = "FromImage"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  tags = {
    Environment   = var.enviro
  } 
}

resource "azurerm_windows_virtual_machine" "vmint" {
  name                            = local.intvmname
  resource_group_name             = var.rgname
  location                        = var.location
  size                            = var.vmsku
  admin_username                  = "azureuser"
  admin_password                  = data.azurerm_key_vault_secret.vmpasswd.value
  //disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nicintvm.id]
  #delete_os_disk_on_termination  = "true"

  os_disk {
    #name              = format("%s%s", resource.azurerm_virtual_machine.vmweb.name, "-osdsk")   #format("%s%s", "disk1_", local.vmname)
    #create_option     = "FromImage"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  tags = {
    Environment   = var.enviro
  } 
}