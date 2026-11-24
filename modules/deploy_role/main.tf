# GitHub Actions OIDC deploy role for one environment of a site stack. Applied
# by hand from the site's bootstrap root. Name it outside resource_prefix so
# the role can't edit its own policy.
resource "aws_iam_role" "this" {
  name                 = var.name
  description          = "GitHub Actions deploy for ${var.github_repository} (${var.environment})"
  assume_role_policy   = data.aws_iam_policy_document.trust.json
  max_session_duration = 3600
}

resource "aws_iam_role_policy" "this" {
  name   = "deploy"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.this.json
}
