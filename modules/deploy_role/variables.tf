variable "name" {
  description = "Role name, github-deploy-<project>-<env>."
  type        = string
}

variable "project" {
  description = "Project tag the site stack's default_tags apply; scopes CloudFront and ACM."
  type        = string
}

variable "environment" {
  description = "GitHub environment the role trusts, and the Environment tag it scopes to."
  type        = string
}

variable "github_repository" {
  description = "owner/name, for the role description."
  type        = string
}

variable "github_sub_prefix" {
  description = "OIDC sub claim prefix, from `gh api repos/<owner>/<repo>/actions/oidc/customization/sub`; the trust appends :environment:<env>."
  type        = string
}

variable "state_bucket" {
  type    = string
  default = "alexraskin-tfstate"
}

variable "state_key_prefix" {
  description = "State key prefix the role may use, <project>/<env>."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix of the site's bucket and CloudFront Function names."
  type        = string
}

variable "route53_zone_name" {
  description = "Zone the site's records live in. Empty when DNS is outside Route 53."
  type        = string
  default     = ""
}

variable "hostnames" {
  description = "Names the role may write in route53_zone_name, with their ACM validation records."
  type        = list(string)
  default     = []
}

variable "additional_policy_documents" {
  description = "Extra policy JSON merged in, for site-specific needs."
  type        = list(string)
  default     = []
}
