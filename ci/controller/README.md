# Jenkins Controller Configuration

This directory defines the Jenkins controller as code. It is intentionally
separate from `ci/agent`, which is the isolated environment that executes CI.

## Contents

- `Dockerfile` extends the official Jenkins controller image.
- `plugins.txt` declares the small controller plugin set.
- `jenkins.yaml` configures Jenkins Configuration as Code (JCasC), the
  permanent `ci` node, the manual baseline Pipeline job, and the repository
  multibranch Pipeline job.
- `controller.env.example` documents the host-local bootstrap variables.

## First boot

Terraform writes the controller build context to `/srv/jenkins/controller`.
On first boot it generates a strong administrator password directly on the
controller, writes `/srv/jenkins/controller.env` with mode `600`, builds the
controller image, and starts Jenkins. The password never enters Terraform,
cloud-init logs, or Git.

After apply, retrieve the generated value with the Terraform output:

```sh
terraform output -raw jenkins_initial_admin_password_command
```

Run the displayed SSH command. It prints `JENKINS_ADMIN_PASSWORD=...` from the
root-only host file. The administrator ID is `admin`.

During bootstrap, Terraform copies this directory to `/srv/jenkins/controller`
and builds the controller image locally before Docker Compose starts it.

On startup, Jenkins reads JCasC from the versioned controller image, creates
or reconciles the declared configuration, and disables the interactive
unlock/setup wizard. Jenkins state remains on EBS; configuration updates do
not depend on a stale reference file copied into the persistent home.

## Scope

The controller has zero executors. It orchestrates two JCasC-managed jobs, and
the inbound `ci-agent` executes their builds:

- `quant-pricing-engine` is the manual, fixed-branch baseline for
  `development`.
- `quant-pricing-engine-branches` uses the GitHub Branch Source plugin to
  discover branches and same-repository pull requests every thirty minutes.

The multibranch job reads `ci/Jenkinsfile` from the exact branch or pull-request
revision being built. Pull requests are tested as prospective merges with
their target branch. Fork pull requests are not built by this initial public
repository configuration.

Periodic discovery is intentional for the disposable lab controller. It only
requires outbound HTTPS, works without GitHub credentials for this public
repository, and does not expose Jenkins to inbound webhook traffic. A webhook
can replace or supplement polling after the project has stable HTTPS ingress
and a documented credential policy. JCasC configures the GitHub API limiter to
throttle only near the anonymous limit; this suits one infrequently scanned
repository better than Jenkins' default strategy of spreading calls evenly
across the hour. Anonymous access is still limited to 60 GitHub API requests
per hour, so repeated scans and builds can be throttled. A future narrowly
scoped GitHub App credential can raise that limit and publish build status back
to GitHub; the anonymous baseline cannot write commit or pull-request checks.

## Why These Plugins Exist

Jenkins plugins add controller capabilities; they are separate from Python
application dependencies in `pyproject.toml`.

- `configuration-as-code` reads `jenkins.yaml` and applies global Jenkins
  configuration at startup.
- `matrix-auth` supplies the authorization strategy declared by JCasC.
- `git` lets Jenkins clone and check out the repository.
- `github-branch-source` understands GitHub branches and pull requests and
  supplies multibranch metadata such as `BRANCH_NAME`, `CHANGE_ID`, and
  `CHANGE_TARGET`.
- `job-dsl` turns the `jobs:` Groovy declarations in `jenkins.yaml` into real
  Jenkins jobs.
- `credentials-binding` provides a controlled way to expose future credentials
  to an individual build step without writing them into the Jenkinsfile.
- `pipeline-model-definition` implements the declarative `pipeline { ... }`
  syntax used by `ci/Jenkinsfile`.
- `pipeline-stage-view` renders Pipeline stages in the Jenkins UI.
- `ansicolor` and `timestamper` make console output readable and auditable.

Plugins may install transitive dependencies such as Branch API or CloudBees
Folder. Those dependencies support the named capability but are resolved by
the Jenkins plugin installer rather than listed as project-level design
choices.

The source-of-truth flow is:

```text
plugins.txt -> controller capabilities
jenkins.yaml -> controller, node, and job configuration
GitHub branches and pull requests -> revisions Jenkins discovers
ci/Jenkinsfile at that revision -> build behavior
Jenkins build records -> runtime evidence
```

Jenkins therefore executes configuration from Git instead of maintaining an
independent copy assembled through UI clicks. Runtime records remain in
Jenkins because logs and build results are evidence, not desired-state source
code.
