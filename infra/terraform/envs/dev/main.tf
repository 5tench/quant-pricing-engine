# Dev network boundary for the Jenkins controller.
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.igw_name
  }
}

# Single public subnet for the current lab controller.
resource "aws_subnet" "public_tier" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_name
  }
}

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

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_tier.id
  route_table_id = aws_route_table.public_rt.id
}

# Keep ingress restricted to trusted /32 CIDRs while this stays public.
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

resource "aws_key_pair" "deployer_key" {
  key_name   = var.key_pair_name
  public_key = file(pathexpand(var.public_key_path))
}

# Controller bootstrap installs Docker, mounts EBS, and starts Compose.
resource "aws_instance" "jenkins_controller" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_tier.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = aws_key_pair.deployer_key.key_name
  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    docker_compose_content = file("${path.module}/docker-compose.yaml")
  })

  tags = {
    Name = var.tfinstance_jenkins
  }
}

# Jenkins state lives on this EBS volume through /srv/jenkins/home.
resource "aws_ebs_volume" "jenkins_volume" {
  availability_zone = var.availability_zones[0]
  size              = var.ebs_volume_size
  type              = "gp3"

  tags = {
    Name = var.tfvolume_jenkins
  }
}

resource "aws_volume_attachment" "jenkins_attachment" {
  device_name  = "/dev/sdh"
  volume_id    = aws_ebs_volume.jenkins_volume.id
  instance_id  = aws_instance.jenkins_controller.id
  force_detach = true
}
