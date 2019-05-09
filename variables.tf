variable "product" {
  type = "string"
  default = "probate"
}

variable "location" {
  type    = "string"
  default = "UK South"
}

// as of now, UK South is unavailable for Application Insights
variable "appinsights_location" {
  type        = "string"
  default     = "West Europe"
  description = "Location for Application Insights"
}

variable "env" {
  type = "string"
}

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

variable "shutterPageDirectory" {
  type    = "string"
  default = "shutterPage"
}

//SHARED VARIABLES
variable "subscription" {}

variable "mgmt_subscription_id" {}

variable "productName" {
  type    = "string"
  default = "probate-frontend"
}

variable "asp_capacity" {
 default = "2" 
}

// TAG SPECIFIC VARIABLES
variable "common_tags" {
  type = "map"
}

variable "external_cert_vault_uri" {}
variable "external_cert_name" {}
variable "external_hostname" {}

// TAG SPECIFIC VARIABLES
variable "team_name" {
  type        = "string"
  description = "The name of your team"
  default     = "Probate"
}

variable "team_contact" {
  type        = "string"
  description = "The name of your Slack channel people can use to contact your team about your infrastructure"
  default     = "#probate-jenkins"
}

variable "destroy_me" {
  type        = "string"
  description = "Here be dragons! In the future if this is set to Yes then automation will delete this resource on a schedule. Please set to No unless you know what you are doing"
  default     = "No"
}

variable "ilbIp" {}

variable "external_hostname_gateway" {
  type = "string"
}

variable "external_hostname_www" {
  type = "string"
}

variable "health_check_interval" {
  default = "30"
}

variable "health_check_timeout" {
  default = "30"
}

variable "unhealthy_threshold" {
  default = "5"
}

variable "external_hostname_www_caveats" {
  type = "string"
}