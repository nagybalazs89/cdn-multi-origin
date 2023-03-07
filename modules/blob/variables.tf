variable "prefix" {
    description     = ""
    type            = string
    default         = ""
}

variable "resource_group_name" {
    description     = "Name of the resource group which will contain the blob"
    type            = string
    default         = ""
}

variable "resource_group_location" {
    description     = "Location of the resource group which will containe the blob"
    type            = string
    default         = ""
}

variable "storage_accounts" {
    description     = ""
    type            = map(object({
        tier        = string
        replication = string
        container   = string
    }))
    default         = {}
}