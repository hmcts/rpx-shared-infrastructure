variable "product" {}

variable "location" {
  type = "string"
  default = "UK South"
}

// as of now, UK South is unavailable for Application Insights
variable "appinsights_location" {
  type        = "string"
  default     = "West Europe"
  description = "Location for Application Insights"
}

variable "common_tags" {
  type = "map"
}

variable "env" {}

variable "application_type" {
  type        = "string"
  default     = "Web"
  description = "Type of Application Insights (Web/Other)"
}

variable "tenant_id" {
  description = "(Required) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. This is usually sourced from environemnt variables and not normally required to be specified."
}

variable "jenkins_AAD_objectId" {
  description = "(Required) The Azure AD object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies."
}

variable "subscription" {}

variable "team_name" {
  default = "rpa"
}

variable "team_contact" {
  default = "#expert-ui"
}

variable "name" {
  default = false
}

variable "asp_capacity" {
  default = 2
}

variable "ilbIp" {}

variable "external_hostname" {}

variable "external_cert_name" {}

variable "external_hostname_ao" {}

variable "external_hostname_mo" {}

variable "external_hostname_cases" {}

variable "external_hostname_www" {}

variable "external_cert_vault_uri" {}
