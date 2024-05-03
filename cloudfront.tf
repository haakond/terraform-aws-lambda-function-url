# Amazon Cloudfront related resources

# Common S3 bucket for Cloudfront logs
module "cloudfront_logs" {
  count                    = var.provision_cloudfront == true ? 1 : 0
  source                   = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git?ref=8a0b697adfbc673e6135c70246cff7f8052ad95a"
  force_destroy            = true # Note: deletes all content from the bucket and then destroys the resource.
  bucket                   = "cloudfront-logs-${data.aws_caller_identity.current.account_id}"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  grant = [{
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_canonical_user_id.current.id
    },
    {
      type       = "CanonicalUser"
      permission = "FULL_CONTROL"
      id         = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id # Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
    }
  ]

  owner = {
    id = data.aws_canonical_user_id.current.id
  }
}

resource "aws_cloudfront_distribution" "lambda_function_url_demo" {
  #checkov:skip=CKV_AWS_310: Origin failover is not required for this use-case.
  #checkov:skip=CKV2_AWS_42: Custom SSL certificate is not required for this use-case.
  #checkov:skip=CKV2_AWS_32: Response headers policy not required.
  #checxkov:skip=CKV_AWS_68: WAF to come
  #checxkov:skip=CKV_AWS_111: WAF to come
  #checkov:skip=CKV2_AWS_47: WAF to come
  count    = var.provision_cloudfront == true ? 1 : 0
  provider = aws.us-east-1
  origin {
    domain_name              = local.lambda_function_url_demo_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cloudfront_oac_lambda_url.id
    origin_id                = local.lambda_function_origin_id

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_200"

  logging_config {
    include_cookies = false
    bucket          = module.cloudfront_logs.s3_bucket_bucket_domain_name
    prefix          = "lambda_function_url_demo"
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.lambda_function_origin_id

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 86400
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  tags = {
    Name = "LambdaFunctionUrlDemo"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2018"
  }
  web_acl_id = aws_wafv2_web_acl.lambda_function_url_demo.arn
}

# Amazon Cloudfront distribution OAC
resource "aws_cloudfront_origin_access_control" "cloudfront_oac_lambda_url" {
  count                             = var.provision_cloudfront == true ? 1 : 0
  name                              = "cloudfront_oac_lambda_url"
  description                       = "Policy for Lambda Function URL origins"
  origin_access_control_origin_type = "lambda"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
