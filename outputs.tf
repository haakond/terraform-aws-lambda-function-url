output "lambda_function_url_demo_arn" {
  value       = module.lambda_function_url_demo.lambda_function_arn
  description = "Lambda Function URL Demo ARN"
  sensitive   = false
}

output "lambda_function_url_demo_url" {
  value       = module.lambda_function_url_demo.lambda_function_url
  description = "Lambda Function URL Demo URL"
  sensitive   = false
}