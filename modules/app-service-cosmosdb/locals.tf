locals {
  # The application image, pulled directly from Docker Hub. A multi-arch build
  # carrying both linux/amd64 (Azure App Service) and linux/arm64 (Apple
  # Silicon), so it runs on Locally and on Azure alike. It's published from the
  # application repository, tombuildsstuff/app-service-cosmosdb.
  image_name = "tombuildsstuff/app-service-cosmosdb:latest"

  # The App Service name, used both as the resource name and to compose the
  # public URL.
  web_app_name = "${var.name_prefix}-app"

  # The port the container listens on inside App Service (the app's PORT, exposed
  # to App Service as WEBSITES_PORT). App Service terminates TLS at the platform
  # and routes public traffic to the container on this port.
  app_port = 3000
}
