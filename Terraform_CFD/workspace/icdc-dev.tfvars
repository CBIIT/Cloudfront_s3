stack_name = "icdc-cache"

tags = {
  Project = "icdc-cache"
  CreatedWith = "Terraform"
  POC = "ye.wu@nih.gov"
  Environment = "dev-2"
}
region = "us-east-1"

#alb
internal_alb = true
#certificate_domain_name = "*.nci.nih.gov"
domain_name = "nci.nih.gov"


#cloud platform
cloud_platform="cloudone"
target_account_cloudone = true

#cloudfront
create_cloudfront = true
create_files_bucket = false
cloudfront_distribution_bucket_name = "nci-icdc-temp-files"
cloudfront_slack_channel_name = "cloudone-cloudfront-wafv2"
alarms = {
  error4xx = {
    name = "4xxErrorRate"
    threshold = 10
  }
  error5xx = {
    name = "5xxErrorRate"
    threshold = 10
  }
}
slack_secret_name = "cloudfront-slack"
