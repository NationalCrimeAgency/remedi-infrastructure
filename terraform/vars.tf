# REMEDI configuration

variable "server_instances" {
  description = "The number of REMEDI servers to deploy (per language)"
  default = 1
}

variable "languages" {
  description = "Array of languages (e.g. nl) supported for translation"
  type = "list"
  default = ["nl"]
}

variable "language_names" {
  description = "Array of language names (e.g. Dutch) supported for translation, in the same order as languages"
  type = "list"
  default = ["Dutch"]
}

variable "model_volume_size" {
  description = "Size of the EBS volume (in GB) that will hold the REMEDI models"
  default = "100"
}

variable "model_bucket" {
  description = "The name of the S3 bucket containing the models (not created by the module)"
}

# Environment configuration

variable "cidrs" {
  description = "CIDRs from which access to the REMEDI servers will be required"
  type = "list"
}

variable "kms_policy_arn" {
  description = "ARN of the KMS Policy"
}

variable "ami_id" {
  description = "ID of the REMEDI AMI as built by the Packer configuration"
}

variable "subnet_id" {
  description = "ID of the subnet on which to set up the REMEDI infrastructure"
}

variable "vpc_id" {
  description = "ID of VPC"
}

variable "zone_id" {
  description = "ID of the Route 53 zone to set up aliases on"
}

variable "key_name" {
  description = "Name of the key pair used for accessing this instance"
}

# Optional configuration

variable "tags" {
  description = "Additional tags to add on to instances"
  type = "map"
  default = {}
}

variable "truecaser" {
  description = "The name of the TrueCaser to use, set to uk.gov.nca.remedi.utils.StanfordTrueCaser to enable true casing on English"
  default = "uk.gov.nca.remedi.utils.NoOpTrueCaser"
}