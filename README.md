# terraform-hugo-module

One way to host and deploy a Hugo site on AWS: a private S3 bucket behind
CloudFront, a DNS-validated ACM certificate, a GitHub OIDC deploy role, and a
reusable GitHub Actions workflow that builds, applies Terraform and runs
`hugo deploy`. Used by alexraskin.com, photography.alexraskin.com and
standwithiran.org.

## Terraform modules

| Module | Does |
|---|---|
| [`site`](modules/site) | Bucket, CloudFront (OAC, router function, security headers, managed `CachingOptimized`), ACM cert for `<domain>` + `www.<domain>` |
| [`route53_dns`](modules/route53_dns) | ACM validation records and A/AAAA aliases in Route 53. Sites on another DNS provider bring their own module with the same inputs. |
| [`deploy_role`](modules/deploy_role) | OIDC deploy role for one environment, applied by hand from the site's `bootstrap/` |
| [`private_bucket`](modules/private_bucket) | The hardened bucket `site` uses; reusable for other private buckets |

```hcl
module "site" {
  source    = "git::https://github.com/alexraskin/terraform-hugo-module.git//modules/site?ref=v1.0.0"
  providers = { aws = aws, aws.us_east_1 = aws.us_east_1 }

  name                    = local.name
  bucket_name             = "${local.name}-web-${data.aws_caller_identity.current.account_id}"
  domain_name             = var.domain_name
  validation_record_fqdns = module.dns.validation_record_fqdns
  content_security_policy = "default-src 'self'; frame-ancestors 'none'"
}

module "dns" {
  source = "git::https://github.com/alexraskin/terraform-hugo-module.git//modules/route53_dns?ref=v1.0.0"

  zone_name                   = var.zone_name
  hostnames                   = module.site.hostnames
  acm_validation_records      = module.site.acm_validation_records
  distribution_domain_name    = module.site.distribution_domain_name
  distribution_hosted_zone_id = module.site.distribution_hosted_zone_id
}
```

The router function 301s every request to one canonical URL
(`https://<domain>`, trailing slash, no `index.html`) and maps directory URLs
to Hugo's `index.html`. Missing keys serve `/404.html` with a 404.

## Deploy workflow

[`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) is a reusable
workflow. The build job runs on every event; the deploy job only when the
caller passes `deploy: true`.

```yaml
jobs:
  site:
    uses: alexraskin/terraform-hugo-module/.github/workflows/deploy.yml@v1.0.0
    permissions:
      contents: read
      id-token: write
    with:
      deploy: ${{ github.event_name != 'pull_request' && github.ref == 'refs/heads/main' }}
      url: https://example.com
```

What a site repo provides:

| | |
|---|---|
| mise tasks | `lint`, `build` (into `public/`), `deploy` (`hugo deploy --target=prod --invalidateCDN`), `tf:init`, `tf:plan`, `tf:apply` |
| `hugo.toml` | `[deployment]` target `prod` with the bucket and distribution ID, plus cache-control matchers |
| GitHub environment | `prod`, restricted to `main`, with vars `AWS_ROLE_ARN` and `AWS_REGION` |
| Terraform | `infrastructure/terraform/` (site stack) and `bootstrap/` (deploy role), per the module docs above |

Optional inputs: `prebuild-task` (+ `prebuild-role-arn`) runs a mise task with
AWS credentials before the build, e.g. to fetch content kept outside git.

## Releasing

Sites pin a tag. Change things here, `mise run lint`, tag `vX.Y.Z`, then bump
the `ref`/`@` in each site and check its plan before merging.
