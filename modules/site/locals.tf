locals {
  hostnames = [var.domain_name, "www.${var.domain_name}"]
}
