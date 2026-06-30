# Project Conventions

- Keep real `terraform.tfvars` files local.
- Use `terraform.tfvars.example` for shareable configuration examples.
- Keep environment-specific Terraform under `infra/terraform/envs/<env>`.
- Put reusable Terraform only in `infra/terraform/modules`.
- Keep Python source under `src/quant_pricing_engine`.
- Put tests under `tests`.
- Add model logic only with tests.
- Do not add live trading or broker execution code during the research phase.
