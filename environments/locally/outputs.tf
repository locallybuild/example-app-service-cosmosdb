output "application_url" {
  description = "Where to reach the application in a browser."
  value       = module.app-service-cosmosdb.application_url
}

output "cosmos_endpoint" {
  description = "The Cosmos DB account endpoint the application connects to."
  value       = module.app-service-cosmosdb.cosmos_endpoint
}
