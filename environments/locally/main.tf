provider "azurerm" {
  features {}
}

module "app-service-cosmosdb" {
  source = "../../modules/app-service-cosmosdb"

  name_prefix = "locally-example-cosmosdb"
  location    = "berlin"
  tags = {
    ProvisionedVia = "Terraform"
  }

  # The app authenticates to Cosmos with its managed identity, so no key is
  # stored in app settings. Locally supports managed identity, the same as Azure.
  cosmos_auth_mode = "aad"
}
