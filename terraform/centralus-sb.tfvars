azure_provider_default = {
  tenant_id              = "aa3ba334-375c-4f89-8679-aacd7f308101"
  subscription_id        = "35b62742-ab17-4688-b514-8f1efbd6e1d5"
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

kv = [
  {
    name                       = "kv-fmtest-sb-cus"
    location = "centralus"
    resource_group_name = "rg-fmtest-sb-cus"
    sku                        = "Premium"
    soft_delete_retention_days = 30
    purge_protection_enabled   = false
    bypass                     = "AzureServices"
    default_action             = "Deny"
  }

]


kvsecret = [
  {
    name            = "kvsecret-fmtest-sb-cus"
    value           = "this is the secret for the aca"
    expiration_date = "2024-12-11T00:00:00Z"

  }
]


kvkey = [
  {
    name                 = "kvkey-fmtest-sb-cus"
    key_type             = "RSA"
    key_size             = 2048
    time_before_expiry   = "P30D"
    expire_after         = "P30D"
    notify_before_expiry = "P29D"
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
    location = "centralus"
    resource_group_name = "rg-fmtest-sb-cus"

  }
]

assignment = [
  {
    name                 = "uami-fmtest-sb-cus-01"
    role_definition_name = "acrpull"
  }
]

law = [
  {
    name              = "laws-fmtest-sb-cus"
    location = "centralus"
    resource_group_name = "rg-fmtest-sb-cus"
    sku               = "PerGB2018"
    retention_in_days = 30

  }
]

acaenv = [
  {
    name = "acaenv-fmtest-sb-cus"

  }
]

aca = [
  {
    name          = "aca-fmtest-sb-cus"
    revision_mode = "Multiple"
    template = {
      max_replicas = 3
      min_replicas = 1
      container = {
        name   = "cont-fmtest-sb-cus"
        image  = "acr-fmtest-sb-cus.azurecr.io/repofmtest/fmtestwebapp:latest"
        cpu    = 0.5
        memory = "0.5Gi"
        readiness_probe = {
          transport = "HTTP"
          port : 5000
        }
        liveness_probe = {
          transport = "HTTP"
          port : 5000
        }
      }
      http_scale_rule = {
        name                = "http-scale-rule-fm01"
        concurrent_requests = 10
      }
    }
  }
]