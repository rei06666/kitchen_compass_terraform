# variables.tf
variable "system" {
  description = "システム名"
  type        = string
}

variable "env" {
  description = "環境名"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "domain_name" {
  description = "ドメイン名"
  type        = string
}

variable "key_name" {
  description = "キーペア名"
  type        = string
}