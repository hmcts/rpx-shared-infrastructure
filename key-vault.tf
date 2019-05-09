module "rpx-vault" {
  source = "git@github.com:contino/moj-module-key-vault?ref=master"
  name = "rpx-${var.env}"
  product = "${var.product}"
  env = "${var.env}"
  tenant_id = "${var.tenant_id}"
  object_id = "${var.jenkins_AAD_objectId}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  product_group_object_id = "33ed3c5a-bd38-4083-84e3-2ba17841e31e"
  common_tags            = "${var.common_tags}"
}

output "vaultName" {
  value = "${module.rpx-vault.key_vault_name}"
}
