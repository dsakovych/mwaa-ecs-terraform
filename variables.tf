variable "access_key" {
  type        = string
  description = "AWS access key"
}

variable "secret_key" {
  type        = string
  description = "AWS secret key"
}

variable "region" {
  type        = string
  description = "AWS region where resources will be deployed."
}

variable "prefix" {
  type        = string
  description = "A prefix to use when naming resources."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnets' CIDR blocks."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnets' CIDR blocks."
}

variable "mwaa_max_workers" {
  type        = number
  description = "Maximum number of MWAA workers."
  default     = 2
}
