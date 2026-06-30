# Runbook

## Validate The Skeleton

```bash
make validate
```

This runs the Python skeleton test. If Terraform is installed, it also checks and validates the dev Terraform environment.

## Terraform Dev Environment

```bash
cd infra/terraform/envs/dev
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Before applying, replace `allowed_ingress_cidrs` in `terraform.tfvars` with a trusted public IP CIDR such as `203.0.113.10/32`.

## Teardown

```bash
cd infra/terraform/envs/dev
terraform destroy
```
