# Architecture

`quant-pricing-engine` is split into four early layers:

1. Infrastructure under `infra/terraform`.
2. CI entrypoints under `ci`.
3. Automation scripts under `scripts`.
4. Python package code under `src/quant_pricing_engine`.

The first infrastructure target is intentionally small: one AWS dev environment that can host Docker and Jenkins while preserving state on EBS.

The Python package is only a skeleton for now. Pricing models should be added after the repository can validate itself reliably.
