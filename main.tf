resource "aws_vpc" "hashicat" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
}

resource "aws_subnet" "hashicat" {
  vpc_id     = aws_vpc.hashicat.id
  cidr_block = var.subnet_prefix
}

resource "aws_instance" "hashicat" {
  ami                         = var.ami
  key_name                    = aws_key_pair.hashicat.key_name
  instance_type               = var.hello_tf_instance_type
  subnet_id                   = aws_subnet.hashicat.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [
    module.security-group_hashicat.security_group_id
  ]
}

module "security-group_hashicat" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "4.8.0"
  # insert required variables here
  name = "${var.prefix}-ssh-sg"
  vpc_id = aws_vpc.hashicat.id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "http-80-tcp"]
  egress_rules        = ["all-all"]
}


resource "aws_internet_gateway" "hashicat" {
  vpc_id = aws_vpc.hashicat.id
}

resource "aws_route_table" "hashicat" {
  vpc_id = aws_vpc.hashicat.id

  route {
    cidr_block = var.route_table_cidr_block
    gateway_id = aws_internet_gateway.hashicat.id
  }
}

resource "aws_route_table_association" "hashicat" {
  subnet_id      = aws_subnet.hashicat.id
  route_table_id = aws_route_table.hashicat.id
}

resource "aws_eip" "hashicat" {
  instance = aws_instance.hashicat.id
  vpc      = true
}

resource "aws_eip_association" "hashicat" {
  instance_id   = aws_instance.hashicat.id
  allocation_id = aws_eip.hashicat.id
}

resource "null_resource" "configure-cat-app" {
  depends_on = [aws_eip_association.hashicat]

  triggers = {
    build_number = timestamp()
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt -y update",
      "sleep 15",
      "sudo apt -y update",
      "sudo apt -y install apache2",
      "sudo systemctl start apache2",
      "sudo chown -R ubuntu:ubuntu /var/www/html",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.hashicat.private_key_pem
      host        = aws_eip.hashicat.public_ip
    }
  }
}

resource "tls_private_key" "hashicat" {
  algorithm = "RSA"
}

locals {
  private_key_filename = "${random_string.default.result}-ssh-key.pem"
}

resource "aws_key_pair" "hashicat" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.hashicat.public_key_openssh
}

resource "random_string" "default" {
  length = 16
}
