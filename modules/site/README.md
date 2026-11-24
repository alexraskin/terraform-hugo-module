# site

A Hugo site's AWS side: private bucket behind CloudFront (OAC, router function, security headers) and a DNS-validated ACM certificate for `<domain>` and `www.<domain>`. Pair it with a DNS module: [`route53_dns`](../route53_dns), or the site's own for another provider. Root must pass `aws.us_east_1`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |
| <a name="provider_aws.us_east_1"></a> [aws.us\_east\_1](#provider\_aws.us\_east\_1) | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bucket"></a> [bucket](#module\_bucket) | ../private_bucket | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_function.router](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_cloudfront_origin_access_control.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_response_headers_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy) | resource |
| [aws_cloudfront_cache_policy.optimized](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_iam_policy_document.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Globally unique name of the private bucket hugo deploy uploads to. | `string` | n/a | yes |
| <a name="input_content_security_policy"></a> [content\_security\_policy](#input\_content\_security\_policy) | Content-Security-Policy header. A site that sets its CSP in a <meta> tag still needs frame-ancestors here, since browsers ignore it in meta. | `string` | n/a | yes |
| <a name="input_cross_origin_resource_policy"></a> [cross\_origin\_resource\_policy](#input\_cross\_origin\_resource\_policy) | Cross-Origin-Resource-Policy header, e.g. same-origin to stop hotlinking. Empty omits it. | `string` | `""` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Canonical host. The certificate also covers www.<domain\_name>, which 301s here. | `string` | n/a | yes |
| <a name="input_hsts_include_subdomains"></a> [hsts\_include\_subdomains](#input\_hsts\_include\_subdomains) | Add includeSubDomains to HSTS (affects every subdomain of the zone). | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Prefix for CloudFront resource names (OAC, <name>-router function, <name>-security headers policy). The deploy role scopes functions to it. | `string` | n/a | yes |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | CloudFront price class. PriceClass\_100 (NA + Europe edges) is cheapest. | `string` | `"PriceClass_100"` | no |
| <a name="input_root_language"></a> [root\_language](#input\_root\_language) | Hugo defaultContentLanguage served at the root, whose /<lang>/ directory URLs 301 to /. Empty for single-language sites. | `string` | `""` | no |
| <a name="input_validation_record_fqdns"></a> [validation\_record\_fqdns](#input\_validation\_record\_fqdns) | ACM validation records created from acm\_validation\_records by the DNS module. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_validation_records"></a> [acm\_validation\_records](#output\_acm\_validation\_records) | Validation record per hostname, for the DNS module. |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | n/a |
| <a name="output_distribution_arn"></a> [distribution\_arn](#output\_distribution\_arn) | n/a |
| <a name="output_distribution_domain_name"></a> [distribution\_domain\_name](#output\_distribution\_domain\_name) | n/a |
| <a name="output_distribution_hosted_zone_id"></a> [distribution\_hosted\_zone\_id](#output\_distribution\_hosted\_zone\_id) | n/a |
| <a name="output_distribution_id"></a> [distribution\_id](#output\_distribution\_id) | n/a |
| <a name="output_hostnames"></a> [hostnames](#output\_hostnames) | <domain\_name> and www.<domain\_name>, for the DNS module. |
<!-- END_TF_DOCS -->
