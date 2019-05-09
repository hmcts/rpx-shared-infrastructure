# module "shutterPage" {
#   source              = "git@github.com:hmcts/moj-module-shutterpage?ref=CNP-585"
#   location            = "${azurerm_resource_group.rg.location}"
#   env                 = "${var.env}"
#   resource_group_name = "${azurerm_resource_group.rg.name}"
#   shutterPageDirectory = "${var.shutterPageDirectory}"
#   tag_list     = "${local.common_tags}"
#   product      = "${var.productName}"
#   subscription = "${var.subscription}"
#   shutterCustomDomain = "${replace(var.productName, "-frontend", "")}"
# }
