variable "name" {
  description = "(Required) Specifies the name of the Logic Application"
  type        = string
  default     = "p-mod-vm"
}

variable "resourceGroupName" {
  description = "(Required) Specifies the name of the resource group"
  type        = string
  default     = "p-mod-vm"
}

variable "location" {
  description = "(Optional) Specifies the location of the Logic Application"
  type        = string
  default     = "westeurope"
}

variable "tags" {
  description = "(Optional) Specifies the tags of the Logic Application"
  type        = map(any)
  default = {
    Environment   = "dev"
    ManagedBy     = "terraform"
    Repo          = "terraform-module-virtual-machine"
    Configuration = "2022-08-02-1208"
  }
}
