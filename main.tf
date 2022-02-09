data "terraform_remote_state" "region" {
  backend = "remote"

  config = {
    organization = "Awesome-Company"
    workspaces = {
          name = "TFCloud-TriggerDeploy"
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

  
resource "azurerm_storage_account" "sa" {
  name                     = "tfcdiagnosticstore1191" 
  resource_group_name      = var.rgName
  location                 = data.terraform_remote_state.region.outputs.location
   account_tier            = "Standard"
   account_replication_type = "LRS"

   tags = {
    environment = "TFC test"
   }
  }
}
