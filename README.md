# cdn-multi-origin

## Terraform Multi-Origin CDN with Azure

Terraform Azure Provider ([azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)) does not support Multi-Origin CDN configuration out of the box.

This repo contains code which accomplishes the same behaviour with the combination of ```azurerm``` and the [AzAPI](https://registry.terraform.io/providers/Azure/azapi/latest/docs) provider.

## The following will be created
* resource group
* profile
* endpoint
* give number of origins grouped into congiured origin groups

## .tfvars example

```
    # dev.tfvars

    prefix                          = "dev"
    resource_group_name             = "sol-cdn-resources"
    resource_group_location         = "West Europe"
    profile_sku                     = "Standard_Microsoft"
    endpoint_name                   = "sol-cdn-endpoint"
    profile_name                    = "sol-cdn-profile"
    default_origin                  = {
        name                        = "primary-one"
        host_name                   = "primary.1.default.com"
        enabled                     = true
        http_port                   = 80
        https_port                  = 443
        origin_host_header          = "primary.2.default.com"
        priority                    = 1
        weight                      = 50
    }
    default_origin_group            = "primary"
    origins                         = {
        primary-two                 = {
            host_name               = "primary.2.default.com"
            enabled                 = true
            http_port               = 80
            https_port              = 443
            origin_host_header      = "primary.2.default.com"
            priority                = 2
            weight                  = 50
        }
        west-one                    = {
            host_name               = "west-one.default.com"
            enabled                 = true
            http_port               = 80
            https_port              = 443
            origin_host_header      = "west-one.default.com"
            priority                = 1
            weight                  = 50
        }
        west-two                    = {
            host_name               = "west-two.default.com"
            enabled                 = true
            http_port               = 80
            https_port              = 443
            origin_host_header      = "west-two.default.com"
            priority                = 2
            weight                  = 50
        }
        north-one                   = {
            host_name               = "north-one.default.com"
            enabled                  = true
            http_port               = 80
            https_port              = 443
            origin_host_header      = "west-two.default.com"
            priority                = 1
            weight                  = 99
        }
        north-two                   = {
            host_name               = "north-two.default.com"
            enabled                  = false
            http_port               = 80
            https_port              = 443
            origin_host_header      = "west-two.default.com"
            priority                = 2
            weight                  = 1
        }
        east-one                    = {
            host_name               = "east-one.default.com"
            enabled                  = true
            http_port               = 80
            https_port              = 443
            origin_host_header      = "west-two.default.com"
            priority                = 1
            weight                  = 100
        }
    }
    origin_groups           = {
        primary             = [
            "primary-two"
        ]
        west                = [
            "west-one",
            "west-two"
        ]
        north               = [
            "north-one",
            "north-two"
        ]
        east                = [
            "east-one"
        ]
    }
```

## TBD
* Refactor (e.g. more friendly input variables)
* Expose more config to module level (e.g. settings for origin groups)