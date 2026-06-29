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
    sudo apt-get update -y
    sudo apt-get install -y docker.io docker-compose
    
    TARGET_DEV=""
    for dev in /dev/nvme1n1 /dev/xvdh /dev/sdh; do
      if [ -b "$dev" ]; then
        TARGET_DEV="$dev"
        break
      fi
    done

    if [ -n "$TARGET_DEV" ]; then
      sudo blkid "$TARGET_DEV" || sudo mkfs -t ext4 "$TARGET_DEV"
      sudo mkdir -p /var/lib/docker
      sudo mount "$TARGET_DEV" /var/lib/docker
      echo "$TARGET_DEV /var/lib/docker ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
    fi

    sudo systemctl daemon-reload
    sudo systemctl start docker
    sudo systemctl enable docker
  EOF
}