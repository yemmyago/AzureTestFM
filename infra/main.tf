resource "azurerm_resource_group" "rg" {
  for_each = local.rg
  name     = each.value.name
  location = each.value.location
}

resource "azurerm_user_assigned_identity" "uami" {
  for_each            = local.uami
  location            = azurerm_resource_group.rg.location
  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_key_vault" "kv" {
  for_each                   = local.kv
  name                       = each.value.name
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = each.value.sku_name
  soft_delete_retention_days = each.value.soft_delete_retention_days
  network_acls {
    bypass         = each.value.bypass
    default_action = each.value.default_action
    ip_rule        = each.value.ip_rule

  }
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.uami.object_id
    key_permissions = [
      "Get",
      "List"
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set"
    ]

    storage_permissions = [
      "Get",
      "List"
    ]
  }
  depends_on = [

    azurerm_resource_group.rg,
    azurerm_user_assigned_identity.uami
  ]
}

resource "azurerm_key_vault_secret" "kvsecret" {
  for_each        = local.kvsecret
  name            = each.value.name
  value           = each.value.value
  key_vault_id    = azurerm_key_vault.kv.id
  expiration_date = each.value.expiration_date
  depends_on = [

    azurerm_key_vault.kv
  ]
}

resource "azurerm_key_vault_key" "kvkey" {
  for_each     = local.kvkey
  name         = each.value.name
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = each.value.key_type
  key_size     = each.value.key_size

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

  rotation_policy {
    automatic {
      time_before_expiry = each.value.time_before_expiry
    }

    expire_after         = each.value.expire_after
    notify_before_expiry = each.value.notify_before_expiry
  }

  depends_on = [

    azurerm_key_vault.kv
  ]
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
    type         = each.value.identity.type
    identity_ids = azurerm_user_assigned_identity.uami.id

  }

  encryption = {

    key_vault_key_id   = azurerm_key_vault_key.kvkey.id
    identity_client_id = azurerm_user_assigned_identity.uami.client_id
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
    azurerm_key_vault_key.kvkey,
    azurerm_user_assigned_identity.uami
  ]
}


resource "azurerm_role_assignment" "assignment" {
  for_each             = local.assignment
  name                 = each.value.name
  scope                = azurerm_resource_group.rg
  role_definition_name = each.value.role_definition_name
  principal_id         = azurerm_user_assigned_identity.uami.principal_id

  depends_on = [
    azurerm_user_assigned_identity.uami,
    azurerm_resource_group.rg
  ]
}

resource "azurerm_log_analytics_workspace" "law" {
  for_each            = local.law
  name                = each.value.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = each.value.sku
  retention_in_days   = each.value.retention_in_days

  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_container_app_environment" "acaenv" {
  for_each                   = local.acaenv
  name                       = each.value.name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_log_analytics_workspace.law

  ]
}

resource "azurerm_container_app" "aca" {
  for_each                     = local.aca
  name                         = each.value.name
  container_app_environment_id = azurerm_container_app_environment.acaenv.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = each.value.revision_mode

  identity {
    type         = "UserAssigned"
    identity_ids = azurerm_user_assigned_identity.uami.id
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.uami.id
  }

  secret {
    name                = azurerm_key_vault_secret.kvsecret.name
    identity            = azurerm_user_assigned_identity.uami.id
    key_vault_secret_id = azurerm_key_vault_secret.kvsecret.id

  }
  template = {
    max_replicas = each.value.template.max_replicas
    min_replicas = each.value.template.min_replicas

    container = {
      name   = each.value.template.container.name
      image  = each.value.template.container.image
      cpu    = each.value.template.container.cpu
      memory = each.value.template.container.memory

      readiness_probe = {
        transport = each.value.template.container.readiness_probe.transport
        port      = each.value.template.container.readiness_probe.port
      }

      liveness_probe = {
        transport = each.value.template.container.liveness_probe.transport
        port      = each.value.template.container.liveness_probe.transport
      }
    }
    http_scale_rule = {
      name                = each.value.template.http_scale_rule
      concurrent_requests = each.value.template.http_scale_rule.concurrent_requests

    }
  }
}