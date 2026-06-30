# Provisions the core Virtual Private Cloud network boundary
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# Attaches an Internet Gateway to allow external web traffic
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.igw_name
  }
}

# Creates the public subnet anchored to your first Availability Zone
resource "aws_subnet" "public_tier" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_name
  }
}

# Defines the routing table directing local traffic to the Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.tfroute_destination_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.tfroute
  }
}

# Binds the public subnet to the internet-bound route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_tier.id
  route_table_id = aws_route_table.public_rt.id
}

# Configures dynamic firewall rules based on your ingress/egress maps
resource "aws_security_group" "jenkins_sg" {
  name        = var.terraform_sg
  description = var.terraform_sg_description
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = var.ingress_description
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = var.ip_protocol
      cidr_blocks = var.allowed_ingress_cidrs
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      description = var.egress_description
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name = var.terraform_sg
  }
}

# Registers your local SSH public key with AWS for instance access
resource "aws_key_pair" "deployer_key" {
  key_name   = var.key_pair_name
  public_key = file(pathexpand(var.public_key_path))
}

# Deploys the EC2 host and injects the automated bootstrap script
resource "aws_instance" "jenkins_controller" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_tier.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = aws_key_pair.deployer_key.key_name
  user_data              = var.tfinstance_jenkins_startup_script

  tags = {
    Name = var.tfinstance_jenkins
  }
}

# Provisions a persistent stateful storage drive in the exact same AZ
resource "aws_ebs_volume" "jenkins_volume" {
  availability_zone = var.availability_zones[0]
  size              = var.ebs_volume_size
  type              = "gp3"

  tags = {
    Name = var.tfvolume_jenkins
  }
}

# Mounts the EBS volume to the EC2 instance with safe auto-detach enabled
resource "aws_volume_attachment" "jenkins_attachment" {
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.jenkins_volume.id
  instance_id  = aws_instance.jenkins_controller.id
  force_detach = true
}
