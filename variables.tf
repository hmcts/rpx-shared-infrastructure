variable "product" {}

variable "location" {
  default = "UK South"
}

variable "common_tags" {
  type = map(string)
}

variable "env" {}

variable "application_type" {
  default     = "web"
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

variable "additional_managed_identities_access" {
  type        = list(string)
  description = "The name of your application"
  default     = []
}
