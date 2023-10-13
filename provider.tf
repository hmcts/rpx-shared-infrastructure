terraform {
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.76.0"
    }
  }

  required_version = "~> 1.3.5"
}

provider "azurerm" {
  features {}
}