data "azurerm_subnet" "ci_evidence_private_endpoint" {
  resource_group_name  = "core-infra-${var.env}"
  virtual_network_name = "core-infra-vnet-${var.env}"
  name                 = "scan-storage"
}

module "ci_evidence_storage" {
  source = "git@github.com:hmcts/cnp-module-storage-account?ref=feature/xui-blob-shared-key"

  env                      = var.env
  storage_account_name     = "xuicireports${var.env}01"
  resource_group_name      = azurerm_resource_group.rg.name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  access_tier              = "Hot"
  common_tags              = local.tags
  containers = [
    { name = "reports", access_type = "private" },
    { name = "summaries", access_type = "private" }
  ]
  enable_data_protection        = false
  shared_access_key_enabled     = false
  public_network_access_enabled = false
  default_action                = "Deny"
  private_endpoint_subnet_id    = data.azurerm_subnet.ci_evidence_private_endpoint.id
  managed_identity_object_id    = data.azurerm_user_assigned_identity.jenkins.principal_id
  role_assignments              = ["Storage Blob Data Contributor"]
}

resource "azurerm_storage_management_policy" "ci_evidence" {
  storage_account_id = module.ci_evidence_storage.storageaccount_id

  rule {
    name    = "delete-reports-after-90-days"
    enabled = true

    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["reports/90d/"]
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 90
      }
    }
  }

  rule {
    name    = "delete-release-reports-after-365-days"
    enabled = true

    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["reports/365d/"]
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 365
      }
    }
  }

  rule {
    name    = "delete-summaries-after-365-days"
    enabled = true

    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["summaries/"]
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 365
      }
    }
  }
}

output "ci_evidence_storage_account_name" {
  value = module.ci_evidence_storage.storageaccount_name
}
