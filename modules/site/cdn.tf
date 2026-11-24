resource "aws_cloudfront_origin_access_control" "this" {
  name                              = var.name
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "router" {
  name    = "${var.name}-router"
  runtime = "cloudfront-js-2.0"
  publish = true
  code = templatefile("${path.module}/router.js", {
    canonical_host = var.domain_name
    root_language  = var.root_language
  })

  # Attached to the distribution, so a rename must create the new one first.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_response_headers_policy" "this" {
  name = "${var.name}-security"

  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
    strict_transport_security {
      access_control_max_age_sec = 31536000
      # includeSubDomains forces HTTPS on every other subdomain of the zone too.
      include_subdomains = var.hsts_include_subdomains
      override           = true
    }
    content_security_policy {
      content_security_policy = var.content_security_policy
      override                = true
    }
  }

  custom_headers_config {
    items {
      header   = "Permissions-Policy"
      value    = "camera=(), microphone=(), geolocation=(), payment=(), browsing-topics=()"
      override = true
    }
    items {
      header   = "Cross-Origin-Opener-Policy"
      value    = "same-origin"
      override = true
    }
    dynamic "items" {
      for_each = var.cross_origin_resource_policy == "" ? [] : [var.cross_origin_resource_policy]
      content {
        header   = "Cross-Origin-Resource-Policy"
        value    = items.value
        override = true
      }
    }
  }
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  comment             = var.name
  aliases             = local.hostnames
  default_root_object = "index.html"
  is_ipv6_enabled     = true
  http_version        = "http2and3"
  price_class         = var.price_class

  origin {
    origin_id                = "s3"
    domain_name              = module.bucket.regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    target_origin_id       = "s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    # Honors each object's Cache-Control, which hugo deploy sets per [deployment.matchers].
    cache_policy_id            = data.aws_cloudfront_cache_policy.optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.this.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.router.arn
    }
  }

  # Without s3:ListBucket a missing key is a 403; serve the site's 404 page either way.
  dynamic "custom_error_response" {
    for_each = [403, 404]
    content {
      error_code            = custom_error_response.value
      response_code         = 404
      response_page_path    = "/404.html"
      error_caching_min_ttl = 60
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.this.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  tags = {
    Name = var.name
  }
}
