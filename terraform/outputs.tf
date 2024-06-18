output "uami_principal_id" {

    value       = [for i in azurerm_user_assigned_identity.uami: flatten(i.*.principal_id)]
}