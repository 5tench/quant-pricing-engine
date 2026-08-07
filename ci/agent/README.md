# Jenkins CI Agent

This image is the reproducible execution environment for baseline CI. It keeps
Python, Terraform, and Docker CLI tooling out of the Jenkins controller.

## Included tools

- Git
- Python 3
- Terraform 1.10.5
- Docker CLI, Buildx, and Docker Compose v2

The image intentionally does not receive `/var/run/docker.sock`, privileged
mode, AWS credentials, or repository secrets. The current pipeline only uses
`docker compose config`, which does not require access to a Docker daemon.

## Build on the Jenkins host

Clone or copy this repository to the controller host, then run:

```sh
sudo docker build \
  --tag quantops-jenkins-ci-agent:0.1.0 \
  /path/to/quant-pricing-engine/ci/agent
```

## Connect the inbound agent

1. In Jenkins, create a permanent node named `ci` using the **Launch agent by
   connecting it to the controller** launch method.
2. Copy its generated secret to `/srv/jenkins/ci-agent.env` on the host:

   ```text
   JENKINS_AGENT_SECRET=<generated-secret>
   ```

3. Start the opt-in Compose profile:

   ```sh
   cd /srv/jenkins
   sudo docker compose --env-file ci-agent.env --profile ci up -d ci-agent
   ```

The secret stays on the controller host and is never committed to this
repository.
