output "object_id" {
value = azurerm_user_assigned_identity.uami[*].object_id
}

output "principal_id" {
value = azurerm_user_assigned_identity.uami[*].principal_id
}

output "law_id" {
value = azurerm_log_analytics_workspace.law[*].id
}

output "kv_id" {
value = azurerm_key_vault.kv[*].id
}

output "rg_name" {
value = azurerm_resource_group.rg[*].name
}

output "acaenv_id" {
value = azurerm_container_app_environment.acaenv[*].id
}

output "kvsecret_name" {
value = azurerm_key_vault_secret.kvsecret[*].name
}

output "kvsecret_id" {
value = azurerm_key_vault_secret.kvsecret[*].id
}

output "kvkey_id" {
value = azurerm_key_vault_key.kvkey[*].id
}

output "client_id" {
value = azurerm_user_assigned_identity.uami[*].client_id
}