variable "zone_name" {
  description = "Route 53 hosted zone the hostnames live in."
  type        = string
}

variable "hostnames" {
  description = "From the site module's hostnames output."
  type        = list(string)
}

variable "acm_validation_records" {
  description = "From the site module, keyed by hostname."
  type = map(object({
    name  = string
    type  = string
    value = string
  }))
}

variable "distribution_domain_name" {
  type = string
}

variable "distribution_hosted_zone_id" {
  type = string
}
