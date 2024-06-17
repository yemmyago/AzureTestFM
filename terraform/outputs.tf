output "object_id" {
values (azurerm_user_assigned_identity.uami)[“*”].object_id
}

output "principal_id" {
values (azurerm_user_assigned_identity.uami)[“*”].principal_id
}

output "law_id" {
values (azurerm_log_analytics_workspace.law)[“*”].id
}

output "kv_id" {
values (azurerm_key_vault.kv)[“*”].id
}

output "rg_name" {
values (azurerm_resource_group.rg)[“*”].name
}

output "acaenv_id" {
values (azurerm_container_app_environment.acaenv)[“*”].id
}

output "kvsecret_name" {
values (azurerm_key_vault_secret.kvsecret)[“*”].name
}

output "kvsecret_id" {
values (azurerm_key_vault_secret.kvsecret)[“*”].id
}

output "kvkey_id" {
values (azurerm_key_vault_key.kvkey)[“*”].id
}

output "client_id" {
values (azurerm_user_assigned_identity.uami)[“*”].client_id
}