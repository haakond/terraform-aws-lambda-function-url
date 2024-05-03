locals {
  lambda_function_origin_id            = "lambda_function_url_demo"
  lambda_function_url_demo_domain_name = replace(replace(module.lambda_function_url_demo.lambda_function_url, "https://", ""), "/", "") #Remove https:// and trailing slash.
}