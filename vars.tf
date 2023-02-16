# setup les Variables
variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
    default = "us-east-1"
}

variable "AWS_AMI" {
    default = "ami-0dfcb1ef8550277af"
  
}