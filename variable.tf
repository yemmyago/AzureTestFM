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