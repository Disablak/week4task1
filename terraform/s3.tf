module "cloudtrail_s3_bucket" {
  source  = "cloudposse/cloudtrail-s3-bucket/aws"
  version = "0.27.0"  # Last Version

  namespace = "eg"
  stage     = "prod"
  name      = "bucket-for-crloudtrail"
}
