# quant-pricing-engine

A research-first pricing engine for options and futures.

The point of this repo is not to build a random trading bot. The point is to build a tool that helps answer better questions: what is this contract worth, how far is market price from modeled fair value, does the idea survive testing, and what breaks the model?

This project mixes quantitative finance with cloud engineering because I want the system to be reproducible from the start. Python handles the pricing and research logic. Terraform, AWS, Docker, and Jenkins handle the infrastructure around it.

> This is for research, learning, and engineering practice. It does not place live trades.

---

## Why this exists

I am interested in futures and options, but I do not want the project to become another chart-watching notebook or a pile of scripts I cannot trust later.

The first goal is to build a pricing kernel: something that can model fair value, Greeks, and contract behavior in a way that can be tested. Once that works, the next goal is to compare those outputs against market data, log the spread between model price and market price, and start validating whether any actual edge exists.

The cloud side matters because the tool should eventually run like real software: versioned, tested, containerized, rebuildable, and deployed through a pipeline. That does not mean over-engineering everything on day one. It means building the foundation cleanly enough that the project can grow.

---

## Current Status

| Area | Status | Notes |
| --- | --- | --- |
| Terraform AWS baseline | In progress | Initial AWS infrastructure is being built first. |
| Jenkins controller | In progress | Jenkins runs through Docker Compose and keeps state on EBS. |
| Dockerized runtime | Planned | The pricing engine should run the same locally and in AWS. |
| Python pricing kernel | Planned | First target is Black-Scholes pricing and Greeks. |
| Unit tests | Planned | `pytest` should protect the math before anything deploys. |
| Backtesting | Planned | Historical validation comes after the pricing kernel works. |
| Live execution | Out of scope for now | Research, logging, and simulation first. No live orders yet. |

---

## Project Shape

```text
quant-pricing-engine/
|-- README.md
|-- ROADMAP.md
|-- Makefile
|-- pyproject.toml
|-- ci/
|   `-- Jenkinsfile
|-- docs/
|   |-- architecture.md
|   |-- codex_workflow.md
|   |-- project_conventions.md
|   |-- runbook.md
|   `-- adr/
|       `-- 0001-repo-structure.md
|-- infra/
|   `-- terraform/
|       |-- envs/
|       |   `-- dev/
|       `-- modules/
|-- scripts/
|   |-- bootstrap.sh
|   `-- validate.sh
|-- src/
|   `-- quant_pricing_engine/
`-- tests/
```

---

## Architecture Idea

The system is being built in layers.

```text
GitHub
  │
  ▼
Jenkins
  │     runs tests, validates Terraform, builds containers
  ▼
Docker
  │     keeps the Python environment consistent
  ▼
Python Pricing Engine
  │     prices contracts, calculates Greeks, compares fair value
  ▼
Market Data / Logs / Backtests
```

The first AWS version is intentionally small: one EC2 host, one persistent EBS volume, Docker, and Jenkins. That is enough to prove the CI/CD loop without dragging in unnecessary infrastructure.

Long term, the platform may move toward ECS, scheduled jobs, market-data adapters, execution simulation, and more automated recovery/rebuild behavior. For now, the focus is getting the chassis right.

---

## Infrastructure Scope

The Terraform layer is the current starting point.

Initial AWS pieces:

- VPC
- public subnet
- internet gateway
- route table
- security group
- EC2 controller host
- EC2 key pair
- EBS volume for Jenkins state
- bootstrap template for Docker Compose and Jenkins setup

The EBS volume matters because the Jenkins controller should be disposable while Jenkins state survives. Jenkins home is mounted at `/srv/jenkins/home` on the controller host.

---

## Security Notes

This is a public-cloud lab until it is hardened.

Before leaving anything online for long:

- lock SSH down to a trusted IP
- do not expose Jenkins to the whole internet
- do not commit real secrets, tokens, private keys, or local tfvars
- use `terraform.tfvars.example` in Git and keep the real `terraform.tfvars` local
- destroy unused lab resources when not working
- add remote state and locking before this becomes more than a solo sandbox

---

## Terraform Quickstart

From the repo root:

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

Tear down the lab when finished:

```bash
terraform destroy
```

---

## Pricing Engine Scope

The first real model target is Black-Scholes.

Initial Python targets:

- European call and put pricing
- Delta, Gamma, Theta, Vega, and Rho
- input validation
- known-value unit tests
- clean separation between model logic, data adapters, and execution logic

Planned next steps:

- implied volatility solving
- options-chain normalization
- futures contract support
- fair value vs. market price spread logging
- historical validation
- portfolio-level risk metrics

---

## CI/CD Direction

The pipeline has one simple job at first: do not let broken math move forward.

Planned Jenkins stages:

```text
checkout
terraform fmt
terraform validate
python install
pytest
Docker build
publish reports
```

Once the Python kernel exists, the CI loop should prove that the model still works before anything gets packaged or deployed.

---

## Working Rules

A few rules for keeping this project honest:

- no live trading before research and simulation
- no model logic without tests
- no hidden manual setup if it can be documented or automated
- no pretending a backtest is proof unless fees, slippage, and bad regimes are considered
- no treating AI-generated code as correct until tests and review back it up

The point is to build a tool that earns trust slowly.

---

## Skeleton Validation

This repo starts with a minimal importable Python package and a basic validation script:

```bash
make validate
```

The script runs the package skeleton test. If Terraform is installed, it also checks formatting and validates the dev environment. This is a repo health check, not source-control validation.

---

## Roadmap

See [`ROADMAP.md`](./ROADMAP.md) for the fuller build plan.

Near-term priorities:

1. Finish and harden the Terraform baseline.
2. Run Jenkins through Docker with persistent EBS-backed state.
3. Add a baseline `Jenkinsfile`.
4. Create the Python package structure.
5. Implement and test Black-Scholes pricing.
6. Start logging model price vs. market price.
