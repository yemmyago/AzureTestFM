variable "azure_provider_default" {
  description = ""
  type = object({
    subscription_id = string
    tenant_id       = string

  })
  default ={

    tenant_id            = "aa3ba334-375c-4f89-8679-aacd7f308101"
    subscription_id      = "35b62742-ab17-4688-b514-8f1efbd6e1d5"
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}


variable "rgs" {
  description = "name of the resource group"
  default     = {}

}

variable "acrs" {
  description = "info of the container registry"
  default     = {}

}

variable "uamis" {
  description = ""
  default     = {}

}

variable "assignments" {
  description = ""
  default     = {}

}

variable "laws" {
  description = ""
  default     = {}

}

variable "kvs" {
  description = ""
  default     = {}

}

variable "kvsecrets" {
  description = ""
  default     = {}
  sensitive   = true

}

variable "kvkeys" {
  description = ""
  default     = {}
  sensitive   = true

}

variable "acas" {
  description = ""
  default     = {}

}

variable "acaenvs" {
  description = ""
  default     = {}

}

