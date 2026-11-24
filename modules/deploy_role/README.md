# deploy_role

GitHub Actions OIDC deploy role for one environment of a site stack, scoped to its state key, bucket and function prefix, and `Project`/`Environment` tags. Apply from the site's `bootstrap/` root by hand.

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
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_policy_documents"></a> [additional\_policy\_documents](#input\_additional\_policy\_documents) | Extra policy JSON merged in, for site-specific needs. | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | GitHub environment the role trusts, and the Environment tag it scopes to. | `string` | n/a | yes |
| <a name="input_github_repository"></a> [github\_repository](#input\_github\_repository) | owner/name, for the role description. | `string` | n/a | yes |
| <a name="input_github_sub_prefix"></a> [github\_sub\_prefix](#input\_github\_sub\_prefix) | OIDC sub claim prefix, from `gh api repos/<owner>/<repo>/actions/oidc/customization/sub`; the trust appends :environment:<env>. | `string` | n/a | yes |
| <a name="input_hostnames"></a> [hostnames](#input\_hostnames) | Names the role may write in route53\_zone\_name, with their ACM validation records. | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Role name, github-deploy-<project>-<env>. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project tag the site stack's default\_tags apply; scopes CloudFront and ACM. | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix of the site's bucket and CloudFront Function names. | `string` | n/a | yes |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | Zone the site's records live in. Empty when DNS is outside Route 53. | `string` | `""` | no |
| <a name="input_state_bucket"></a> [state\_bucket](#input\_state\_bucket) | n/a | `string` | `"alexraskin-tfstate"` | no |
| <a name="input_state_key_prefix"></a> [state\_key\_prefix](#input\_state\_key\_prefix) | State key prefix the role may use, <project>/<env>. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
<!-- END_TF_DOCS -->
