# Jenkins Controller Configuration

This directory defines the Jenkins controller as code. It is intentionally
separate from `ci/agent`, which is the isolated environment that executes CI.

## Contents

- `Dockerfile` extends the official Jenkins controller image.
- `plugins.txt` declares the small controller plugin set.
- `jenkins.yaml` configures Jenkins Configuration as Code (JCasC), the
  permanent `ci` node, and the repository Pipeline job.
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

On an empty Jenkins home, JCasC creates the administrator and disables the
interactive unlock/setup wizard. It does not overwrite an existing Jenkins
home: migrate an existing controller deliberately rather than deleting its
EBS-backed state.

## Scope

The controller has zero executors. It orchestrates the JCasC-managed
`quant-pricing-engine` Pipeline; the inbound `ci-agent` executes it. GitHub
trigger provisioning remains a separate layer of work.
