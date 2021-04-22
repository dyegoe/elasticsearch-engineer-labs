variable "region" {
  type        = string
  description = "An AWS region must be provided. e.g. eu-central-1, ap-northeast-1"
  default     = "eu-north-1"

  validation {
    condition     = can(regex("^(us|ap|ca|cn|eu|sa)-(central|(north|south)?(east|west)?)-[1-3]$", var.region))
    error_message = "You must provide a valid AWS region. e.g. eu-central-1 or ap-northeast-1."
  }
}

variable "ami_id" {
  type        = string
  description = "A valid AWS ami_id must be provided. e.g. ami-02baf2b4223a343e8."
  default     = "ami-02baf2b4223a343e8"

  validation {
    condition     = can(regex("^ami-[0-9a-z]{8,17}$", var.ami_id))
    error_message = "You must provide a valid AWS ami_id. e.g. ami-02baf2b4223a343e8."
  }
}

variable "ssh_public_key" {
  type        = string
  description = "A valid SSH public key. e.g. 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ...'"
  sensitive   = true
}

variable "ips_list" {
  type        = list(string)
  description = "A list with IPs to allow access in the security group."
  default = [
    "0.0.0.0/0"
  ]
}

variable "cidr" {
  type        = string
  description = "A valid CIDR notation to create VPC. e.g. 10.31.85.0/24"
  default     = "10.31.85.0/24"

  validation {
    condition     = can(regex("^(10|172|192).[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}/([8-9]|1[0-9]|2[0-6])$", var.cidr))
    error_message = "A valid CIDR notation to create VPC. I can't be smaller than /26. e.g. 10.31.85.0/24."
  }
}
