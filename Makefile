SHELL := /bin/sh

.PHONY: validate test terraform-fmt terraform-validate

validate:
	sh ./scripts/validate.sh

test:
	PYTHONPATH=src python -m unittest discover -s tests

terraform-fmt:
	cd infra/terraform/envs/dev && terraform fmt -recursive

terraform-validate:
	cd infra/terraform/envs/dev && terraform init -backend=false && terraform validate
