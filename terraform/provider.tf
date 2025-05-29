terraform {
  backend "s3" {
    bucket = "w4t1-terraform-states"
    key    = "state"
    region = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}