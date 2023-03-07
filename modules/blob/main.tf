resource "azurerm_resource_group" "this" {
  name                          = "${var.prefix}${var.resource_group_name}"
  location                      = var.resource_group_location
}

resource "azurerm_storage_account" "this" {
    for_each                    = var.storage_accounts
    name                        = "${var.prefix}${each.key}"
    resource_group_name         = azurerm_resource_group.this.name
    location                    = azurerm_resource_group.this.location
    account_tier                = each.value.tier
    account_replication_type    = each.value.replication
}

resource "azurerm_storage_container" "this" {
    for_each                    = var.storage_accounts
    name                        = "${var.prefix}-${each.key}-${each.value.container}"
    storage_account_name        = azurerm_storage_account.this[each.key].name
    container_access_type       = "container"
}