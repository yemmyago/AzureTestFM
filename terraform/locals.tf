locals {
  rgs         = { for rg in var.rgs : rg.name => rg }
  acrs        = { for acr in var.acrs : acr.name => acr }
  uamis       = { for uami in var.uamis : uami.name => uami }
  assignments = { for assignment in var.assignments : assignment.name => assignment }
  laws        = { for law in var.laws : law.name => law }
  kvs         = { for kv in var.kvs : kv.name => kv }
  kvsecrets   = { for kvsecret in var.kvsecrets : kvsecret.name => kvsecret }
  kvkeys      = { for kvkey in var.kvkeys : kvkey.name => kvkey }
  acas        = { for aca in var.acas : aca.name => aca }
  acaenvs     = { for acaenv in var.acaenvs : acaenv.name => acaenv }
}