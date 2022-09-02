variable resource_group_name {
  description = "(Required) Specifies the resource group name of the virtual machine"
  type = string
}

variable name {
  description = "Override standard resource name / governance naming standard."
  type = string
  default = null
}

variable numberOfInstances {
  description = "Number of Virtual Machines to deploy."
  type = number
  default = 1
}

variable "deployVMSS" {
  description = "Deploy as a VM Scale Set"
  type = bool
  default = false
}

variable vmRole {
  type = string
  default = "vm"
      
        description = "The Virtual Machine(s) role. e.g. dc for Domain Controller."
      }

variable size {
  description = "(Required) Specifies the size of the virtual machine"
  type = string
  default = "Standard_DS1_v2"
}

variable "os_disk_image" {
  type        = map(string)
  description = "(Optional) Specifies the os disk image of the virtual machine"
  default     = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS" 
    version   = "latest"
  }
}

variable "os_disk_storage_account_type" {
  description = "(Optional) Specifies the storage account type of the os disk of the virtual machine"
  default     = "StandardSSD_LRS"
  type        = string

  validation {
    condition = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS",  "Standard_LRS"], var.os_disk_storage_account_type)
    error_message = "The storage account type of the OS disk is invalid."
  }
}

variable public_ip {
  description = "(Optional) Specifies whether create a public IP for the virtual machine"
  type = bool
  default = false
}

variable location {
  description = "(Required) Specifies the location of the virtual machine"
  type = string
}

variable domain_name_label {
  description = "(Required) Specifies the DNS domain name of the virtual machine"
  type = string
}

variable subnet_id {
  description = "(Required) Specifies the resource id of the subnet hosting the virtual machine"
  type        = string
}



variable "boot_diagnostics_storage_account" {
  description = "(Optional) The Primary/Secondary Endpoint for the Azure Storage Account (general purpose) which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor."
  default     = null
}

variable "tags" {
  description = "(Optional) Specifies the tags of the storage account"
  default     = {}
}

# variable "log_analytics_workspace_id" {
#   description = "Specifies the log analytics workspace id"
#   type        = string
# }

# variable "log_analytics_workspace_key" {
#   description = "Specifies the log analytics workspace key"
#   type        = string
# }

variable "log_analytics_workspace_resource_id" {
  description = "Specifies the log analytics workspace resource id"
  type        = string
  default = null
}


variable "log_analytics_retention_days" {
  description = "Specifies the number of days of the retention policy"
  type        = number
  default     = 7
}

variable "admin_ssh_public_key" {
  description = "Specifies the public SSH key"
  type        = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDpTPg902uyF9QmsTxvFwNpWaIQhrm8nWE3H1sumL0MXOP2fa8Ld+d8fJUunHHyXFLqxUuGYeYTcQTt5Uez5iRTF88zngbltgHr7LABBVwZQR0MVZUL4lLqLrx4b0HJFThf4NaAk7ZpQt70Qe/3ljBt55Tzhiz3py2Tr2vx0JIqsRR91t4NUHztqCWl5ZzGc2hb7ZEz80y+F4emYfWBBDY2HjgMWBIk8ZEsiW58Nf5akmCDYBdAE5XPaCZVnMOaiXM+jQH62JzRlmBDQ0yDPcVU05qqz0XKOotY1RZfwx8jztuBVp5CUOF4sKhJtInZnHuQSGIWPJZqSjLmhGrtXCOI+U/LmKS3fb00EIpM6PWWQwJcy8fLP3DaNR7FjRCFEfGxYu/pQczq7ihUXwJ5kVZaEB62dgs7oSIi5kgt+YxXAv3jjoauBG/DHgrZTmuf4TscLHsjA+p2Koux+8WdbjbYUy5OdDlCjggQLzal/70o/OLs/EPDxECi2c88RwUDPH7/KtVqJ46QHB5xuN0MgWO1h4kLilOkZ1B1YyPjDufKW96b27PjkFMmV1dq5wM+ybvL2kTNONL5svZUpQWAhtQMNy0DSnmbCM5jCzN60kiDg5CQzYNZSjeXZiamTsMMfzUmPcMSz0PfOAgmgYEdVWBKCIQVDsH9ua7oiP+MpdzxzQ== root@172.16.1.70"
}

variable vm_user {
  description = "(Required) Specifies the username of the virtual machine"
  type        = string
  default     = "azureuser"
}
# variable "script_storage_account_name" {
#   description = "(Required) Specifies the name of the storage account that contains the custom script."
#   type        = string
# }

# variable "script_storage_account_key" {
#   description = "(Required) Specifies the name of the storage account that contains the custom script."
#   type        = string
# }

# variable "container_name" {
#   description = "(Required) Specifies the name of the container that contains the custom script."
#   type        = string
# }

# variable "script_name" {
#   description = "(Required) Specifies the name of the custom script."
#   type        = string
# }