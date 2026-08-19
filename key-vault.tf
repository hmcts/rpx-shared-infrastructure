module "key_vault" {
  source                               = "git@github.com:hmcts/cnp-module-key-vault?ref=DTSPO-31965/remove-jenkins-ptl-access"
  grant_preview_jenkins_access         = var.env == "aat"
  name                                 = "${var.product}-${var.env}"
  product                              = var.product
  env                                  = var.env
  tenant_id                            = var.tenant_id
  object_id                            = var.jenkins_AAD_objectId
  jenkins_object_id                    = data.azurerm_user_assigned_identity.jenkins.principal_id
  resource_group_name                  = azurerm_resource_group.rg.name
  product_group_object_id              = "7a7c6518-2381-408b-940c-7b9bd0256d9a" # dcd_group_expertui_v2
  common_tags                          = local.tags
  create_managed_identity              = true
  additional_managed_identities_access = var.additional_managed_identities_access
}

data "azurerm_user_assigned_identity" "jenkins" {
  name                = "jenkins-${var.env}-mi"
  resource_group_name = "managed-identities-${var.env}-rg"
}

output "vaultName" {
  value = module.key_vault.key_vault_name
}
