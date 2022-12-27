terraform {
  backend "s3" {
    bucket         = "terraform-state20200913104433379400000001"
    key            = "module-vpc-test"
    region         = "eu-west-2"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:eu-west-2:889199313043:key/dcebdb94-dd79-4d33-b4f4-b00aee818b6d"
    dynamodb_table = "terraform-state-lock"
    profile        = "adm_rhook_cli"
  }
}
