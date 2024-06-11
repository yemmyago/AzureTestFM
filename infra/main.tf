resource "azurerm_resource_group" "rg" {
  for_each = local.rg
  name     = each.value.name
  location = each.value.location
}


data "azurerm_key_vault_key" "kv" {
  name         = "super-secret"
  key_vault_id = data.azurerm_key_vault.existing.id
}


resource "azurerm_container_registry" "acr" {
  for_each                      = local.acr
  name                          = each.value.name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  sku                           = each.value.sku
  admin_enabled                 = each.value.admin_enabled
  public_network_access_enabled = each.value.public_network_access_enabled
  anonymous_pull_enabled        = each.value.anonymous_pull_enabled
  network_rule_bypass_option    = each.value.network_rule_bypass_option
  quarantine_policy_enabled     = each.value.quarantine_policy_enabled
  georeplications = {
    location                = each.value.georeplications.location
    zone_redundancy_enabled = each.value.georeplications.zone_redundancy_enabled

  }

  network_rule_set = {

    default_action = try(each.value.network_rule_set.default_action, [])
    ip_rule        = concat(try(each.value.network_rule_set.ip_rule, []))
    subnet_ids     = try(each.value.network_rule_set.subnet_ids, [])
  }
  identity = {
    type = each.value.identity.type
  }

  encryption = {

    key_vault_key_id   = data.azurerm_key_vault_key.kv.id
    identity_client_id = azurerm_user_assigned_identity.kv.client_id
  }

  trust_policy = {
    enabled = each.value.trust_policy.enabled

  }

  retention_policy = {

    days    = each.value.retention_policy.days
    enabled = each.value.retention_policy.enabled
  }

  depends_on = [
    azurerm_resource_group.rg,
    data.azurerm_key_vault_key.kv
  ]
}