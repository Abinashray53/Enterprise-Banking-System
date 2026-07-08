terraform {

  backend "s3" {

    bucket = "enterprise-bank-terraform-state"

    key = "aws/terraform.tfstate"

    region = "ap-south-1"

    encrypt = true

  }

}