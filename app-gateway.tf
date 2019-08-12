resource "azurerm_application_insights" "appinsights" {
  name                = "${var.product}-${var.env}"
  location            = "${var.appinsights_location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  application_type    = "${var.application_type}"
}

output "appInsightsInstrumentationKey" {
  value = "${azurerm_application_insights.appinsights.instrumentation_key}"
}
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
      name     = "${var.external_cert_name_mo}"
      data     = "${data.azurerm_key_vault_secret.cert.value}"
      password = ""
    },
    {
      name     = "${var.external_cert_name_ao}"
      data     = "${data.azurerm_key_vault_secret.cert.value}"
      password = ""
    },
    {
      name     = "${var.external_cert_name_cases}"
      data     = "${data.azurerm_key_vault_secret.cert.value}"
      password = ""
    },
  ]

  # Http Listeners
  httpListeners = [
    {
      name                    = "http-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.external_hostname_cases}"
    },
    {
      name                    = "https-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.external_cert_name_cases}"
      hostName                = "${var.external_hostname_cases}"
    },
    {
      name                    = "www-http-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.external_hostname_www}"
    },
    {
      name                    = "www-https-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.external_cert_name_cases}"
      hostName                = "${var.external_hostname_www}"
    },
    {
      name                    = "http-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.external_hostname_mo}"
    },
    {
      name                    = "https-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.external_cert_name_mo}"
      hostName                = "${var.external_hostname_mo}"
    },
    {
      name                    = "www-http-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.external_hostname_www}"
    },
    {
      name                    = "www-https-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.external_cert_name_mo}"
      hostName                = "${var.external_hostname_www}"
    },
    {
      name                    = "http-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.external_hostname_ao}"
    },
    {
      name                    = "https-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.external_cert_name_ao}"
      hostName                = "${var.external_hostname_ao}"
    },
    {
      name                    = "www-http-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.external_hostname_www}"
    },
    {
      name                    = "www-https-listener"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.external_cert_name_ao}"
      hostName                = "${var.external_hostname_www}"
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
        {
          ipAddress = "${local.webapp_internal_hostname_ao}"
        },
        {
          ipAddress = "${local.webapp_internal_hostname_mo}"
        }
      ]
    },
  ]
  use_authentication_cert = true
  backendHttpSettingsCollection = [
    {
      name                           = "backend-80"
      port                           = 80
      Protocol                       = "Http"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = ""
      probeEnabled                   = "True"
      probe                          = "http-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_cases}"
    },
      {
      name                           = "backend-443"
      port                           = 443
      Protocol                       = "Https"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = "ilbCert"
      probeEnabled                   = "True"
      probe                          = "https-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_cases}"
    },
      {
      name                           = "backend-80-www"
      port                           = 80
      Protocol                       = "Http"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = ""
      probeEnabled                   = "True"
      probe                          = "www-http-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_www}"
    },
      {
      name                           = "backend-443-www"
      port                           = 443
      Protocol                       = "Https"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = "ilbCert"
      probeEnabled                   = "True"
      probe                          = "www-https-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_www}"
    },
    {
      name                           = "backend-80"
      port                           = 80
      Protocol                       = "Http"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = ""
      probeEnabled                   = "True"
      probe                          = "http-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_mo}"
    },
      {
      name                           = "backend-443"
      port                           = 443
      Protocol                       = "Https"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = "ilbCert"
      probeEnabled                   = "True"
      probe                          = "https-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_mo}"
    },
      {
      name                           = "backend-80-www"
      port                           = 80
      Protocol                       = "Http"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = ""
      probeEnabled                   = "True"
      probe                          = "www-http-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_www}"
    },
      {
      name                           = "backend-443-www"
      port                           = 443
      Protocol                       = "Https"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = "ilbCert"
      probeEnabled                   = "True"
      probe                          = "www-https-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_www}"
    },
    {
      name                           = "backend-80"
      port                           = 80
      Protocol                       = "Http"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = ""
      probeEnabled                   = "True"
      probe                          = "http-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_ao}"
    },
      {
      name                           = "backend-443"
      port                           = 443
      Protocol                       = "Https"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = "ilbCert"
      probeEnabled                   = "True"
      probe                          = "https-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_ao}"
    },
      {
      name                           = "backend-80-www"
      port                           = 80
      Protocol                       = "Http"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = ""
      probeEnabled                   = "True"
      probe                          = "www-http-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_www}"
    },
      {
      name                           = "backend-443-www"
      port                           = 443
      Protocol                       = "Https"
      CookieBasedAffinity            = "Disabled"
      AuthenticationCertificates     = "ilbCert"
      probeEnabled                   = "True"
      probe                          = "www-https-probe"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_www}"
    },
    {
      name                = "http"
      RuleType            = "Basic"
      httpListener        = "http-listener"
      backendAddressPool  = "${var.product}-${var.env}"
      backendHttpSettings = "backend-80"
    },
    {
      name                = "https"
      RuleType            = "Basic"
      httpListener        = "https-listener"
      backendAddressPool  = "${var.product}-${var.env}"
      backendHttpSettings = "backend-443"
    },
    {
      name                = "www-http"
      RuleType            = "Basic"
      httpListener        = "www-http-listener"
      backendAddressPool  = "${var.product}-${var.env}"
      backendHttpSettings = "backend-80-www"
    },
    {
      name                = "www-https"
      RuleType            = "Basic"
      httpListener        = "www-https-listener"
      backendAddressPool  = "${var.product}-${var.env}"
      backendHttpSettings = "backend-443-www"
    },
    {
      name                                = "http-probe"
      protocol                            = "Http"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-80"
      host                                = "${var.external_hostname_cases}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "https-probe"
      protocol                            = "Https"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-443"
      host                                = "${var.external_hostname_cases}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "www-http-probe"
      protocol                            = "Http"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-80-www"
      host                                = "${var.external_hostname_www}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "www-https-probe"
      protocol                            = "Https"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-443-www"
      host                                = "${var.external_hostname_www}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "http-probe"
      protocol                            = "Http"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-80"
      host                                = "${var.external_hostname_mo}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "https-probe"
      protocol                            = "Https"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-443"
      host                                = "${var.external_hostname_mo}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "www-http-probe"
      protocol                            = "Http"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-80-www"
      host                                = "${var.external_hostname_www}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "www-https-probe"
      protocol                            = "Https"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-443-www"
      host                                = "${var.external_hostname_www}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "http-probe"
      protocol                            = "Http"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-80"
      host                                = "${var.external_hostname_ao}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "https-probe"
      protocol                            = "Https"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-443"
      host                                = "${var.external_hostname_ao}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "www-http-probe"
      protocol                            = "Http"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-80-www"
      host                                = "${var.external_hostname_www}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "www-https-probe"
      protocol                            = "Https"
      path                                = "/"
      interval                            = 30
      timeout                             = 30
      unhealthyThreshold                  = 5
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-443-www"
      host                                = "${var.external_hostname_www}"
      healthyStatusCodes                  = "200-399"                  #// MS returns 400 on /, allowing more codes in case they change it
    },
  ]
}