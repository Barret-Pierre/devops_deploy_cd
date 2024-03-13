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

variable "key_name" {
  description = "Value of the key_name"
  type        = string
}

variable "private_key" {
  description = "Value of the private key"
  type        = string
}

variable "vpc_security_group_id" {
  description = "Value of the secutiry group id"
  type        = string
}

