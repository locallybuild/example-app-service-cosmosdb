# ---------------------------------------------------------------------------
# App Service Plan - houses the App Service running the custom container.
# ---------------------------------------------------------------------------
resource "azurerm_service_plan" "main" {
  name                = "${var.name_prefix}-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
}

# ---------------------------------------------------------------------------
# Linux App Service (Web App for Containers) - runs the Tasks app.
#
# The image is pulled directly from Docker Hub (a public image), so there is no
# Container Registry to provision or import into - unlike the other App Service
# examples in this repo. App Service terminates TLS at the platform, so the
# browser reaches the app over HTTPS while the container serves plain HTTP on
# WEBSITES_PORT.
# ---------------------------------------------------------------------------
resource "azurerm_linux_web_app" "main" {
  name                = local.web_app_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  tags                = var.tags

  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  identity {
    type = "SystemAssigned"
  }

  site_config {
    health_check_path                 = "/healthz"
    health_check_eviction_time_in_min = 2

    application_stack {
      # Pulled straight from Docker Hub - a public image, so no registry
      # credentials are needed.
      docker_image_name   = local.image_name
      docker_registry_url = "https://index.docker.io"
    }
  }

  app_settings = merge(
    {
      # App Service routes public traffic to the container on this port, and the
      # app binds to it (12-factor port binding).
      WEBSITES_PORT    = tostring(local.app_port)
      PORT             = tostring(local.app_port)
      COSMOS_ENDPOINT  = azurerm_cosmosdb_account.main.endpoint
      COSMOS_AUTH_MODE = var.cosmos_auth_mode
      COSMOS_DATABASE  = azurerm_cosmosdb_sql_database.main.name
      COSMOS_CONTAINER = azurerm_cosmosdb_sql_container.tasks.name
    },
    var.cosmos_auth_mode == "key" ? {
      COSMOS_KEY = azurerm_cosmosdb_account.main.primary_key
    } : {}
  )
}
