data "azurerm_key_vault_secret" "cert" {
  name      = "${var.external_cert_name}"
  vault_uri = "https://infra-vault-${var.subscription}.vault.azure.net/"
}


data "azurerm_subnet" "ase_subnet" {
  name                 = "core-infra-subnet-0-${var.env}"
  virtual_network_name = "core-infra-vnet-${var.env}"
  resource_group_name  = "core-infra-${var.env}"
}


locals {
  probate_frontend_internal_hostname  = "${var.product}-frontend-${var.env}.service.core-compute-${var.env}.internal"
  caveats_internal_hostname = "${var.product}-caveats-fe-${var.env}.service.core-compute-${var.env}.internal"
}

module "appGw" {
  source            = "git@github.com:hmcts/cnp-module-waf?ref=ccd/CHG0033576"
  env               = "${var.env}"
  subscription      = "${var.subscription}"
  location          = "${var.location}"
  wafName           = "${var.product}-appGW"
  resourcegroupname = "${azurerm_resource_group.rg.name}"
  use_authentication_cert = "true"
  common_tags            = "${var.common_tags}"

  # vNet connections
  gatewayIpConfigurations = [
    {
      name     = "internalNetwork"
      subnetId = "${data.azurerm_subnet.ase_subnet.id}"
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
      name                    = "${var.product}-http-listener-service"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.external_hostname_gateway}"
    },
    {
      name                    = "${var.product}-https-listener-service"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.external_cert_name}"
      hostName                = "${var.external_hostname_gateway}"
    },
    {
      name                    = "${var.product}-http-listener-platform"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort80"
      Protocol                = "Http"
      SslCertificate          = ""
      hostName                = "${var.external_hostname_www}"
    },
    {
      name                    = "${var.product}-https-listener-platform"
      FrontendIPConfiguration = "appGatewayFrontendIP"
      FrontendPort            = "frontendPort443"
      Protocol                = "Https"
      SslCertificate          = "${var.external_cert_name}"
      hostName                = "${var.external_hostname_www}"
    },
    # {
    #   name                    = "${var.product}-caveats-http-listener-platform"
    #   FrontendIPConfiguration = "appGatewayFrontendIP"
    #   FrontendPort            = "frontendPort80"
    #   Protocol                = "Http"
    #   SslCertificate          = ""
    #   hostName                = "${var.external_hostname_www_caveats}"
    # },
    # {
    #   name                    = "${var.product}-caveats-https-listener-platform"
    #   FrontendIPConfiguration = "appGatewayFrontendIP"
    #   FrontendPort            = "frontendPort443"
    #   Protocol                = "Https"
    #   SslCertificate          = "${var.external_cert_name}"
    #   hostName                = "${var.external_hostname_www_caveats}"
    # },
  ]

  # Backend address Pools
  backendAddressPools = [
    {
      name = "${var.product}-${var.env}-palo-alto"
      backendAddresses = "${module.palo_alto.untrusted_ips_fqdn}"
    },
    {
      name = "${var.product}-${var.env}-backend-pa-pool"
      backendAddresses = [
        {
          ipAddress = "${local.probate_frontend_internal_hostname}"
        },
      ]
    },
    {
      name = "${var.product}-${var.env}-backend-cav-pool"

      backendAddresses = [
        {
          ipAddress = "${local.caveats_internal_hostname}"
        },
      ]
    },
  ]

  backendHttpSettingsCollection = [
    {
      name                           = "backend-80-nocookies-service"
      port                           = 80
      Protocol                       = "Http"
      AuthenticationCertificates     = ""
      CookieBasedAffinity            = "Disabled"
      probeEnabled                   = "True"
      probe                          = "http-probe-service"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_gateway}"
    },
    {
      name                           = "backend-80-nocookies-platform"
      port                           = 80
      Protocol                       = "Http"
      AuthenticationCertificates     = ""
      CookieBasedAffinity            = "Disabled"
      probeEnabled                   = "True"
      probe                          = "http-probe-platform"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_www}"
    },
    {
      name                           = "backend-80-nocookies-platform-caveats"
      port                           = 80
      Protocol                       = "Http"
      AuthenticationCertificates     = ""
      CookieBasedAffinity            = "Disabled"
      probeEnabled                   = "True"
      probe                          = "http-probe-platform-cav"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_www_caveats}"
    },
    {
      name                           = "backend-443-nocookies-platform"
      port                           = 443
      Protocol                       = "Https"
      AuthenticationCertificates     = "ilbCert"
      CookieBasedAffinity            = "Disabled"
      probeEnabled                   = "True"
      probe                          = "https-probe-platform"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_www}"
    },
    {
      name                           = "backend-443-nocookies-service"
      port                           = 443
      Protocol                       = "Https"
      AuthenticationCertificates     = "ilbCert"
      CookieBasedAffinity            = "Disabled"
      probeEnabled                   = "True"
      probe                          = "https-probe-service"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_gateway}"
    },
    {
      name                           = "backend-443-nocookies-platform-caveats"
      port                           = 443
      Protocol                       = "Https"
      AuthenticationCertificates     = "ilbCert"
      CookieBasedAffinity            = "Disabled"
      probeEnabled                   = "True"
      probe                          = "https-probe-platform-cav"
      PickHostNameFromBackendAddress = "False"
      HostName                       = "${var.external_hostname_www_caveats}"
    },
  ]

  # Request routing rules
  # requestRoutingRules = [

  # ]

  requestRoutingRulesPathBased = [
    {
      name                = "http-service"
      ruleType            = "PathBasedRouting"
      httpListener        = "${var.product}-http-listener-service"
      urlPathMap          = "http-url-path-map-service"
    },
    {
      name                = "https-service"
      ruleType            = "PathBasedRouting"
      httpListener        = "${var.product}-https-listener-service"
      urlPathMap          = "https-url-path-map-service"
    },
    {
      name                = "http-platform"
      ruleType            = "PathBasedRouting"
      httpListener        = "${var.product}-http-listener-platform"
      urlPathMap          = "http-url-path-map-platform"
    },
    {
      name                = "https-platform"
      ruleType            = "PathBasedRouting"
      httpListener        = "${var.product}-https-listener-platform"
      urlPathMap          = "https-url-path-map-platform"
    }
  ]

  urlPathMaps = [
    {
      name                       = "http-url-path-map-service"
      defaultBackendAddressPool  = "${var.product}-${var.env}-backend-pa-pool"
      defaultBackendHttpSettings = "backend-80-nocookies-service"
      pathRules                  = [
        {
          name                = "http-url-path-map-service-rule-caveats"
          paths               = ["/caveats","/caveats/*" ]
          backendAddressPool  = "${var.product}-${var.env}-backend-cav-pool"
          backendHttpSettings = "backend-443-nocookies-platform-caveats"
        },
        {
          name                = "http-url-path-map-service-rule-palo-alto"
          paths               = ["/document-upload"]
          backendAddressPool  = "${var.product}-${var.env}-palo-alto"
          backendHttpSettings = "backend-80-nocookies-service"
        }
      ]
    },
    {
      name                       = "https-url-path-map-service"
      defaultBackendAddressPool  = "${var.product}-${var.env}-backend-pa-pool"
      defaultBackendHttpSettings = "backend-443-nocookies-service"
      pathRules                  = [
        {
          name                = "https-url-path-map-service-rule-caveats"
          paths               = ["/caveats", "/caveats/*"]
          backendAddressPool  = "${var.product}-${var.env}-backend-cav-pool"
          backendHttpSettings = "backend-443-nocookies-platform-caveats"
        },
        {
          name                = "https-url-path-map-service-rule-palo-alto"
          paths               = ["/document-upload"]
          backendAddressPool  = "${var.product}-${var.env}-palo-alto"
          backendHttpSettings = "backend-80-nocookies-service"
        }
      ]
    },
    {      
      name                       = "http-url-path-map-platform"
      defaultBackendAddressPool  = "${var.product}-${var.env}-backend-pa-pool"
      defaultBackendHttpSettings = "backend-80-nocookies-platform"
      pathRules                  = [
        {
          name                = "backend-80-nocookies-platform-rule-caveats"
          paths               = ["/caveats","/caveats/*" ]
          backendAddressPool  = "${var.product}-${var.env}-backend-cav-pool"
          backendHttpSettings = "backend-80-nocookies-platform-caveats"
        },
        {
          name                = "backend-80-nocookies-platform-rule-palo-alto"
          paths               = ["/document-upload"]
          backendAddressPool  = "${var.product}-${var.env}-palo-alto"
          backendHttpSettings = "backend-80-nocookies-platform"
        }
      ]
    },
    {
      name                       = "https-url-path-map-platform"
      defaultBackendAddressPool  = "${var.product}-${var.env}-backend-pa-pool"
      defaultBackendHttpSettings = "backend-443-nocookies-platform"
      pathRules                  = [
        {
          name                = "backend-443-nocookies-platform-rule-caveats"
          paths               = ["/caveats", "/caveats/*"]
          backendAddressPool  = "${var.product}-${var.env}-backend-cav-pool"
          backendHttpSettings = "backend-443-nocookies-platform-caveats"
        },
        {
          name                = "backend-443-nocookies-platform-rule-palo-alto"
          paths               = ["/document-upload"]
          backendAddressPool  = "${var.product}-${var.env}-palo-alto"
          backendHttpSettings = "backend-443-nocookies-platform"
        }
      ]
    }
  ]

  probes = [
    {
      name                                = "http-probe-service"
      protocol                            = "Http"
      path                                = "/"
      interval                            = "${var.health_check_interval}"
      timeout                             = "${var.health_check_timeout}"
      unhealthyThreshold                  = "${var.unhealthy_threshold}"
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-80-nocookies-service"
      host                                = "${var.external_hostname_gateway}"
      healthyStatusCodes                  = "200-404"                  // MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "http-probe-platform"
      protocol                            = "Http"
      path                                = "/"
      interval                            = "${var.health_check_interval}"
      timeout                             = "${var.health_check_timeout}"
      unhealthyThreshold                  = "${var.unhealthy_threshold}"
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-80-nocookies-platform"
      host                                = "${var.external_hostname_www}"
      healthyStatusCodes                  = "200-404"                  // MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "http-probe-platform-cav"
      protocol                            = "Http"
      path                                = "/caveats"
      interval                            = "${var.health_check_interval}"
      timeout                             = "${var.health_check_timeout}"
      unhealthyThreshold                  = "${var.unhealthy_threshold}"
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-80-nocookies-platform-caveats"
      host                                = "${var.external_hostname_www_caveats}"
      healthyStatusCodes                  = "200-404"                  // MS returns 400 on /, allowing more codes in case they change it
    },
    {
      name                                = "https-probe-platform"
      protocol                            = "Https"
      path                                = "/"
      interval                            = "${var.health_check_interval}"
      timeout                             = "${var.health_check_timeout}"
      unhealthyThreshold                  = "${var.unhealthy_threshold}"
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-443-nocookies-platform"
      host                                = "${var.external_hostname_www}"
      healthyStatusCodes                  = "200-399"
    },
    {
      name                                = "https-probe-platform-cav"
      protocol                            = "Https"
      path                                = "/caveats"
      interval                            = "${var.health_check_interval}"
      timeout                             = "${var.health_check_timeout}"
      unhealthyThreshold                  = "${var.unhealthy_threshold}"
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-80-nocookies-platform-caveats"
      host                                = "${var.external_hostname_www_caveats}"
      healthyStatusCodes                  = "200-399"
    },
    {
      name                                = "https-probe-service"
      protocol                            = "Https"
      path                                = "/"
      interval                            = "${var.health_check_interval}"
      timeout                             = "${var.health_check_timeout}"
      unhealthyThreshold                  = "${var.unhealthy_threshold}"
      pickHostNameFromBackendHttpSettings = "false"
      backendHttpSettings                 = "backend-443-nocookies-service"
      host                                = "${var.external_hostname_gateway}"
      healthyStatusCodes                  = "200-399"
    },
    
  ]
}
