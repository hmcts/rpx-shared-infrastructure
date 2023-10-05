module "key_vault" {
  source                     = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                       = "${var.product}-${var.env}"
  product                    = var.product
  env                        = var.env
  tenant_id                  = var.tenant_id
  object_id                  = var.jenkins_AAD_objectId
  resource_group_name        = azurerm_resource_group.rg.name
  product_group_object_id    = "7a7c6518-2381-408b-940c-7b9bd0256d9a" # dcd_group_expertui_v2
  common_tags                = local.tags
  create_managed_identity    = true
}

output "vaultName" {
  value = module.key_vault.key_vault_name
}
