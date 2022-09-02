## Terraform Versions

terraform {
  required_version = ">= 1.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    # HACK 0 - Opinionated Example Default
    resource_group_name  = "p-gov-tf"
    storage_account_name = "pgovtfstate202206281650"
    container_name       = "workflow"
    key                  = "module-virtual-machine.tfstate"
    subscription_id      = "64499dc8-d437-45d7-8d2e-4910e88e17b2"
  }
}
