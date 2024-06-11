azure_provider_default = {
  tenant_id              = "xxxxxxxx"
  subscription_id        = "xxxxxxxx"
  region                 = "centralus"
  region_alias           = "cus"
  environment_type_alias = "sb"
}

r_groups = [
  {
    name     = "rg-fmtest-sb-cus"
    location = "centralus"
  }
]