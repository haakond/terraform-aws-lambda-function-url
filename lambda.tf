# AWS Lambda Function
module "lambda_function_url_demo" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-lambda.git?ref=f7866811bc1429ce224bf6a35448cb44aa5155e7"

  function_name              = "lambda-function-url-demo"
  description                = "Lambda Function URL Demo"
  handler                    = "index.lambda_handler"
  runtime                    = "python3.12"
  source_path                = "${path.module}/src/lambda-function-url-demo/index.py"
  create_lambda_function_url = true
  authorization_type         = "AWS_IAM"
  timeout                    = 30
  cors = {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 60
  }

  tags = {
    Name = "LambdaFunctionUrlDemo"
  }
}

resource "aws_lambda_permission" "allow_cloudfront" {
  count         = var.provision_cloudfront == true ? 1 : 0
  statement_id  = "AllowCloudFrontServicePrincipal"
  action        = "lambda:InvokeFunctionUrl"
  function_name = module.lambda_function_url_demo.lambda_function_name
  principal     = "cloudfront.amazonaws.com"
  source_arn    = aws_cloudfront_distribution.lambda_function_url_demo[0].arn
}