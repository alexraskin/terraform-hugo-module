# route53_dns

Route 53 records for a [`site`](../site): ACM validation records and A/AAAA aliases to the distribution.

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

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_validation_records"></a> [acm\_validation\_records](#input\_acm\_validation\_records) | From the site module, keyed by hostname. | <pre>map(object({<br/>    name  = string<br/>    type  = string<br/>    value = string<br/>  }))</pre> | n/a | yes |
| <a name="input_distribution_domain_name"></a> [distribution\_domain\_name](#input\_distribution\_domain\_name) | n/a | `string` | n/a | yes |
| <a name="input_distribution_hosted_zone_id"></a> [distribution\_hosted\_zone\_id](#input\_distribution\_hosted\_zone\_id) | n/a | `string` | n/a | yes |
| <a name="input_hostnames"></a> [hostnames](#input\_hostnames) | From the site module's hostnames output. | `list(string)` | n/a | yes |
| <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name) | Route 53 hosted zone the hostnames live in. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_validation_record_fqdns"></a> [validation\_record\_fqdns](#output\_validation\_record\_fqdns) | Feed back into the site module. |
<!-- END_TF_DOCS -->
