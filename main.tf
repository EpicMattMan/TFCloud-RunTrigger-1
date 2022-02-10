data "terraform_remote_state" "network" {
  backend = "remote"

  config = {
    organization = "Awesome-Company"
    workspaces = {
          name = "TFCloud-Trigger-Network"
    }
  }
}

provider "azurerm" {
  version =  "2.66.0"

  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.clientSecret
  tenant_id = var.tenant_id

  features{}

  
#Deploy Public IP
resource "azurerm_public_ip" "pip1" {
  name                = "TFC-pip1"
  location            = data.terraform_remote_state.netowrk.outputs.location
  resource_group_name = data.terraform_remote_state.netowrk.outputs.rgName  
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

#Create NIC
resource "azurerm_network_interface" "nic1" {
  name                = "TFC-TestVM-Nic"  
  location            = data.terraform_remote_state.netowrk.outputs.location  
  resource_group_name = data.terraform_remote_state.netowrk.outputs.rgName 

    ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = date.terraform_remote_state.network.outputs.subnet1_id 
    private_ip_address_allocation  = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip1.id
  }
}

#Create Boot Diagnostic Account
resource "azurerm_storage_account" "sa" {
  name                     = "tfcdiagnosticstore1191" 
  resource_group_name      = data.terraform_remote_state.netowrk.outputs.rgName   
  location                 = data.terraform_remote_state.netowrk.outputs.location
   account_tier            = "Standard"
   account_replication_type = "LRS"

   tags = {
    environment = "TFC test"
   }
  }

#Create Virtual Machine
resource "azurerm_virtual_machine" "TFCVM" {
  name                  = "TF-TestVM-1"  
  location              = data.terraform_remote_state.netowrk.outputs.location 
  resource_group_name   = data.terraform_remote_state.netowrk.outputs.rgName 
  network_interface_ids = [azurerm_network_interface.nic1.id]
  vm_size               = "Standard_B1s"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk1"
    disk_size_gb      = "128"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "TFC-AwesomeVM1" 
    admin_username = "azureuser"
    admin_password = "Password12345!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

boot_diagnostics {
        enabled     = "true"
        storage_uri = azurerm_storage_account.sa.primary_blob_endpoint
    }
}
