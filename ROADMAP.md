# quant-pricing-engine Roadmap

This roadmap is the working plan for turning `quant-pricing-engine` into a useful research tool.

The main goal is not to make a flashy repo. The main goal is to build something that helps me understand futures and options better, price contracts more objectively, test ideas, and eventually compare model output against real market behavior.

The DevOps side is part of the tool, not the whole identity of the project. I want the platform to be reproducible, containerized, tested, and deployable because that is how the work becomes trustworthy.

---

## North Star

Build a system that can eventually answer these questions:

- What should this contract be worth under the model?
- What are the Greeks and risk sensitivities?
- How far is market price from modeled fair value?
- Is that difference meaningful after spread, fees, and slippage?
- Has the idea held up historically?
- What market regime breaks it?
- Can the whole platform be rebuilt without guessing what I did last time?

No live trading until the research, testing, and risk layers are real.

---

## Phase 0 — Infrastructure Chassis

**Goal:** Get the project foundation running in AWS without making it heavier than it needs to be.

### Build

- Terraform directory at the repo root
- VPC, public subnet, internet gateway, and route table
- EC2 controller host
- security group with restricted ingress
- EC2 key pair
- EBS volume for Jenkins state
- Docker installed on the host
- Jenkins running as a container

### Done when

- `terraform fmt -recursive` passes
- `terraform validate` passes
- `terraform plan` is clean and reviewed
- EC2 comes up successfully
- SSH works from an approved IP only
- Jenkins is not wide open to the internet
- EBS attaches and survives reboot/rebuild behavior
- Docker starts automatically
- README explains apply, validate, and destroy

### Watch out for

- accidentally committing real `terraform.tfvars`
- leaving port 22 or 8080 open to `0.0.0.0/0`
- creating AWS resources that sit around unused
- doing too much infra before the pricing code exists

---

## Phase 1 — Jenkins / CI Baseline

**Goal:** Prove the repo can test itself.

### Build

- `docker-compose.yaml` for Jenkins
- persistent Jenkins home on EBS
- baseline `Jenkinsfile`
- GitHub integration through webhook or polling
- Terraform validation stage
- placeholder Python test stage until the pricing kernel exists

### Done when

- Jenkins can clone the repo
- Jenkins can run Terraform formatting/validation
- Jenkins can run `pytest`
- failed tests fail the build
- Jenkins state survives host restart
- the pipeline is defined in code, not only clicked together in the UI

---

## Phase 2 — Pricing Kernel MVP

**Goal:** Build the math core that the rest of the project depends on.

### Build

- Python package under `src/`
- dependency management through `pyproject.toml` or a simple starter equivalent
- Black-Scholes pricer for European calls and puts
- Greeks: Delta, Gamma, Theta, Vega, Rho
- input validation
- deterministic unit tests
- a small CLI or example script

### Done when

- known Black-Scholes examples match expected values within tolerance
- invalid inputs fail cleanly
- tests pass locally
- tests pass in Jenkins
- model code is separate from infrastructure code
- README includes a small usage example

### Principle

This is where the project starts becoming a tool instead of just infrastructure. The math does not need to be perfect forever, but it needs to be testable immediately.

---

## Phase 3 — Market Data and Spread Logging

**Goal:** Connect the model to real market inputs without placing trades.

### Build

- market data adapter interface
- first simple data source
- normalized option/future input objects
- model price vs. market price comparison
- spread/drift logging
- basic report output

### Done when

- the engine can ingest market inputs
- the model can calculate fair value from those inputs
- output shows market price, model price, and difference
- missing or stale data is handled safely
- no live orders are placed

### Principle

This phase is about observation. Do not rush from a price difference to a trade. First, log it and learn how the difference behaves.

---

## Phase 4 — Backtesting and Validation

**Goal:** Find out whether the idea survives history.

### Build

- historical data ingestion
- simple backtest runner
- repeatable config files
- Sharpe ratio
- max drawdown
- win rate
- expectancy
- basic VaR/CVaR or stress metrics

### Done when

- a hypothesis can be tested from repeatable inputs
- results include both return and risk
- fees and slippage are represented somehow
- assumptions are documented
- bad regimes are called out instead of hidden

### Principle

A backtest is not proof. It is a filter. The job is to kill weak ideas early.

---

## Phase 5 — Risk Layer

**Goal:** Stop thinking about one trade at a time.

### Build

- position model
- portfolio Greeks
- exposure aggregation
- scenario analysis
- stress testing
- loss limits

### Done when

- the system can describe portfolio-level exposure
- risk reports are generated from repeatable inputs
- tail-risk assumptions are visible
- risk checks happen before any execution work

---

## Phase 6 — Execution Simulation

**Goal:** Model execution without sending live orders.

### Build

- simulated order interface
- fill assumptions
- slippage model
- order lifecycle logs
- TWAP/VWAP research prototypes
- post-trade analysis output

### Done when

- simulated orders produce auditable logs
- slippage/fill assumptions are configurable
- execution quality can be measured
- no broker credentials are required
- the project remains safe to keep public

---

## Phase 7 — Platform Hardening

**Goal:** Make the platform less fragile.

### Build

- remote Terraform state with locking
- least-privilege IAM
- better secret handling
- tighter Jenkins access
- clean teardown/rebuild docs
- basic monitoring/logging
- clearer runbooks

### Done when

- infrastructure can be rebuilt from code and docs
- secrets are not in Git
- Jenkins is not publicly exposed
- IAM permissions are scoped down
- deploy/validate/troubleshoot/destroy steps are documented

---

## Codex / Agent Workflow

Codex is a good fit for implementation work inside VS Code, but it should not be treated as the architect of the project.

Use ChatGPT or project docs for:

- architecture decisions
- roadmap changes
- README tone
- trade/research framing
- reviewing whether a proposed direction makes sense

Use Codex for:

- editing repo files
- generating Python classes
- adding tests
- refactoring Terraform
- writing Dockerfiles/Jenkinsfiles
- opening small implementation PRs

Rule: every agent-generated change should be small, reviewable, and backed by tests where possible.

---

## Current Sprint Focus

### 01_Cloud_Architecture

- finalize `terraform/` structure
- harden variables and tfvars handling
- restrict ingress
- provision EC2 + EBS
- bootstrap Docker

### 02_CI_Baseline

- run Jenkins through Docker
- persist Jenkins state
- add baseline `Jenkinsfile`
- prove the repo can test itself

### 03_Pricing_Kernel

- create Python package structure
- implement Black-Scholes
- implement Greeks
- add pytest coverage

### 04_Data_Integration

- pull first market data inputs
- normalize data
- log model price vs. market price

---

## Guiding Rule

Build the research platform before building the trading machine.

A better trader needs evidence. A better system needs tests. A useful repo needs both.
