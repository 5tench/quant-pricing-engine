# The public IP address of your new compute host
output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins EC2 instance"
  value       = aws_instance.jenkins_controller.public_ip
}

# Quick-copy SSH command using your local key
output "ssh_connection_string" {
  description = "Command to SSH directly into the Jenkins host"
  value       = "ssh -i ${replace(var.public_key_path, ".pub", "")} ec2-user@${aws_instance.jenkins_controller.public_ip}"
}

# Browser URL for the Jenkins controller
output "jenkins_url" {
  description = "HTTP URL for the Jenkins web interface"
  value       = "http://${aws_instance.jenkins_controller.public_ip}:8080"
}

# Quick-copy command for the JCasC-generated administrator credential
output "jenkins_initial_admin_password_command" {
  description = "Command to retrieve the controller-local Jenkins admin password after first boot"
  value       = "ssh -i ${replace(var.public_key_path, ".pub", "")} ec2-user@${aws_instance.jenkins_controller.public_ip} 'sudo grep \"^JENKINS_ADMIN_PASSWORD=\" /srv/jenkins/controller.env'"
}

# The ID of the generated VPC network boundary
output "vpc_id" {
  description = "ID of the primary VPC"
  value       = aws_vpc.main.id
}
