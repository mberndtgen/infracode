# AWS basic settings

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

# AWS security group 

resource "aws_security_group" "server" {
  name        = "${var.hostname}.${var.domain} security group"
  description = "Server ${var.hostname}.${var.domain}"
  vpc_id      = "${var.aws_vpc_id}"
  tags = {
    Name      = "${var.hostname}.${var.domain} security group"
  }
}


# SSH

resource "aws_security_group_rule" "server_allow_22_tcp_allowed_cidrs" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${split(",", var.allowed_cidrs)}"]
  security_group_id = "${aws_security_group.server.id}"
}


# HTTP (nginx)

resource "aws_security_group_rule" "server_allow_80_tcp" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.server.id}"
}


# HTTPS (nginx)

resource "aws_security_group_rule" "server_allow_443_tcp" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.server.id}"
}


# Egress: ALL

resource "aws_security_group_rule" "server_allow_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.server.id}"
}

# get an elastic ip address

resource "aws_eip" "elastic_ip" {
  vpc = true
  instance = "${aws_instance.server.id}"
  associate_with_private_ip = "${aws_instance.server.private_ip}"
}

# create dns entry

resource "aws_route53_record" "public_dns" {
   zone_id = "${var.aws_route53_zone_id}"
   name = "${var.hostname}"
   type = "A"
   ttl = "300"
   records = ["${aws_eip.elastic_ip.public_ip}"]
}

#
# Provision server
#

resource "aws_instance" "server" {
  ami           = "${lookup(var.ami_map, "${var.ami_os}-${var.aws_region}")}"
  instance_type = "${var.aws_flavor}"
  associate_public_ip_address = "${var.public_ip}"
  subnet_id     = "${var.aws_subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.server.id}"]
  key_name      = "${var.aws_key_name}"
  tags = {
    Name        = "${var.hostname}.${var.domain}"
    Description = "${var.tag_description}"
  }
  root_block_device = {
    # https://www.terraform.io/docs/providers/aws/r/instance.html#block-devices
    delete_on_termination = "${var.root_delete_termination}"
    volume_size = "${var.root_volume_size}"
    volume_type = "${var.root_volume_type}"
  }
  connection {
    host        = "${self.public_ip}"
    user        = "${lookup(var.ami_usermap, var.ami_os)}"
    private_key = "${file(var.aws_private_key_file)}"
  }

  # Setup

  provisioner "remote-exec" {
    script = "${path.module}/files/disable_firewall.sh"
  }
  
}


