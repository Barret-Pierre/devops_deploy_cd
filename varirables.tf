variable "ami" {
  description = "Value of the ami"
  type        = string
  default = "ami-0b7282dd7deb48e78"
}

variable "region" {
  description = "Value of the cluster region"
  type        = string
  default = "eu-west-3"
}

variable "vpc_security_group_id" {
  description = "Value of the AWS secutiry group id"
  type        = string
}

variable "key_name" {
  description = "Value of the AWS key name"
  type        = string
}

variable "private_key" {
  description = "Value of the AWS private key"
  type        = string
}

