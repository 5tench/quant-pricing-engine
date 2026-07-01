#!/usr/bin/env sh
set -eu

PYTHONPATH=src python -m unittest discover -s tests

if command -v terraform >/dev/null 2>&1; then
  terraform -chdir=infra/terraform/envs/dev fmt -check -recursive
  terraform -chdir=infra/terraform/envs/dev init -backend=false
  terraform -chdir=infra/terraform/envs/dev validate
else
  echo "terraform not found; skipped Terraform validation"
fi
