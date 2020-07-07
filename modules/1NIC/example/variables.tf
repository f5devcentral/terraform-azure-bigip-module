variable location {
  description = "Resource Group Location"
  type        = string
}

variable "prefix" {
  description = "Prefix for resources created by this module"
  type        = string
  default     = "terraform-azure-bigip-1nic"
}
