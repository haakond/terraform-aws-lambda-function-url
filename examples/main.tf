module "lambda_function_url_demo" {
  source = "git::https://github.com/haakond/terraform-aws-lambda-function-url.git?ref=402ca28d25da0e90214d44ef2c550bef7baa64f1" # Update to the latest commit-hash
  # As global resources related to Cloudfront needs to be provisioned in us-east-1, we pass in two different providers.
  providers = {
    aws           = aws
    aws-us-east-1 = aws-us-east-1
  }
}