resource "aws_cloudtrail" "main" {
  name                          = "my-cloudtrail"
  s3_bucket_name                = module.cloudtrail_s3_bucket.bucket_id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  enable_logging                = true
}