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

# Quick-copy remote health check for the live controller
output "jenkins_controller_status_command" {
  description = "Command to inspect controller and CI-agent status and recent logs over SSH"
  value       = "ssh -i ${replace(var.public_key_path, ".pub", "")} ec2-user@${aws_instance.jenkins_controller.public_ip} 'cd /srv/jenkins && if sudo test -f ci-agent.env; then sudo docker compose --env-file ci-agent.env --profile ci ps && sudo docker compose --env-file ci-agent.env --profile ci logs --tail=100 jenkins ci-agent; else echo \"CI-agent runtime file is not available; showing bootstrap status instead.\"; sudo cloud-init status --long; sudo tail -n 100 /var/log/jenkins-bootstrap.log; fi'"
}

# Quick-copy command for the JCasC-generated administrator credential
output "jenkins_initial_admin_password_command" {
  description = "Command to retrieve the controller-local Jenkins admin password after first boot"
  value       = "ssh -i ${replace(var.public_key_path, ".pub", "")} ec2-user@${aws_instance.jenkins_controller.public_ip} sudo grep ^JENKINS_ADMIN_PASSWORD= /srv/jenkins/controller.env"
}

# The ID of the generated VPC network boundary
output "vpc_id" {
  description = "ID of the primary VPC"
  value       = aws_vpc.main.id
}
