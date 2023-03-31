stack_name = "icdc"

tags = {
  Project = "icdc"
  CreatedWith = "Terraform"
  POC = "ye.wu@nih.gov"
  Environment = "dev"
}
region = "us-east-1"

#alb
#internal_alb = true
#certificate_domain_name = "*.nci.nih.gov"
domain_name = "nci.nih.gov"


#cloud platform
cloud_platform="cloudone"
target_account_cloudone = true

#cloudfront
create_cloudfront = true
create_files_bucket = false
cloudfront_distribution_bucket_name = "datacommons-gmb-files"
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
