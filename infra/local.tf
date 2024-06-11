locals {


  rgs  = { for rg in var.rgs : rg.name => rg }
  acrs = { for acr in var.acrs : acr.name => acr }
}