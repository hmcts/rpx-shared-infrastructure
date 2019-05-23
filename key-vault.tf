module "key_vault" {
  source = "git@github.com:contino/moj-module-key-vault?ref=master"
  name = "${var.product}-${var.env}"
  product = "${var.product}"
  env = "${var.env}"
  tenant_id = "${var.tenant_id}"
  object_id = "${var.jenkins_AAD_objectId}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  product_group_object_id = "5d9cd025-a293-4b97-a0e5-6f43efce02c0"
  common_tags = "${local.tags}"
}

output "vaultName" {
  value = "${module.key_vault.key_vault_name}"
}
