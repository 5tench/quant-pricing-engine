# The public IP address of your new compute host
output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins EC2 instance"
  value       = aws_instance.jenkins_controller.public_ip
}

# Quick-copy SSH command using your local key
output "ssh_connection_string" {
  description = "Command to SSH directly into the Jenkins host"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.jenkins_controller.public_ip}"
}

# The ID of the generated VPC network boundary
output "vpc_id" {
  description = "ID of the primary VPC"
  value       = aws_vpc.main.id
}