module "multi_origin_cdn" {
  source                  = "./module/multi_origin_cdn"
  prefix                  = var.prefix
  default_origin          = var.default_origin
  default_origin_group    = var.default_origin_group
  endpoint_name           = var.endpoint_name
  origin_groups           = var.origin_groups
  origins                 = var.origins
  profile_name            = var.profile_name
  profile_sku             = var.profile_sku
  resource_group_location = var.resource_group_location
  resource_group_name     = var.resource_group_name 
}