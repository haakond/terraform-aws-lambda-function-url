module "lambda_function_url_demo" {
  source = "git::https://github.com/haakond/terraform-aws-lambda-function-url.git?ref=861e626b4563417c5c35cabfa84d3eaa1bd7aaa4"

  # As global resources related to Cloudfront and WAF needs to be provisioned in us-east-1, we pass in two different providers.
  # Reference: https://developer.hashicorp.com/terraform/language/modules/develop/providers#passing-providers-explicitly
  provision_cloudfront = false # Set to false on the first run, set to true on the second run, because of circular dependencies.
  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}