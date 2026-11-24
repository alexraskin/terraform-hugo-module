# A Hugo site: private S3 bucket behind CloudFront (OAC), with a DNS-validated
# ACM certificate for <domain> and www.<domain>. DNS records live in a separate
# module (route53_dns here, or the site's own) fed by acm_validation_records and the
# distribution outputs; its validation_record_fqdns come back in here.
module "bucket" {
  source = "../private_bucket"

  name   = var.bucket_name
  policy = data.aws_iam_policy_document.bucket.json
}
