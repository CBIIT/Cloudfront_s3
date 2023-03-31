variable "tags" {
  description = "tags to associate with this instance"
  type = map(string)
}

variable "alarms" {
  description = "alarms to be configured"
  type = map(map(string))
  default = null
}

variable "cloudfront_distribution_bucket_name" {
  description = "specify the name of s3 bucket for cloudfront"
  type = string
  default = null
}

variable "stack_name" {
  description = "name of the project"
  type = string
}

variable "target_account_cloudone"{
  description = "to add check conditions on whether the resources are brought up in cloudone or not"
  type        = bool
  default =   true
}

variable "create_cloudfront" {
  description = "create cloudfront or not"
  type = bool
  default = true
}

variable "create_files_bucket" {
  description = "indicate if you want to create files bucket or use existing one"
  type = bool
  default = false
}

variable "domain_name" {
  description = "domain name for the application"
  type = string
}

variable "region" {
  description = "aws region to use for this resource"
  type = string
  default = "us-east-1"
}

variable "cloudfront_slack_channel_name" {
  type = string
  description = "cloudfront slack name"
  default = null
}

variable "slack_secret_name" {
  type = string
  description = "name of cloudfront slack secret"
  default = null
}

variable "s3_force_destroy" {
  description = "force destroy bucket"
  default = true
  type = bool
}

variable "bucket_name" {
  description = "s3 bucket name"
  type = string
  default = "null"
}
