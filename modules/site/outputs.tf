output "bucket_name" {
  value = module.bucket.id
}

output "distribution_id" {
  value = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  value = aws_cloudfront_distribution.this.arn
}

output "distribution_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "distribution_hosted_zone_id" {
  value = aws_cloudfront_distribution.this.hosted_zone_id
}

output "hostnames" {
  description = "<domain_name> and www.<domain_name>, for the DNS module."
  value       = local.hostnames
}

output "acm_validation_records" {
  description = "Validation record per hostname, for the DNS module."
  value = {
    for o in aws_acm_certificate.this.domain_validation_options : o.domain_name => {
      name  = o.resource_record_name
      type  = o.resource_record_type
      value = o.resource_record_value
    }
  }
}
