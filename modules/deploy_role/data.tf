data "aws_caller_identity" "current" {}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_route53_zone" "this" {
  count = var.route53_zone_name == "" ? 0 : 1
  name  = var.route53_zone_name
}

data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["${var.github_sub_prefix}:environment:${var.environment}"]
    }
  }
}

data "aws_iam_policy_document" "this" {
  source_policy_documents = var.additional_policy_documents

  statement {
    sid       = "StateList"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.state_bucket}"]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["${var.state_key_prefix}/*"]
    }
  }

  statement {
    sid       = "StateObjects"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.state_bucket}/${var.state_key_prefix}/*"]
  }

  # Bucket config for Terraform; ListBucket for hugo deploy's diff.
  statement {
    sid = "SiteBucket"
    actions = [
      "s3:Get*",
      "s3:ListBucket",
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:PutBucketPolicy",
      "s3:DeleteBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketOwnershipControls",
      "s3:PutEncryptionConfiguration",
      "s3:PutBucketTagging",
    ]
    resources = ["arn:aws:s3:::${var.resource_prefix}*"]
  }

  statement {
    sid       = "SiteObjects"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.resource_prefix}*/*"]
  }

  statement {
    sid = "CdnAndCertsRead"
    actions = [
      "cloudfront:Get*",
      "cloudfront:List*",
      "cloudfront:Describe*",
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:ListTagsForCertificate",
    ]
    resources = ["*"]
  }

  # Distributions and certs only have generated IDs, so scope by the default_tags
  # the site stack applies. Create must carry them...
  statement {
    sid = "CdnAndCertsCreateTagged"
    actions = [
      "cloudfront:CreateDistribution",
      "cloudfront:TagResource",
      "acm:RequestCertificate",
      "acm:AddTagsToCertificate",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Project"
      values   = [var.project]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/Environment"
      values   = [var.environment]
    }
  }

  # ...and changes need them already on the resource. RequestTag IfExists stops
  # retagging a resource into another env.
  statement {
    sid = "CdnAndCertsManageTagged"
    actions = [
      "cloudfront:UpdateDistribution",
      "cloudfront:DeleteDistribution",
      "cloudfront:CreateInvalidation",
      "cloudfront:TagResource",
      "cloudfront:UntagResource",
      "acm:DeleteCertificate",
      "acm:AddTagsToCertificate",
      "acm:RemoveTagsFromCertificate",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.project]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Environment"
      values   = [var.environment]
    }
    condition {
      test     = "StringEqualsIfExists"
      variable = "aws:RequestTag/Environment"
      values   = [var.environment]
    }
  }

  statement {
    sid = "CdnFunctions"
    actions = [
      "cloudfront:CreateFunction",
      "cloudfront:UpdateFunction",
      "cloudfront:PublishFunction",
      "cloudfront:DeleteFunction",
      "cloudfront:TestFunction",
      "cloudfront:TagResource",
      "cloudfront:UntagResource",
    ]
    resources = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:function/${var.resource_prefix}*"]
  }

  # OACs and response headers policies take no tags and get generated IDs, so
  # nothing narrower than * is available.
  statement {
    sid = "CdnUntaggable"
    actions = [
      "cloudfront:CreateOriginAccessControl",
      "cloudfront:UpdateOriginAccessControl",
      "cloudfront:DeleteOriginAccessControl",
      "cloudfront:CreateResponseHeadersPolicy",
      "cloudfront:UpdateResponseHeadersPolicy",
      "cloudfront:DeleteResponseHeadersPolicy",
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = data.aws_route53_zone.this
    content {
      sid = "DnsRead"
      actions = [
        "route53:GetChange",
        "route53:GetHostedZone",
        "route53:ListHostedZones",
        "route53:ListHostedZonesByName",
        "route53:ListResourceRecordSets",
        "route53:ListTagsForResource",
      ]
      resources = ["*"]
    }
  }

  dynamic "statement" {
    for_each = data.aws_route53_zone.this
    content {
      sid       = "DnsWriteOwnNames"
      actions   = ["route53:ChangeResourceRecordSets"]
      resources = [statement.value.arn]
      condition {
        test     = "ForAllValues:StringLike"
        variable = "route53:ChangeResourceRecordSetsNormalizedRecordNames"
        values   = local.dns_names
      }
      condition {
        test     = "Null"
        variable = "route53:ChangeResourceRecordSetsNormalizedRecordNames"
        values   = ["false"]
      }
    }
  }
}
