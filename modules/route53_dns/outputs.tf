output "validation_record_fqdns" {
  description = "Feed back into the site module."
  value       = [for r in aws_route53_record.validation : r.fqdn]
}
