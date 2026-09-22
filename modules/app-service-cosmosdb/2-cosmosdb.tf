# ---------------------------------------------------------------------------
# Cosmos DB (SQL / Core API) - the backing store for the Tasks app.
#
# The database and container are provisioned here (control plane). In "aad" mode
# the app connects to them as they already exist rather than creating them via
# the data plane, so both must be provisioned by this apply.
# ---------------------------------------------------------------------------
resource "azurerm_cosmosdb_account" "main" {
  name                = "${var.name_prefix}-cosmos"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  tags                = var.tags

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "tasksdb"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
}

resource "azurerm_cosmosdb_sql_container" "tasks" {
  name                = "tasks"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_sql_database.main.name
  partition_key_paths = ["/id"]
}

# ---------------------------------------------------------------------------
# AAD data-plane role assignment (only in "aad" mode).
#
# Grants the web app's managed identity the built-in Cosmos DB Data Contributor
# role, so the app can read and write documents without a key in app settings.
#
# This grant is necessarily created *after* the web app (its principal only
# exists once the app does), so the app's first Cosmos call at cold start can
# briefly 403 before the grant lands. The app tolerates that by retrying a
# startup 403 with backoff - see initContainer in the application repository.
# ---------------------------------------------------------------------------
resource "azurerm_cosmosdb_sql_role_assignment" "app" {
  count               = var.cosmos_auth_mode == "aad" ? 1 : 0
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  role_definition_id  = "${azurerm_cosmosdb_account.main.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = azurerm_linux_web_app.main.identity[0].principal_id
  scope               = azurerm_cosmosdb_account.main.id
}
