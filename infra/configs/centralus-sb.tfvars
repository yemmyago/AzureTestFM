azure_provider_default = {
  tenant_id              = "xxxxxxxx"
  subscription_id        = "xxxxxxxx"
  region                 = "centralus"
  region_alias           = "cus"
  environment_type_alias = "sb"
}

rg = [
  {
    name     = "rg-fmtest-sb-cus"
    location = "centralus"
  }
]

acr = [
  {

    name                          = "acr-fmtest-sb-cus"
    sku                           = "Premium"
    admin_enabled                 = false
    public_network_access_enabled = false
    anonymous_pull_enabled        = false
    network_rule_bypass_option    = "AzureServices"
    quarantine_policy_enabled     = true

    georeplications = {
      location                = "eastus2"
      zone_redundancy_enabled = true
    }

    network_rule_set = {

      default_action = "Deny"
    }

    identity = {
      type = "UserAssigned"
    }

    trust_policy = {
      enabled = true

    }

    retention_policy = {

      days    = 30
      enabled = true
    }

  }

]

uami = [
  {
    name = "uami-fmtest-sb-cus"

  }
]

assignment = [
  {
    role_definition_name = "acrpull"
  }
]