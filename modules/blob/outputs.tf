# output "hosts" {
#     value = values(azurerm_storage_account.this).*.primary_blob_host
# }

output "hosts" {
    value = {
        for k, x in azurerm_storage_account.this : k => x.primary_blob_host
    }
}