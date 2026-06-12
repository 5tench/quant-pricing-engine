# quant-pricing-engine

A modular quantitative finance library and automated "Quant-Ops" infrastructure for modeling derivative fair value, implementing Greeks, and establishing a rigorous mathematical baseline for systematic trading pipelines.

## Overview

This repository serves as the **Pricing Kernel** and the deployment pipeline for a professional-grade quantitative trading system. It is engineered to provide a mathematically sound foundation for identifying market mispricing, while demonstrating scalable, containerized execution on AWS. By treating quantitative logic as a microservice, this architecture ensures all trading theses are verified by quantitative expectancy and seamlessly deployed via modern CI/CD practices.

## Pipeline Architecture

This project is developed across mathematical phases and supported by a robust cloud infrastructure stack.

### Phase 1: Mathematical Foundations (Core Engine)
* **Focus**: Derivative pricing models (Black-Scholes).
* **Goal**: Establish the objective "Fair Value" of assets to detect arbitrage opportunities rather than chasing price action.
* **Status**: [Active]

### Phase 2: Quantitative Validation (Backtesting)
* **Focus**: Statistical expectancy, vectorized analysis, and Monte Carlo simulations.
* **Goal**: Ensure the pricing logic survives historical stress tests and proves a positive Sharpe ratio.
* **Status**: [Planned]

### Phase 3: Market Microstructure (Execution)
* **Focus**: Order book dynamics, liquidity, and GEX (Gamma Exposure).
* **Goal**: Translate theoretical fair value into optimized, low-latency execution strategies.
* **Status**: [Planned]

## Infrastructure & "Quant-Ops" Stack

This system is built to operate as an automated, self-healing trading platform.

* **Continuous Integration (CI/CD):** * Driven by **Jenkins** (via Pipeline as Code). Every code push triggers a `pytest` suite against the mathematical models to ensure no regression in the core pricing logic.
* **Containerization:** * The Python pricing engine is fully packaged using **Docker**, ensuring identical execution across local development and production environments.
* **Infrastructure as Code (IaC):** * **Terraform** provisions the underlying AWS environment (VPC, EC2 compute, and stateful EBS volumes for the CI controller) to guarantee the deployment architecture is highly reproducible.
* **Cloud Hosting:** * Deployed strictly within **AWS**, optimized for efficient compute utilization and low-latency connections to external market data APIs.

## Core Features
* Modular Python classes for derivative evaluation.
* Standardized Greek calculations (Delta, Gamma, Theta, Vega, Rho).
* Institutional-grade CI/CD pipeline preventing broken math from entering production.
* Containerized execution for high portability and seamless infrastructure integration.

## Current Sprint Roadmap

1. **Infrastructure Chassis:** Provision the AWS environment and stateful EBS volume via Terraform; initialize the Dockerized Jenkins controller.
2. **Pricing Kernel:** Implement fundamental derivatives pricing logic (`BlackScholesPricer`) and the automated unit-testing suite.
3. **Data Integration:** Standardize API inputs for real-time market data to calculate Live Market Price vs. Fair Value spreads.
4. **Containerized Execution:** Wrap the data-feed and pricing kernel into a unified Docker image deployed autonomously by Jenkins.

## Contributing

As this project strictly follows a DevOps-oriented architecture, all new implementations must pass the automated pipeline. Code contributions must include:

1. **Type hinting** (PEP 8 standard).
2. **Comprehensive unit tests** (pytest) that pass the Jenkins CI build.
3. **Container-compatible execution** logic.
