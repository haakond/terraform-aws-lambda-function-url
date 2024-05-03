
# Web Application Firewall resources

# Common S3 bucket for WAF logs
resource "aws_cloudwatch_log_group" "waf_cloudwatch_logs" {
  #checkov:skip=CKV_AWS_158: KMS encryption unnecessary for this use-case.
  count             = var.provision_cloudfront == true ? 1 : 0
  provider          = aws.us-east-1
  name              = "aws-waf-logs-lambda-function-url-demo"
  retention_in_days = 365
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_cloudwatch_logs_config" {
  count                   = var.provision_cloudfront == true ? 1 : 0
  provider                = aws.us-east-1
  log_destination_configs = [aws_cloudwatch_log_group.waf_cloudwatch_logs[0].arn]
  resource_arn            = aws_wafv2_web_acl.lambda_function_url_demo[0].arn
}

resource "aws_cloudwatch_log_resource_policy" "waf_cloudwatch_logs_resource_policy" {
  count           = var.provision_cloudfront == true ? 1 : 0
  provider        = aws.us-east-1
  policy_document = data.aws_iam_policy_document.waf_logging[0].json
  policy_name     = "webacl-policy-waf-lambda-function-url-demo"
}

# Create a Web ACL
resource "aws_wafv2_web_acl" "lambda_function_url_demo" {
  #checkov:skip=CKV2_AWS_31: WAF2 logging configuration not necessary for this use-case.
  count       = var.provision_cloudfront == true ? 1 : 0
  provider    = aws.us-east-1
  name        = "lambda_function_url_demo"
  description = "Web ACL with managed rule groups for lambda_function_url_demo"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = false
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "AWSManagedRulesKnownBadInputsRuleSet"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "web-acl-lambda-function-url-demo"
    sampled_requests_enabled   = true
  }
}
