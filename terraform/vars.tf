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

variable "processor_certificate" {
  description = "The contents of the REMEDI Processor certificate (.crt) file. If not supplied, then TLS will be disabled for the REMEDI Processor."
  default = ""
}

variable "processor_certificate_key" {
  description = "The contents of the REMEDI Processor certificate key (.key) file. If not supplied, then TLS will be disabled for the REMEDI Processor."
  default = ""
}

variable "balancer_certificate" {
  description = "The contents of the REMEDI Balancer certificate (.crt) file. If not supplied, then TLS will be disabled for the REMEDI Balancer."
  default = ""
}

variable "balancer_certificate_key" {
  description = "The contents of the REMEDI Balancer certificate key (.key) file. If not supplied, then TLS will be disabled for the REMEDI Balancer."
  default = ""
}

variable "ciphers" {
  description = "Ciphers to be used by REMEDI (if TLS is enabled)"
  default = "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK"
}