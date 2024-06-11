locals {


  rgs         = { for rg in var.rgs : rg.name => rg }
  acrs        = { for acr in var.acrs : acr.name => acr }
  uamis       = { for uami in var.uamis : uami.name => uami }
  assignments = { for assignment in var.assignments : assignment.name => assignment }
  laws        = { for law in var.laws : law.name => law }

}