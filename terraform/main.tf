resource "azurerm_resource_group" "rg" {
  for_each = local.rgs
  name     = each.key
  location = each.value.location
}

resource "azurerm_user_assigned_identity" "uami" {
  for_each            = local.uamis
  location            = each.value.location
  name                = each.key
  resource_group_name = each.value.resource_group_name

  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_key_vault" "kv" {
  for_each                   = local.kvs
  name                       = each.key
  resource_group_name        = each.value.resource_group_name
  location                   = each.value.location
  tenant_id                  = "aa3ba334-375c-4f89-8679-aacd7f308101"
  sku_name                   = each.value.sku_name
  soft_delete_retention_days = each.value.soft_delete_retention_days
  network_acls {
    bypass         = each.value.bypass
    default_action = each.value.default_action
    
  }
  access_policy {
    tenant_id = "aa3ba334-375c-4f89-8679-aacd7f308101"
    object_id =  azurerm_user_assigned_identity.uami[*].object_id
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
  for_each        = nonsensitive(local.kvsecrets)
  name            = each.key
  value           = each.value.value
  key_vault_id    = azurerm_key_vault.kv[*].id
  expiration_date = each.value.expiration_date
  depends_on = [

    azurerm_key_vault.kv
  ]
}

resource "azurerm_key_vault_key" "kvkey" {
  for_each     = nonsensitive(local.kvkeys)
  name         = each.key
  key_vault_id = azurerm_key_vault.kv[*].id
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
  for_each                      = local.acrs
  name                          = each.key
  resource_group_name        = each.value.resource_group_name
  location                   = each.value.location
  sku                           = each.value.sku
  admin_enabled                 = each.value.admin_enabled
  public_network_access_enabled = each.value.public_network_access_enabled
  anonymous_pull_enabled        = each.value.anonymous_pull_enabled
  network_rule_bypass_option    = each.value.network_rule_bypass_option
  quarantine_policy_enabled     = each.value.quarantine_policy_enabled
  georeplications {
    location                = each.value.georeplications.location
    zone_redundancy_enabled = each.value.georeplications.zone_redundancy_enabled

  }

  network_rule_set {

    default_action = each.value.network_rule_set.default_action
    ip_rule        = each.value.network_rule_set.ip_rule
    
  }
  identity {
    type         = each.value.identity.type
    identity_ids = azurerm_user_assigned_identity.uami[*].id

  }

  encryption {

    key_vault_key_id   = azurerm_key_vault_key.kvkey[*].id
    identity_client_id = azurerm_user_assigned_identity.uami[*].client_id
  }

  trust_policy {
    enabled = each.value.trust_policy.enabled

  }

  retention_policy {

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
  for_each             = local.assignments
  name                 = each.key
  scope                = azurerm_resource_group.rg[*].name
  role_definition_name = each.value.role_definition_name
  principal_id         = azurerm_user_assigned_identity.uami[*].principal_id

  depends_on = [
    azurerm_user_assigned_identity.uami,
    azurerm_resource_group.rg
  ]
}

resource "azurerm_log_analytics_workspace" "law" {
  for_each            = local.laws
  name                = each.key
  resource_group_name        = each.value.resource_group_name
  location                   = each.value.location
  sku                 = each.value.sku
  retention_in_days   = each.value.retention_in_days

  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_container_app_environment" "acaenv" {
  for_each                   = local.acaenvs
  name                       = each.key
  resource_group_name        = each.value.resource_group_name
  location                   = each.value.location                 

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_log_analytics_workspace.law

  ]
}

resource "azurerm_container_app" "aca" {
  for_each                     = local.acas
  name                         = each.key
  container_app_environment_id = azurerm_container_app_environment.acaenv[*].id
  resource_group_name          = each.value.name
  revision_mode                = each.value.revision_mode

  identity {
    type         = "UserAssigned"
    identity_ids = azurerm_user_assigned_identity.uami[*].id
  }

  registry {
    server   = azurerm_container_registry.acr[*].login_server
    identity = azurerm_user_assigned_identity.uami[*].id
  }

  secret {
    name                = azurerm_key_vault_secret.kvsecret[*].name
    identity            = azurerm_user_assigned_identity.uami[*].id
    key_vault_secret_id = azurerm_key_vault_secret.kvsecret[*].id

  }
  template {
    max_replicas = each.value.template.max_replicas
    min_replicas = each.value.template.min_replicas

    container {
      name   = each.value.template.container.name
      image  = each.value.template.container.image
      cpu    = each.value.template.container.cpu
      memory = each.value.template.container.memory

      readiness_probe {
        transport = each.value.template.container.readiness_probe.transport
        port      = each.value.template.container.readiness_probe.port
      }

      liveness_probe {
        transport = each.value.template.container.liveness_probe.transport
        port      = each.value.template.container.liveness_probe.transport
      }
    }
    http_scale_rule {
      name                = each.value.template.http_scale_rule
      concurrent_requests = each.value.template.http_scale_rule.concurrent_requests

    }
  }
}