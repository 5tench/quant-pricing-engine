# Runbook

## Validate The Skeleton

```bash
make validate
```

Run this from a WSL/Linux shell. A Python virtual environment is not required for Terraform, and it is optional for the current Python skeleton.

`make validate` calls `scripts/validate.sh`. The script is a repo health check, not SCM validation. It currently:

- runs the Python skeleton test under `tests/`
- checks Terraform formatting with `terraform fmt -check`
- initializes Terraform with `-backend=false`
- validates the dev Terraform configuration

This is the same kind of command Jenkins can run later as an early CI stage.

## Terraform Dev Environment

```bash
cd infra/terraform/envs/dev
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Before applying, replace `allowed_ingress_cidrs` in `terraform.tfvars` with a trusted public /32 IP.

The Jenkins controller is bootstrapped through `user_data.sh.tftpl`. Docker Compose runs Jenkins from `docker-compose.yaml`, with Jenkins home mounted at `/srv/jenkins/home` on the attached EBS volume.

After apply, use the `jenkins_url` output to open Jenkins. Retrieve the first unlock password with the `jenkins_initial_admin_password_command` output, or SSH to the host and run:

```bash
sudo cat /srv/jenkins/home/secrets/initialAdminPassword
```

## Jenkins Controller

The controller is configured at first boot through Jenkins Configuration as
Code (JCasC). Its image, plugins, and configuration live under
`ci/controller`. Terraform writes the controller image build context under
`/srv/jenkins/controller`, generates a strong administrator password directly
on the host, builds the image, and starts Jenkins. The root-only
`/srv/jenkins/controller.env` file is never committed and the secret is never
stored in Terraform state. After apply, run the
`jenkins_initial_admin_password_command` Terraform output to retrieve it.

Both Jenkins jobs load their Pipeline definition from the repository's
`ci/Jenkinsfile`:

- `quant-pricing-engine` is a manual baseline job fixed to `development`.
- `quant-pricing-engine-branches` checks GitHub every thirty minutes for
  branches and same-repository pull requests.

The multibranch job creates a child job for each discovered branch or pull
request that contains `ci/Jenkinsfile`. A branch push is picked up on the next
scan. A pull request is built as a prospective merge with its target branch so
the build tests the code GitHub would merge, not merely an unrelated branch
tip. The Pipeline's `Build Context` stage records the Jenkins job, branch or
pull request, and exact Git commit in the console log.

The polling design is deliberate while the controller is a disposable,
IP-restricted HTTP lab. It avoids opening Jenkins to inbound webhook traffic
and does not require storing a GitHub credential. The thirty-minute interval
leaves room under GitHub's anonymous 60-request-per-hour limit for discovery
and builds during normal lab use. Jenkins is configured to throttle only when
that limit is nearly exhausted. For immediate feedback, open
`quant-pricing-engine-branches` and trigger **Scan Multibranch Pipeline Now**;
inspect **Scan Multibranch Pipeline Log** if the expected revision is not
discovered.

Anonymous access can discover and clone this public repository, but it cannot
publish commit statuses or pull-request checks back to GitHub. Jenkins logs a
non-fatal authentication warning when it attempts that write. Add a narrowly
scoped GitHub App credential only after the repository's secrets policy is
defined; do not solve the warning by placing a personal token in Git or in an
untracked browser-only configuration.

The controller currently runs in Docker Compose. Jenkins home is persisted on EBS at:

```text
/srv/jenkins/home
```

The controller remains a minimal Jenkins service. Repository validation runs on
the dedicated `ci` inbound agent defined in `ci/agent/Dockerfile`; its setup
instructions are in `ci/agent/README.md`. The agent contains Python,
Terraform, and Docker Compose tooling, but it does not receive Docker socket,
AWS credential, or repository-secret access.

## Verify GitHub-discovered Builds

For a branch-push smoke test:

1. Push a commit containing `ci/Jenkinsfile` to a non-protected branch.
2. Wait up to thirty minutes for repository discovery, or trigger **Scan
   Multibranch Pipeline Now**.
3. Open `quant-pricing-engine-branches/<branch-name>` in Jenkins.
4. Confirm the `Build Context` commit matches `git rev-parse HEAD` for the
   pushed branch.

For a pull-request smoke test:

1. Open a pull request from a branch in `5tench/quant-pricing-engine`.
2. Wait up to thirty minutes for repository discovery, or trigger **Scan
   Multibranch Pipeline Now**.
3. Confirm Jenkins creates a `PR-<number>` child job.
4. Confirm `CHANGE_ID` and `CHANGE_TARGET` in `Build Context` match the pull
   request and that the checked-out revision is the prospective merge revision.

Fork pull requests are intentionally excluded. The agent has no deployment
credentials, AWS credentials, privileged mode, or Docker socket, but limiting
the first trigger scope keeps the trust boundary explicit.

## Teardown

```bash
cd infra/terraform/envs/dev
terraform destroy
```
