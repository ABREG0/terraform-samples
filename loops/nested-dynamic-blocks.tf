# nested dynamic blocks: https://stackoverflow.com/questions/62221306/terraform-nested-dynamic-block-with-nested-map
# azure container group deployment 
# sample of nested dynamic block loop from list object map and list objects. 

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

variable "container" {
  type = list(object({
    name   = string
    image  = string
    cpu    = string
    memory = string
    ports = list(object(
      {
        port     = string
        protocol = string
      }
    ))
  }))

  default = [
    {
      name   = "grafana"
      image  = "grafana/grafana:latest"
      cpu    = "0.5"
      memory = "0.5"
      ports = [{
        port     = null 
        protocol = null
        }
      ]
    },
    {
      name   = "traefik"
      image  = "traefik:latest"
      cpu    = "0.5"
      memory = "0.5"
      ports = [
        {
          port     = 80
          protocol = "TCP"
        },
        {
          port     = 443
          protocol = "TCP"
        },
        {
          port     = 8080
          protocol = "TCP"
        }
      ]
    }
  ]
}

resource "azurerm_container_group" "cg" {
  name                = "container-1"
  location            = "westus2"
  resource_group_name = "containter-rg"
  os_type             = "Linux"
  restart_policy      = "Always"
  exposed_port = [{
    port     = 3000
    protocol = "TCP"
  }]


  dynamic "container" {
    for_each = var.container

    content {
      name   = container.value["name"]
      image  = container.value["image"]
      cpu    = container.value["cpu"]
      memory = container.value["memory"]

      dynamic "ports" {
        for_each = container.value.ports

        content {
          port     = ports.value.port 
          protocol = ports.value.protocol
        }
      }
    }
  }

}
