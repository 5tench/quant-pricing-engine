# Core networking and regional deployment configuration
region                         = "us-east-1"
availability_zones             = ["us-east-1a", "us-east-1b"]
vpc_name                       = "quantops-vpc"
vpc_cidr                       = "10.0.0.0/16"
subnet_name                    = "quantops-public-subnet"
subnet_cidr                    = "10.0.1.0/24"
igw_name                       = "quantops-igw"
tfroute                        = "quantops-public-rt"
tfroute_destination_cidr       = "0.0.0.0/0"
tfroute_table_association_name = "quantops-public-assoc"

# Firewall and network access parameters
terraform_sg             = "quantops-jenkins-sg"
terraform_sg_description = "Allow SSH and Jenkins web traffic"
ip_protocol              = "tcp"
ingress_description      = "Inbound traffic rule"
egress_description       = "Outbound traffic rule"

# Dynamic map variables defining your open ports
ingress_rules = {
  "ssh"     = 22
  "jenkins" = 8080
}

egress_rules = {
  "all_outbound" = 0
}

# Compute host and deployment key specifications
ami_id             = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS (us-east-1)
instance_type      = "t3.medium"
tfinstance_jenkins = "quantops-jenkins-controller"
public_key_path    = "~/.ssh/id_rsa.pub"
key_pair_name      = "quantops-deployer-key"

# Persistent storage allocation
ebs_volume_size  = 10
tfvolume_jenkins = "quantops-jenkins-state-ebs"