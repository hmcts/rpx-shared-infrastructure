data "azurerm_key_vault_secret" "cert" {
  name      = "${var.external_cert_name}"
  vault_uri = "${var.external_cert_vault_uri}"
}

locals {

 xui_suffix  = "${var.env != "prod" ? "-webapp" : ""}"

 webapp_internal_hostname_cases  = "xui-webapp-${var.env}.service.core-compute-${var.env}.internal"

webapp_internal_hostname_ao  = "xui-mo-webapp-${var.env}.service.core-compute-${var.env}.internal"

webapp_internal_hostname_mo  = "xui-ao-webapp-${var.env}.service.core-compute-${var.env}.internal"

}

module "appGw" {
  source            = "git@github.com:hmcts/cnp-module-waf?ref=ccd/CHG0033576"
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
      name     = "${var.external_cert_name}"
      data     = "${data.azurerm_key_vault_secret.cert.value}"
      password = ""
    },
  ]

  # Http Listeners
  httpListeners = [
    {
      name                    = "http-cases-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.external_hostname_cases}"
    },
    {
      name                    = "https-cases-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.external_cert_name}"
      hostName                = "${var.external_hostname_cases}"
    },
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
      SslCertificate          = "${var.external_cert_name}"
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
      SslCertificate          = "${var.external_cert_name}"
      hostName                = "${var.external_hostname_ao}"
    },
  ]

   # Backend address Pools
  backendAddressPools = [
    {
      name = "${var.product}-${var.env}"

      backendAddresses = [
        {
          ipAddress = "${local.webapp_internal_hostname_cases}"
        },
      ]
      
      name = "${var.product}-${var.env}-backend-ao-pool"
      backendAddresses = [
        {
          ipAddress = "${local.webapp_internal_hostname_ao}"
        },
      ]
      
      name = "${var.product}-${var.env}-backend-mo-pool"
      backendAddresses = [
        {
          ipAddress = "${local.webapp_internal_hostname_mo}"
        },
      ]
    },
  ]
  
  use_authentication_cert = true
  backendHttpSettingsCollection = [
    {
      name                           = "backend-cases-80"
      port                           = 80
      Protocol                       = "Http"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = ""
      probeEnabled                   = "True"
      probe                          = "http-cases-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_cases}"
    },
      {
      name                           = "backend-cases-443"
      port                           = 443
      Protocol                       = "Https"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = "ilbCert"
      probeEnabled                   = "True"
      probe                          = "https-cases-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_cases}"
    },
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
  ]
  
  # Request routing rules
  requestRoutingRules = [
    {
      name                = "http-cases"
      RuleType            = "Basic"
      httpListener        = "http-cases-listener"
      backendAddressPool  = "${var.product}-${var.env}"
      backendHttpSettings = "backend-cases-80"
    },
    {
      name                = "https-cases"
      RuleType            = "Basic"
      httpListener        = "https-cases-listener"
      backendAddressPool  = "${var.product}-${var.env}"
      backendHttpSettings = "backend-cases-443"
    },
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
    {
      name                                = "http-cases-probe"
      protocol                            = "Http"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-cases-80"
      host                                = "${var.external_hostname_cases}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "https-cases-probe"
      protocol                            = "Https"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-cases-443"
      host                                = "${var.external_hostname_cases}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
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
