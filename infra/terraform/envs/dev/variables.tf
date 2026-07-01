# Core networking and regional deployment configuration
variable "region" {
  description = "AWS region for deployment"
  type        = string
}

variable "availability_zones" {
  description = "Target AWS availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_name" {
  description = "Name tag for the public subnet"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "igw_name" {
  description = "Name tag for the Internet Gateway"
  type        = string
}

variable "tfroute" {
  description = "Name tag for the route table"
  type        = string
}

variable "tfroute_destination_cidr" {
  description = "Destination CIDR for the default route"
  type        = string
}

variable "tfroute_table_association_name" {
  description = "Name tag for the route table association"
  type        = string
}

# Firewall and network access parameters
variable "terraform_sg" {
  description = "Security group name"
  type        = string
}

variable "terraform_sg_description" {
  description = "Description for the security group"
  type        = string
}

variable "ip_protocol" {
  description = "IP protocol for security group rules"
  type        = string
}

variable "ingress_description" {
  description = "Description for inbound traffic rules"
  type        = string
}

variable "egress_description" {
  description = "Description for outbound traffic rules"
  type        = string
}

variable "ingress_rules" {
  description = "Map of inbound rules and target ports"
  type        = map(number)
}

variable "allowed_ingress_cidrs" {
  description = "CIDR blocks allowed to reach SSH and Jenkins. Use a trusted /32 while this is a public lab."
  type        = list(string)
  default     = ["127.0.0.1/32"]
}

variable "egress_rules" {
  description = "Map of outbound rules and target ports"
  type        = map(number)
}

# Compute host and deployment key specifications
variable "ami_id" {
  description = "AMI ID for the EC2 controller host"
  type        = string
}

variable "instance_type" {
  description = "EC2 compute instance sizing type"
  type        = string
}

variable "tfinstance_jenkins" {
  description = "Name tag for the EC2 compute instance"
  type        = string
}

variable "public_key_path" {
  description = "Local file path to the SSH public key"
  type        = string
}

variable "key_pair_name" {
  description = "AWS EC2 key pair name"
  type        = string
}

# Persistent storage allocation
variable "ebs_volume_size" {
  description = "Storage capacity of the EBS volume in GB"
  type        = number
  default     = 10
}

variable "tfvolume_jenkins" {
  description = "Name tag for the persistent EBS volume"
  type        = string
  default     = "quantops-jenkins-state-ebs"
}

# Automated initialization script
variable "tfinstance_jenkins_startup_script" {
  description = "Bootstrap script to provision Docker and mount storage"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    apt-get update -y
    apt-get install -y docker.io docker-compose
    systemctl stop docker || true

    TARGET_DEV=""
    for attempt in $(seq 1 60); do
      for dev in /dev/nvme1n1 /dev/xvdh /dev/sdh; do
        if [ -b "$dev" ]; then
          TARGET_DEV="$dev"
          break 2
        fi
      done
      sleep 10
    done

    if [ -z "$TARGET_DEV" ]; then
      echo "No attached Jenkins EBS device found after waiting." >&2
      exit 1
    fi

    if ! blkid "$TARGET_DEV"; then
      mkfs -t ext4 "$TARGET_DEV"
    fi

    mkdir -p /var/lib/docker
    if ! mountpoint -q /var/lib/docker; then
      mount "$TARGET_DEV" /var/lib/docker
    fi

    DEVICE_UUID=$(blkid -s UUID -o value "$TARGET_DEV")
    if ! grep -q "$DEVICE_UUID" /etc/fstab; then
      echo "UUID=$DEVICE_UUID /var/lib/docker ext4 defaults,nofail 0 2" >> /etc/fstab
    fi

    systemctl daemon-reload
    systemctl enable docker
    systemctl start docker

    docker network create jenkins || true
    if docker ps -a --format '{{.Names}}' | grep -qx jenkins; then
      docker start jenkins
    else
      docker run -d \
        --name jenkins \
        --restart unless-stopped \
        --network jenkins \
        -p 8080:8080 \
        -p 50000:50000 \
        -v jenkins_home:/var/jenkins_home \
        jenkins/jenkins:lts
    fi
  EOF
}
