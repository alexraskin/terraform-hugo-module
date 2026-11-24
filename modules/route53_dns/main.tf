# Route 53 records for a site module: ACM validation, and A/AAAA aliases to
# the distribution (an apex can't be a CNAME).
resource "aws_route53_record" "validation" {
  for_each = toset(var.hostnames)

  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.acm_validation_records[each.key].name
  type    = var.acm_validation_records[each.key].type
  records = [var.acm_validation_records[each.key].value]
  ttl     = 60
}

resource "aws_route53_record" "alias" {
  for_each = { for p in setproduct(var.hostnames, ["A", "AAAA"]) : "${p[0]} ${p[1]}" => p }

  zone_id = data.aws_route53_zone.this.zone_id
  name    = each.value[0]
  type    = each.value[1]

  alias {
    name                   = var.distribution_domain_name
    zone_id                = var.distribution_hosted_zone_id
    evaluate_target_health = false
  }
}
