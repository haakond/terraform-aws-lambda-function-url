variable "provision_cloudfront" {
  type        = bool
  default     = false
  description = "Toggle for provisioning Cloudfront resources as a second module call, to avoid issues with circular dependencies for Lambda permissions."
}