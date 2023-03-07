variable "default_origin" {
  description = ""
  type = object({
    name = string
    host_name = string
  })
  default = {
    name = "default"
    host_name = "default.com"
  }
}

variable "default_origin_group" {
  description = ""
  type = string
  default = "defaultOriginGroup"
}

variable "origins" {
  default = {
    originone = "origin1.com"
    origintwo = "origin2.com"
    originthr = "origin3.com"
    originfou = "origin4.com"
    originfiv = "origin5.com"
  }
}

variable "origin_groups" {
  default = { originGroupZero = [
    "originone",
    "origintwo"
  ]
  originGroupOne = [
    "originthr",
    "originfou"
  ]
  originGroupTwo = [
    "originfiv"
  ]}
}

resource "azurerm_resource_group" "this" {
  name                  = "solResourceGroup"
  location              = "West Europe"
}

resource "azurerm_cdn_profile" "this" {
    name                = "solProfile"
    location            = azurerm_resource_group.this.location
    resource_group_name = azurerm_resource_group.this.name
    sku                 = "Standard_Microsoft"        
}

resource "azurerm_cdn_endpoint" "this" {
    name                = "solEndpoint"
    profile_name        = azurerm_cdn_profile.this.name
    location            = azurerm_resource_group.this.location
    resource_group_name = azurerm_resource_group.this.name

    origin {
      name              = var.default_origin.name
      host_name         = var.default_origin.host_name
    }
}

data "azapi_resource" "default_origin" {
  name      = var.default_origin.name
  parent_id = azurerm_cdn_endpoint.this.id
  type      = "Microsoft.Cdn/profiles/endpoints/origins@2022-11-01-preview"

  response_export_values = ["id"]
  depends_on = [azurerm_cdn_endpoint.this]
}

resource "azapi_resource_action" "symbolicname" {
  type = "Microsoft.Cdn/profiles/endpoints/originGroups@2022-11-01-preview"
  resource_id = "${azurerm_cdn_endpoint.this.id}/originGroups/${var.default_origin_group}"
  method = "PUT"
  body = jsonencode({
    properties = {
      origins = [{
        id = "${jsondecode(data.azapi_resource.default_origin.output).id}"
      }]
    }
  })
}

resource "azapi_resource_action" "add_default_origin_group" {
  type = "Microsoft.Cdn/profiles/endpoints@2022-11-01-preview"
  resource_id = "${azurerm_cdn_endpoint.this.id}"
  method = "PATCH"
  body = jsonencode({
    properties = {
      defaultOriginGroup = {
        id = azapi_resource_action.symbolicname.id
      }
    }
  })
}

resource "azapi_resource_action" "origins" {
  for_each = var.origins
  type = "Microsoft.Cdn/profiles/endpoints/origins@2022-11-01-preview"
  resource_id = "${azurerm_cdn_endpoint.this.id}/origins/${each.key}"
  method = "PUT"
  body = jsonencode({
    properties = {
      hostName = each.value
    }
  })
  depends_on = [
    azapi_resource_action.add_default_origin_group
  ]
}

data "azapi_resource_action" "all_origins" {
  type = "Microsoft.Cdn/profiles/endpoints@2022-11-01-preview"
  resource_id = azurerm_cdn_endpoint.this.id
  method = "GET"
  action = "origins"
  response_export_values = ["*"]
  depends_on = [
    azapi_resource_action.origins
  ]
}

# data "azapi_resource" "all_origins" {
#   for_each  = var.origins
#   name      = each.key
#   parent_id = azurerm_cdn_endpoint.this.id
#   type      = "Microsoft.Cdn/profiles/endpoints/origins@2022-11-01-preview"

#   response_export_values = ["id", "name"]
#   depends_on = [azapi_resource_action.origins]
# }

resource "azapi_resource_action" "non_def_groups" {
  for_each = var.origin_groups
  type = "Microsoft.Cdn/profiles/endpoints/originGroups@2022-11-01-preview"
  resource_id = "${azurerm_cdn_endpoint.this.id}/originGroups/${each.key}"
  method = "PUT"
  body = jsonencode({
    properties = {
      origins = [for instance in jsondecode(data.azapi_resource_action.all_origins.output).value : { id = instance.id } if contains(each.value, instance.name)]
    }
  })
  depends_on = [
    data.azapi_resource_action.all_origins
  ]
}

# output "hosts" {
#     value = [for instance in data.azapi_resource.all_origins : instance.id]
# }