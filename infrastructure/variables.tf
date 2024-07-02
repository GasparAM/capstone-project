variable "ingress_ips" {}

variable "db_name" {
  type = string
  default = "petclinic"
  
}

variable "sg_ingress" {
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default = null
}

variable "sg_egress" {
  type = map(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
  }))
  default = null
}

variable "db_version" {
  type = string
  default = "5.7"
  
}

variable "asg_desired_capacity" {
  type = string
  default = 3
}

variable "asg_min_capacity" {
  type = string
  default = 3
}

variable "asg_max_capacity" {
  type = string
  default = 3
}

variable "ami" {
  type = string
  default = "ami-0577c11149d377ab7"
}

variable "compute_instance" {}

variable "rds_instance" {}

variable "cidr_block_vpc" {}

variable "iam_name" {}

variable "tags" {}

locals {
  subnetcalc = cidrsubnets(var.cidr_block_vpc, 8, 8, 8, 8, 8)
  privsubs   = element(chunklist(local.subnetcalc, 3), 1)
  pubsubs   = element(chunklist(local.subnetcalc, 3), 0)
  subnets_private = {
    "private-a" = {
      cidr_block        = local.privsubs[0]
      availability_zone = "eu-north-1a"
    }
    "private-b" = {
      cidr_block = local.privsubs[1]
      availability_zone = "eu-north-1b"
    }
    # "private-c" = {
    #   cidr_block = local.privsubs[2]
    #   availability_zone = "en-north-1c"
    # }
  }
  subnets_public = {
    "public-a" = {
      cidr_block        = local.pubsubs[0]
      availability_zone = "eu-north-1a"
    }
    "public-b" = {
      cidr_block = local.pubsubs[1]
      availability_zone = "eu-north-1b"
    }
    "public-c" = {
      cidr_block = local.pubsubs[2]
      availability_zone = "eu-north-1c"
    }
  }
}