resource "azurerm_resource_group" "rg" {
  for_each = local.r_groups
  name     = each.value.name
  location = each.value.location
}

