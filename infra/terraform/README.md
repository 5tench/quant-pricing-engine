# Terraform

Terraform is organized by environment first, with shared modules reserved for later:

```text
infra/terraform/
|-- envs/
|   `-- dev/
`-- modules/
```

The `dev` environment currently provisions the small AWS lab chassis: VPC, public subnet, internet gateway, route table, Jenkins security group, EC2 controller, key pair, and EBS volume.

## Quickstart

```bash
cd infra/terraform/envs/dev
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Apply only after reviewing the plan:

```bash
terraform apply
```

Destroy unused lab resources when finished:

```bash
terraform destroy
```

## Local Variables

Copy `terraform.tfvars.example` to `terraform.tfvars` and update the values for your account and workstation.

Keep `terraform.tfvars` local. It may contain machine-specific paths, CIDR allowlists, or account details.
