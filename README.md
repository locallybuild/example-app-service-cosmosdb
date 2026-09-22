# Example: Deploy a Cosmos DB-backed app to App Service within Locally

This example shows how to deploy [a sample 12-factor Tasks app - `tombuildsstuff/app-service-cosmosdb`](https://hub.docker.com/r/tombuildsstuff/app-service-cosmosdb) to App Service, backed by Cosmos DB, on [Locally Build](https://locally.build).

The application is a minimal CRUD Tasks app. It's a plain [12-factor](https://12factor.net) service: one image, configured entirely through environment variables, connecting to Cosmos DB for storage. The image is built and published from [the application repository](https://github.com/tombuildsstuff/app-service-cosmosdb); this repository is just the infrastructure that runs it.

The app authenticates to Cosmos using its **managed identity** (`cosmos_auth_mode = "aad"`), so no key is stored in app settings. Locally supports managed identity the same way Azure does, so the identical wiring works locally and in the cloud.

## How this differs from the other App Service examples

The other App Service examples in this repo import their image into a Locally Container Registry and pull it from there, mirroring how you'd host a *private* image on Azure. This example keeps things minimal: the image is public, so **App Service pulls it directly from Docker Hub** - there's no Container Registry to provision or import into, and no `Microsoft.ContainerRegistry` plugin to install.

## Requirements

* [Locally Build](https://locally.build).
* Either [HashiCorp Terraform](https://terraform.io) or [OpenTofu](https://opentofu.org).
* Either [Docker](https://www.docker.com) or [Podman](https://podman.io) (recommended).
* The Locally Plugin for `Microsoft.DocumentDB` installed (`locally plugin install --name Microsoft.DocumentDB`).
* The Locally Plugin for `Microsoft.Web` installed (`locally plugin install --name Microsoft.Web`).

## Running the example

First up, we need to ensure our container runtime (Docker or Podman) is running, then launch Locally:

```bash
locally build
```

With Locally running, in another terminal we can initialise Terraform, which both downloads the providers we need and configures the module for use:

```bash
cd environments/locally
terraform init
```

> [!NOTE]
> It's possible to use OpenTofu here by substituting `terraform` for `tofu`.

With Terraform initialised, we can then provision the example by running:

```bash
locally run terraform apply
```

Once you approve the plan and the resources have been deployed, the application is running at the URL in the outputs:

```
https://locally-example-cosmosdb-app.furnace.locally:5663
```

[Open that URL in a browser](https://locally-example-cosmosdb-app.furnace.locally:5663) and you'll be able to add, complete, and delete tasks; each one is stored as a document in Cosmos DB.

---

As this Terraform configuration sends the App Service logs into a Log Analytics Workspace, we can then query them within [the Locally Dashboard, in the Monitoring section](https://localhost:5678/monitoring/components), by running:

```
AppServiceConsoleLogs | order by TimeGenerated desc
```

## Tearing it down

```bash
cd environments/locally
locally run terraform destroy
```
