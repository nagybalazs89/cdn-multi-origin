resource "azurerm_resource_group" "this" {
  name                    = "${var.prefix}${var.resource_group_name}"
  location                = var.resource_group_location
}

resource "azurerm_cdn_profile" "this" {
    name                  = "${var.prefix}${var.profile_name}"
    location              = azurerm_resource_group.this.location
    resource_group_name   = azurerm_resource_group.this.name
    sku                   = var.profile_sku       
}

resource "azurerm_cdn_endpoint" "this" {
    name                  = "${var.prefix}${var.endpoint_name}"
    profile_name          = azurerm_cdn_profile.this.name
    location              = azurerm_resource_group.this.location
    resource_group_name   = azurerm_resource_group.this.name

    origin {
      name                = var.default_origin.name
      host_name           = var.default_origin.host_name
    }
}

# Get the Id of the default origin (created by azurerm_cdn_endpoint.this by the origin block)
data "azapi_resource" "default_origin" {
  name                    = var.default_origin.name
  parent_id               = azurerm_cdn_endpoint.this.id
  type                    = "Microsoft.Cdn/profiles/endpoints/origins@2022-11-01-preview"

  response_export_values  = ["id"]
  depends_on              = [azurerm_cdn_endpoint.this]
}

# Create an origin group
resource "azapi_resource_action" "default_origin_group" {
  type                    = "Microsoft.Cdn/profiles/endpoints/originGroups@2022-11-01-preview"
  resource_id             = "${azurerm_cdn_endpoint.this.id}/originGroups/${var.default_origin_group}"
  method                  = "PUT"
  body = jsonencode({
    properties = {
      origins = [{
        id = "${jsondecode(data.azapi_resource.default_origin.output).id}"
      }]
    }
  })
}

# Register the previously created origin group as a default
resource "azapi_resource_action" "add_default_origin_group" {
  type                    = "Microsoft.Cdn/profiles/endpoints@2022-11-01-preview"
  resource_id             = "${azurerm_cdn_endpoint.this.id}"
  method                  = "PATCH"
  body = jsonencode({
    properties = {
      defaultOriginGroup = {
        id  = azapi_resource_action.symbolicname.id
      }
    }
  })
}

# Create all the origins on endpoint level (default group required to succeed)
resource "azapi_resource_action" "origins" {
  for_each                = var.origins
  type                    = "Microsoft.Cdn/profiles/endpoints/origins@2022-11-01-preview"
  resource_id             = "${azurerm_cdn_endpoint.this.id}/origins/${each.key}"
  method                  = "PUT"
  body = jsonencode({
    properties = {
      hostName = each.value.host_name
      enabled = each.value.enabled
      httpPort = each.value.http_port
      httpsPort = each.value.https_port
      originHostHeader = each.value.origin_host_header
      priority = each.value.priority
      weight = each.value.weight
    }
  })
  depends_on = [ azapi_resource_action.add_default_origin_group ]
}

# Get all the previously created origins
data "azapi_resource_action" "all_origins" {
  type                    = "Microsoft.Cdn/profiles/endpoints@2022-11-01-preview"
  resource_id             = azurerm_cdn_endpoint.this.id
  method                  = "GET"
  action                  = "origins"
  response_export_values  = ["*"]
  depends_on              = [ azapi_resource_action.origins ]
}

# Create origin groups and add the origins by the configuration
resource "azapi_resource_action" "non_def_groups" {
  for_each                = {
    for k, v in var.origin_groups : k => v
    if k != var.default_origin_group
  }
  type                    = "Microsoft.Cdn/profiles/endpoints/originGroups@2022-11-01-preview"
  resource_id             = "${azurerm_cdn_endpoint.this.id}/originGroups/${each.key}"
  method                  = "PUT"
  body = jsonencode({
    properties = {
      origins = [for instance in jsondecode(data.azapi_resource_action.all_origins.output).value : { id = instance.id } if contains(each.value, instance.name)]
    }
  })
  depends_on = [
    data.azapi_resource_action.all_origins
  ]
}

# Update the already existing default origin group with the configured origins
resource "azapi_resource_action" "def_groups" {
  for_each                = {
    for k, v in var.origin_groups : k => v
    if k == var.default_origin_group
  }
  type                    = "Microsoft.Cdn/profiles/endpoints/originGroups@2022-11-01-preview"
  resource_id             = "${azurerm_cdn_endpoint.this.id}/originGroups/${each.key}"
  method                  = "PATCH"
  body = jsonencode({
    properties = {
      origins = concat([{ id = data.azapi_resource.default_origin.id }], [for instance in jsondecode(data.azapi_resource_action.all_origins.output).value : { id = instance.id } if contains(each.value, instance.name)])
    }
  })
  depends_on = [ data.azapi_resource_action.all_origins ]
}