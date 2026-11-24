variable "name" {
  description = "Prefix for CloudFront resource names (OAC, <name>-router function, <name>-security headers policy). The deploy role scopes functions to it."
  type        = string
}

variable "bucket_name" {
  description = "Globally unique name of the private bucket hugo deploy uploads to."
  type        = string
}

variable "domain_name" {
  description = "Canonical host. The certificate also covers www.<domain_name>, which 301s here."
  type        = string
}

variable "validation_record_fqdns" {
  description = "ACM validation records created from acm_validation_records by the DNS module."
  type        = list(string)
}

variable "content_security_policy" {
  description = "Content-Security-Policy header. A site that sets its CSP in a <meta> tag still needs frame-ancestors here, since browsers ignore it in meta."
  type        = string
}

variable "cross_origin_resource_policy" {
  description = "Cross-Origin-Resource-Policy header, e.g. same-origin to stop hotlinking. Empty omits it."
  type        = string
  default     = ""
}

variable "root_language" {
  description = "Hugo defaultContentLanguage served at the root, whose /<lang>/ directory URLs 301 to /. Empty for single-language sites."
  type        = string
  default     = ""
}

variable "hsts_include_subdomains" {
  description = "Add includeSubDomains to HSTS (affects every subdomain of the zone)."
  type        = bool
  default     = false
}

variable "price_class" {
  description = "CloudFront price class. PriceClass_100 (NA + Europe edges) is cheapest."
  type        = string
  default     = "PriceClass_100"
}
