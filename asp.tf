locals {
  ase_name = "core-compute-${var.env}"

  // num of apps * 1 to save cost where we can, * 2 in prod like environments
asp_capacity = "${var.env == "prod" || var.env == "sprod" || var.env == "aat" ? 2 : 2}"

asp_rd_capacity = "${var.env == "prod" || var.env == "sprod" || var.env == "aat" ? 2 : 2}"

  asp_anno_capacity = "${var.env == "prod" || var.env == "sprod" || var.env == "aat" ? 2 : 1}"

  asp_bundling_capacity = "${var.env == "prod" || var.env == "sprod" || var.env == "aat" ? 2 : 1}"

  asp_dg_capacity = "${var.env == "prod" || var.env == "sprod" || var.env == "aat" ? 2 : 1}"

  // I2 in prod like env, I1 everywhere else
  sku_size = "${var.env == "prod" || var.env == "sprod" || var.env == "aat" ? "I2" : "I1"}"
}

module "asp" {
  source              = "git@github.com:hmcts/cnp-module-app-service-plan?ref=master"
  location            = "${var.location}"
  env                 = "${var.env}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  asp_capacity        = "${local.asp_capacity}"
  asp_sku_size        = "${local.sku_size}"
  asp_name            = "${var.product}"
  ase_name            = "${local.ase_name}"
  tag_list            = "${local.tags}"
}
