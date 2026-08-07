# Runbook

## Validate The Skeleton

```bash
make validate
```

Run this from a WSL/Linux shell. A Python virtual environment is not required for Terraform, and it is optional for the current Python skeleton.

`make validate` calls `scripts/validate.sh`. The script is a repo health check, not SCM validation. It currently:

- runs the Python skeleton test under `tests/`
- checks Terraform formatting with `terraform fmt -check`
- initializes Terraform with `-backend=false`
- validates the dev Terraform configuration

This is the same kind of command Jenkins can run later as an early CI stage.

## Terraform Dev Environment

```bash
cd infra/terraform/envs/dev
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Before applying, replace `allowed_ingress_cidrs` in `terraform.tfvars` with a trusted public /32 IP.

The Jenkins controller is bootstrapped through `user_data.sh.tftpl`. Docker Compose runs Jenkins from `docker-compose.yaml`, with Jenkins home mounted at `/srv/jenkins/home` on the attached EBS volume.

After apply, use the `jenkins_url` output to open Jenkins. Retrieve the first unlock password with the `jenkins_initial_admin_password_command` output, or SSH to the host and run:

```bash
sudo cat /srv/jenkins/home/secrets/initialAdminPassword
```

## Jenkins Controller

For the first setup pass, install the suggested plugins and create an admin user through the Jenkins UI. The initial pipeline target is the repository `ci/Jenkinsfile`, which calls `scripts/validate.sh`.

The controller currently runs in Docker Compose. Jenkins home is persisted on EBS at:

```text
/srv/jenkins/home
```

The controller remains a minimal Jenkins service. Repository validation runs on
the dedicated `ci` inbound agent defined in `ci/agent/Dockerfile`; its setup
instructions are in `ci/agent/README.md`. The agent contains Python,
Terraform, and Docker Compose tooling, but it does not receive Docker socket,
AWS credential, or repository-secret access.

## Teardown

```bash
cd infra/terraform/envs/dev
terraform destroy
```
