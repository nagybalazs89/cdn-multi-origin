variable "prefix" {
    description             = "Prefix of resources"
    type                    = string
    default                 = ""
}

variable "resource_group_name" {
    description             = "Name of the resource group"
    type                    = string
    default                 = "" 
}

variable "profile_sku" {
    description             = "SKU of the profile"
    type                    = string
    default                 = "" 
}

variable "endpoint_name" {
    description             = "Name of the endpoint"
    type                    = string
    default                 = "" 
}

variable "profile_name" {
    description             = "Name of the CDN profile"
    type                    = string
    default                 = ""
}

variable "resource_group_location" {
    description             = "Location of the resource group"
    type                    = string
    default                 = "" 
}

variable "default_origin" {
    description             = "Name and host name of the default origin"
    type                    = object({
        name                = string
        host_name           = string
        enabled             = bool
        http_port           = number
        https_port          = number
        origin_host_header  = string
        priority            = number
        weight              = number
    })
}

variable "default_origin_group" {
    description             = "Name of the default origin group"
    type                    = string
    default                 = ""
}

variable "origins" {
    description             = "List of origins"
    type                    = map(object({
        host_name           = string
        enabled             = bool
        http_port           = number
        https_port          = number
        origin_host_header  = string
        priority            = number
        weight              = number
    }))
    default                 = {}
}

variable "origin_groups" {
    description             = "List of origin groups"
    type                    = map(list(string))
    default                 = {}
}