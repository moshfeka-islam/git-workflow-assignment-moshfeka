terraform {
  backend "s3" {
    bucket         = "platform-tfstate"
    key            = "global/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
