terraform {
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.6.0"
}

provider "azurerm" {
  features {}
}