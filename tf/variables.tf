# variables

variable "ami" {
  description = "AMI of image for the EC2 instances, currently only SUSE is supported"
  type = string
  default = "ami-0e9777e8a2a5b54fb"
}

variable "aws_profile" {
  description = "AWS CLI Profile"
  type = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "prefix" {
  description = "Prefix of the EC2 instance name"
  type        = string
  default     = "my"
}


# domain
variable "route53_zone_id" {
  type        = string
}
variable "route53_domain" {
  type        = string
}
variable "route53_subdomain" {
  type        = string
}

# instance tags
variable "aws_tags" {
  description = "Default tags to use for AWS"
  type        = map(string)
}

# ssh keyname
variable "key_name" {
  description = "Name of Keypair to use for SSH"
  type        = string
}


# security group source ips:
variable "ip_cidr_me" {
  type        = string
}
variable "ip_cidr_work" {
  type        = string
}

# instances
variable "node_count" {
  default = "3"
}

variable "instance_type" {
  description = "Size of the EC2 instance"
  type        = string
  default     = "t3.medium"
}

variable "volume_type" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "gp2"
}

variable "volume_size" {
  description = "Value of the Name tag for the EC2 instance"
  type        = number
  default     = 100
}

# vpc
# vpc:
variable "dnsSupport" {
  default = true
}
variable "dnsHostNames" {
  default = true
}
variable "mapPublicIP" {
  default = true
}
variable "vpcCIDRblock" {
  default = "10.0.0.0/16"
}
variable "subnetCIDRblock" {
  default = "10.0.1.0/24"
}
variable "subnet2CIDRblock" {
  default = "10.0.2.0/24"
}
variable "destinationCIDRblock" {
  default = "0.0.0.0/0"
}
variable "ingressCIDRblock" {
  default = [ "0.0.0.0/0" ]
}
variable "instanceTenancy" {
  default = "default"
}
variable "availability_zone" {
  default = "us-east-1a"
}
variable "private_ips" {
  default = ["10.0.1.160"]
}


