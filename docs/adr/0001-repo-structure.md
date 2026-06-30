# ADR 0001: Repository Structure

## Status

Accepted

## Context

The project needs to support both quantitative research code and cloud infrastructure without mixing responsibilities. It is still early, so the structure should create obvious places for future work without adding a large framework.

## Decision

Use this top-level shape:

- `infra/terraform/envs/dev` for the first AWS environment
- `infra/terraform/modules` for future shared Terraform modules
- `ci` for pipeline definitions
- `scripts` for local and CI automation
- `src/quant_pricing_engine` for importable Python package code
- `tests` for automated checks
- `docs` for architecture notes, conventions, runbooks, and ADRs

## Consequences

This keeps the first environment easy to run while leaving room to add modules or additional environments later. It also makes the Python package reusable by other projects without coupling it to Jenkins or Terraform.
