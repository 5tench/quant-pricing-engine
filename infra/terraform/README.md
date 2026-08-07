# Terraform

Terraform is organized by environment first, with shared modules reserved for later:

```text
infra/terraform/
|-- envs/
|   `-- dev/
`-- modules/
```

The `dev` environment currently provisions the small AWS lab chassis: VPC, public subnet, internet gateway, route table, Jenkins security group, EC2 controller, key pair, and EBS volume.

The controller uses the latest official RHEL 9 x86_64 AMI in the selected Region. It is resolved at plan time, so no AMI ID belongs in `terraform.tfvars`. Accept the RHEL AWS Marketplace terms once for the AWS account before the first apply. RHEL's subscription-included image can incur an hourly software charge; destroy the environment after each lab session.

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
