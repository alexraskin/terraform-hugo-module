locals {
  # ACM validation names are _<32 hex>.<host>; _dmarc and friends stay out of reach.
  acm_label = "_${join("", [for i in range(32) : "?"])}"
  dns_names = flatten([for h in var.hostnames : [h, "${local.acm_label}.${h}"]])
}
