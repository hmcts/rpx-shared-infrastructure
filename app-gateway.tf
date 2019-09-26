data "azurerm_key_vault_secret" "cert" {
  name      = "${var.external_ao_cert_name}"
  name      = "${var.external_mo_cert_name}"
  name      = "${var.external_reg_cert_name}"
  name      = "${var.external_cert_name}"
  vault_uri = "${var.external_cert_vault_uri}"
}

locals {

xui_suffix  = "${var.env != "prod" ? "-webapp" : ""}"

webapp_internal_hostname_case  = "xui-webapp-${var.env}.service.core-compute-${var.env}.internal"

webapp_internal_hostname_ao  = "xui-mo-webapp-${var.env}.service.core-compute-${var.env}.internal"

webapp_internal_hostname_mo  = "xui-ao-webapp-${var.env}.service.core-compute-${var.env}.internal"

}

module "appGw" {
  source            = "git@github.com:hmcts/cnp-module-waf?ref=master"
  env               = "${var.env}"
  subscription      = "${var.subscription}"
  location          = "${var.location}"
  wafName           = "${var.product}"
  resourcegroupname = "${azurerm_resource_group.rg.name}"
  common_tags       = "${var.common_tags}"

  # vNet connections
  gatewayIpConfigurations = [
    {
      name     = "internalNetwork"
      subnetId = "${data.azurerm_subnet.subnet_a.id}"
    },
  ]

  sslCertificates = [
    {
      name     = "${var.external_ao_cert_name}"
      data     = "${data.azurerm_key_vault_secret.cert.value}"
      password = ""
    },
    {
      name     = "${var.external_mo_cert_name}"
      data     = "${data.azurerm_key_vault_secret.cert.value}"
      password = ""
    },
    {
      name     = "${var.external_reg_cert_name}"
      data     = "${data.azurerm_key_vault_secret.cert.value}"
      password = ""
    },
    {
      name     = "${var.external_cert_name}"
      data     = "${data.azurerm_key_vault_secret.cert.value}"
      password = ""
    },
  ]

  # Http Listeners
  httpListeners = [
    //{
    //  name                    = "http-case-listener"
    //  FrontendIPConfiguration = "appGatewayFrontendIP"
    //  FrontendPort            = "frontendPort80"
    //  Protocol                = "Http"
    //  SslCertificate          = ""
    //  hostName                = "${var.external_hostname_case}"
    //},
    //{
    //  name                    = "https-case-listener"
    //  FrontendIPConfiguration = "appGatewayFrontendIP"
    //  FrontendPort            = "frontendPort443"
    //  Protocol                = "Https"
    //  SslCertificate          = "${var.external_cert_name}"
    //  hostName                = "${var.external_hostname_case}"
    //},
    {
      name                    = "http-mo-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.external_hostname_mo}"
    },
    {
      name                    = "https-mo-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.external_mo_cert_name}"
      hostName                = "${var.external_hostname_mo}"
    },
    {
      name                    = "http-ao-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.external_hostname_ao}"
    },
    {
      name                    = "https-ao-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.external_ao_cert_name}"
      hostName                = "${var.external_hostname_ao}"
    },
        {
      name                    = "http-mo-reg-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.external_hostname_mo_reg}"
    },
    {
      name                    = "https-mo-reg-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.external_reg_cert_name}"
      hostName                = "${var.external_hostname_mo_reg}"
    },
  ]

   # Backend address Pools
  backendAddressPools = [
    {
      name = "${var.product}-${var.env}"

      backendAddresses = [
        {
          ipAddress = "${local.webapp_internal_hostname_case}"
        },
        {
          ipAddress = "${local.webapp_internal_hostname_ao}"
        },
        {
          ipAddress = "${local.webapp_internal_hostname_mo}"
        },
      ]
    },
  ]
  
  use_authentication_cert = true
  backendHttpSettingsCollection = [
    //{
    //  name                           = "backend-case-80"
    //  port                           = 80
    //  Protocol                       = "Http"
    //  CookieBasedAffinity            = "Disabled"
    //  AuthenticationCertificates     = ""
    //  probeEnabled                   = "True"
    //  probe                          = "http-case-probe"
    //  PickHostNameFromBackendAddress = "False"
    //  HostName                       = "${var.external_hostname_case}"
    //},
    //  {
    //  name                           = "backend-case-443"
    //  port                           = 443
    //  Protocol                       = "Https"
    //  CookieBasedAffinity            = "Disabled"
    //  AuthenticationCertificates     = "ilbCert"
    //  probeEnabled                   = "True"
    //  probe                          = "https-case-probe"
    //  PickHostNameFromBackendAddress = "False"
    //  HostName                       = "${var.external_hostname_case}"
    //},
    {
      name                           = "backend-mo-80"
      port                           = 80
      Protocol                       = "Http"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = ""
      probeEnabled                   = "True"
      probe                          = "http-mo-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_mo}"
    },
      {
      name                           = "backend-mo-443"
      port                           = 443
      Protocol                       = "Https"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = "ilbCert"
      probeEnabled                   = "True"
      probe                          = "https-mo-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_mo}"
    },
    {
      name                           = "backend-ao-80"
      port                           = 80
      Protocol                       = "Http"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = ""
      probeEnabled                   = "True"
      probe                          = "http-ao-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_ao}"
    },
    {
      name                           = "backend-ao-443"
      port                           = 443
      Protocol                       = "Https"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = "ilbCert"
      probeEnabled                   = "True"
      probe                          = "https-ao-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_ao}"
    },
      {
      name                           = "backend-mo-reg-80"
      port                           = 80
      Protocol                       = "Http"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = ""
      probeEnabled                   = "True"
      probe                          = "http-mo-probe"
      PickHostNameFromBackendAddress = "False"
      HostName = ""
    },
      {
      name                           = "backend-mo-reg-443"
      port                           = 443
      Protocol                       = "Https"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = "ilbCert"
      probeEnabled                   = "True"
      probe                          = "https-mo-probe"
      PickHostNameFromBackendAddress = "False"
      HostName = ""
    },
  ]
  
  # Request routing rules
  requestRoutingRules = [
    //{
    //  name                = "http-case"
    //  RuleType            = "Basic"
    //  httpListener        = "http-case-listener"
    //  backendAddressPool  = "${var.product}-${var.env}"
    //  backendHttpSettings = "backend-case-80"
    //},
    //{
    //  name                = "https-case"
    //  RuleType            = "Basic"
    //  httpListener        = "https-case-listener"
    //  backendAddressPool  = "${var.product}-${var.env}"
    //  backendHttpSettings = "backend-case-443"
    //},
    {
      name                = "http-mo"
      RuleType            = "Basic"
      httpListener        = "http-mo-listener"
      backendAddressPool  = "${var.product}-${var.env}"
      backendHttpSettings = "backend-mo-80"
    },
    {
      name                = "https-mo"
      RuleType            = "Basic"
      httpListener        = "https-mo-listener"
      backendAddressPool  = "${var.product}-${var.env}"
      backendHttpSettings = "backend-mo-443"
    },
        {
      name                = "http-ao"
      RuleType            = "Basic"
      httpListener        = "http-ao-listener"
      backendAddressPool  = "${var.product}-${var.env}"
      backendHttpSettings = "backend-ao-80"
    },
    {
      name                = "https-ao"
      RuleType            = "Basic"
      httpListener        = "https-ao-listener"
      backendAddressPool  = "${var.product}-${var.env}"
      backendHttpSettings = "backend-ao-443"
    },
  ]

  probes = [
    //{
    //  name                                = "http-case-probe"
    //  protocol                            = "Http"
    //  path                                = "/"
    //  interval                            = 30
    //  timeout                             = 30
    //  unhealthyThreshold                  = 5
    //  pickHostNameFromBackendHttpSettings = "false"
    //  backendHttpSettings                 = "backend-case-80"
    //  host                                = "${var.external_hostname_case}"
    //  healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    //},
    //{
    //  name                                = "https-case-probe"
    //  protocol                            = "Https"
    //  path                                = "/"
    //  interval                            = 30
    //  timeout                             = 30
    //  unhealthyThreshold                  = 5
    //  pickHostNameFromBackendHttpSettings = "false"
    //  backendHttpSettings                 = "backend-case-443"
    //  host                                = "${var.external_hostname_case}"
    //  healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    //},
    {
      name                                = "http-mo-probe"
      protocol                            = "Http"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-mo-80"
      host                                = "${var.external_hostname_mo}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "https-mo-probe"
      protocol                            = "Https"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-mo-443"
      host                                = "${var.external_hostname_mo}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "http-ao-probe"
      protocol                            = "Http"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-ao-80"
      host                                = "${var.external_hostname_ao}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "https-ao-probe"
      protocol                            = "Https"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-ao-443"
      host                                = "${var.external_hostname_ao}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
  ]
}
