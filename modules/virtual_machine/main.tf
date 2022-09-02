terraform {
  # This module is now only being tested with Terraform 1.1.x.
  required_version = ">= 1.1.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.98.0"
    }
  }
}


locals {
  module_tag = {
    "module_name"    = basename(abspath(path.module))
    "module_version" = "0.0.1"
  }
  tags = merge(var.tags, local.module_tag)
}


# Log Analytics Workspace Information
locals {
  log_analytics_sub            = try(element(split("/", var.log_analytics_workspace_resource_id), 2), null)
  log_analytics_rg             = try(element(split("/", var.log_analytics_workspace_resource_id), 4), null)
  log_analytics_name           = try(element(split("/", var.log_analytics_workspace_resource_id), 8), null)
  log_analytics_workspace_id   = try(data.azurerm_log_analytics_workspace.logging[1].workspace_id, null)
  log_analytics_workspace_key  = try(data.azurerm_log_analytics_workspace.logging[1].primary_shared_key, null)
  log_analytics_retention_days = try(data.azurerm_log_analytics_workspace.logging[1].retention_in_days, null)
}

# Governance - Naming Standards
locals {
  suffixAvailabilitySet = "as"
  suffixLoadbalancer    = "lb"
  suffixASG             = "asg"
  suffixNSG             = "nsg"
  suffixNIC             = "nic00"
  suffixOSdisk          = "osdisk"
  suffixDatadisk        = "datadisk"
  suffixPublicIP        = "pip"
  vmNamePrefixString    = length(split("-", var.resource_group_name)) >= 3 ? "${var.resource_group_name}-${var.vmRole}" : "${regexall("(.*-)", var.resource_group_name)[0]}${var.vmRole}"
  vmNamePrefix          = var.name == null ? local.vmNamePrefixString : var.name

  availabilitySetName = "${local.vmNamePrefix}-${local.suffixAvailabilitySet}"
  lbName              = "${local.vmNamePrefix}-{$local.suffixAvailabilitySet}"

  storageAccountPrefix = "${replace(local.vmNamePrefix, "-", "")}diag"

  uniqueString             = resource.random_string.uniqueString.id
  vmDiagStorageAccountName = lower(substr(replace("${local.storageAccountPrefix}${local.uniqueString}", "-", ""), 0, 23))
}

# Logic - Regions with Availability Zones
locals {
  regions_with_availability_zones = ["centralus", "eastus2", "eastus", "westus", "westeurope"]
  # zones = contains(local.regions_with_availability_zones, resource.azurerm_resource_group.vm_rg.location) ? list("1","2","3") : null
  zones = 0
}

# Logic - Windows or Linux VM
locals {
  # Logic is not defind yet
  isWindowsOS = false
}


# ---------------------------------------------------------------------------------------------------------------------
# Module Payload
#

data "azurerm_log_analytics_workspace" "logging" {
  count               = var.log_analytics_workspace_resource_id != null ? 1 : 0
  name                = local.log_analytics_name
  resource_group_name = local.log_analytics_rg
  provider            = azurerm
}


resource "random_string" "uniqueString" {
  length  = 16
  special = false
}

resource "azurerm_resource_group" "vm_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

# Availability Set
resource "azurerm_availability_set" "vm_set" {
  count = var.deployVMSS != true && local.zones == 0 ? 1 : 0

  name                         = local.availabilitySetName
  location                     = resource.azurerm_resource_group.vm_rg.location
  resource_group_name          = resource.azurerm_resource_group.vm_rg.name
  tags                         = local.tags
  platform_update_domain_count = 2
  platform_fault_domain_count  = 2
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${local.vmNamePrefix}-${local.suffixPublicIP}"
  location            = resource.azurerm_resource_group.vm_rg.location
  resource_group_name = resource.azurerm_resource_group.vm_rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = lower(var.domain_name_label)
  count               = var.public_ip ? 1 : 0
  tags                = local.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# resource "azurerm_network_security_group" "nsg" {
#   name                = "${local.vmNamePrefix}-${local.suffixNSG}"
#   location            = resource.azurerm_resource_group.vm_rg.location
#   resource_group_name = resource.azurerm_resource_group.vm_rg.name
#   tags                = local.tags

#   security_rule {
#     name                       = "SSH"
#     priority                   = 1001
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }

#   lifecycle {
#     ignore_changes = [
#         tags
#     ]
#   }
# }

resource "azurerm_network_interface" "nic" {
  # If we are not Deploying VMSS, we will require NICs pre-provisioned for us
  count               = var.deployVMSS == false ? var.numberOfInstances : 0
  name                = "${local.vmNamePrefix}${format("%02d", count.index)}-${local.suffixNIC}"
  location            = resource.azurerm_resource_group.vm_rg.location
  resource_group_name = resource.azurerm_resource_group.vm_rg.name
  tags                = local.tags

  ip_configuration {
    name                          = "Configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = try(azurerm_public_ip.public_ip[0].id, "")
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# resource "azurerm_network_interface_security_group_association" "nsg_association" {
#   count = var.numberOfInstances
#   network_interface_id      = azurerm_network_interface.nic[count.index].id
#   network_security_group_id = azurerm_network_security_group.nsg.id
#   depends_on = [azurerm_network_security_group.nsg]
# }

resource "azurerm_linux_virtual_machine_scale_set" "virtual_machine_scale_set" {
  count               = var.deployVMSS ? 1 : 0
  name                = local.vmNamePrefix
  location            = resource.azurerm_resource_group.vm_rg.location
  resource_group_name = resource.azurerm_resource_group.vm_rg.name
  instances           = var.numberOfInstances
  admin_username      = var.vm_user
  sku                 = var.size

  admin_ssh_key {
    username   = var.vm_user
    public_key = var.admin_ssh_public_key # file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    offer     = lookup(var.os_disk_image, "offer", null)
    publisher = lookup(var.os_disk_image, "publisher", null)
    sku       = lookup(var.os_disk_image, "sku", null)
    version   = lookup(var.os_disk_image, "version", null)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }

  network_interface {
    name    = "${local.vmNamePrefix}-${local.suffixNIC}"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id
    }
  }
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  count                 = var.deployVMSS ? 0 : var.numberOfInstances
  name                  = "${local.vmNamePrefix}${format("%02d", count.index)}"
  location              = resource.azurerm_resource_group.vm_rg.location
  resource_group_name   = resource.azurerm_resource_group.vm_rg.name
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  size                  = var.size
  computer_name         = var.name
  admin_username        = var.vm_user
  tags                  = local.tags
  availability_set_id   = local.zones == 0 ? resource.azurerm_availability_set.vm_set[0].id : null
  # zones                         = local.zones

  os_disk {
    name                 = "${local.vmNamePrefix}${format("%02d", count.index)}-${local.suffixOSdisk}"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }

  admin_ssh_key {
    username   = var.vm_user
    public_key = var.admin_ssh_public_key
  }

  source_image_reference {
    offer     = lookup(var.os_disk_image, "offer", null)
    publisher = lookup(var.os_disk_image, "publisher", null)
    sku       = lookup(var.os_disk_image, "sku", null)
    version   = lookup(var.os_disk_image, "version", null)
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account == "" ? null : var.boot_diagnostics_storage_account
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  depends_on = [
    azurerm_network_interface.nic,
    # azurerm_network_security_group.nsg
  ]
}

# # resource "azurerm_virtual_machine_extension" "custom_script" {
# #   name                    = "${var.name}CustomScript"
# #   virtual_machine_id      = azurerm_linux_virtual_machine.virtual_machine.id
# #   publisher               = "Microsoft.Azure.Extensions"
# #   type                    = "CustomScript"
# #   type_handler_version    = "2.0"

# #   settings = <<SETTINGS
# #     {
# #       "fileUris": ["https://${var.script_storage_account_name}.blob.core.windows.net/${var.container_name}/${var.script_name}"],
# #       "commandToExecute": "bash ${var.script_name}"
# #     }
# #   SETTINGS

# #   protected_settings = <<PROTECTED_SETTINGS
# #     {
# #       "storageAccountName": "${var.script_storage_account_name}",
# #       "storageAccountKey": "${var.script_storage_account_key}"
# #     }
# #   PROTECTED_SETTINGS

# #   lifecycle {
# #     ignore_changes = [
# #       tags,
# #       settings,
# #       protected_settings
# #     ]
# #   }
# # }


# ## Microsoft Monitoring Agent Extension

resource "azurerm_virtual_machine_extension" "monitor_agent" {
  count                      = var.log_analytics_workspace_resource_id == null ? 0 : 1
  name                       = "${local.vmNamePrefix}${format("%02d", count.index)}-MicrosoftMonitoringAgent"
  virtual_machine_id         = local.isWindowsOS == true ? "azurerm_windows_virtual_machine.virtual_machine[count.index].id" : azurerm_linux_virtual_machine.virtual_machine[count.index].id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = local.isWindowsOS == true ? "MicrosoftMonitoringAgent" : "OmsAgentForLinux"
  type_handler_version       = local.isWindowsOS == true ? "1.0" : "1.13"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId": "${local.log_analytics_workspace_id}",
      "stopOnMultipleConnections": "${local.isWindowsOS == true ? "false" : "true"}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${local.log_analytics_workspace_key}"
    }
  PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
  # depends_on = [azurerm_virtual_machine_extension.custom_script]
}

# resource "azurerm_virtual_machine_extension" "dependency_agent" {
#   count = var.log_analytics_workspace_resource_id == null ? 0 : 1
#   name                       = "${local.vmNamePrefix}${format("%02d",count.index)}-DependencyAgent"
#   virtual_machine_id         = local.isWindowsOS == true ? "azurerm_windows_virtual_machine.virtual_machine[count.index].id" : azurerm_linux_virtual_machine.virtual_machine[count.index].id 
#   publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
#   type                       = local.isWindowsOS == true ? "DependencyAgentWindows" : "DependencyAgentLinux" 
#   type_handler_version       = "9.10"
#   auto_upgrade_minor_version = true

#   settings = <<SETTINGS
#     {
#       "workspaceId": "${local.log_analytics_workspace_id}"
#     }
#   SETTINGS

#   protected_settings = <<PROTECTED_SETTINGS
#     {
#       "workspaceKey": "${local.log_analytics_workspace_key}"
#     }
#   PROTECTED_SETTINGS

#   lifecycle {
#     ignore_changes = [
#       tags
#     ]
#   }
#   depends_on = [azurerm_virtual_machine_extension.monitor_agent]
# }

# resource "azurerm_monitor_diagnostic_setting" "nsg_settings" {
#   count = var.log_analytics_workspace_resource_id == null ? 0 : 1
#   name                       = "DiagnosticsSettings"
#   target_resource_id         = azurerm_network_security_group.nsg.id
#   log_analytics_workspace_id = var.log_analytics_workspace_resource_id

#   log {
#     category = "NetworkSecurityGroupEvent"
#     enabled  = true

#     retention_policy {
#       enabled = true
#       days    = local.log_analytics_retention_days
#     }
#   }

#  log {
#     category = "NetworkSecurityGroupRuleCounter"
#     enabled  = true

#     retention_policy {
#       enabled = true
#       days    = local.log_analytics_retention_days
#     }
#   }
# }
