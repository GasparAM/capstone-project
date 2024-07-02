cidr_block_vpc    = "10.0.0.0/16"
iam_name = "rdsFromEc2"
compute_instance = "t3.micro"
rds_instance = "db.t3.micro"
# cidr_block_subnet = "10.0.1.0/24"
ingress_ips       = ["139.45.214.21/32", "0.0.0.0/0"]
tags = {
  Name    = "Terraform_managed"
  Project = "t1_t2_path"
  Owner   = "gavetisyan"
  Matcher = "t1_infrastructure"
}

sg_ingress = {
  https = {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  http = {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ssh = {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
}

sg_egress = {
  all_traffic = {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}