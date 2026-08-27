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

## Automated deployment

Terraform passes this Dockerfile into the EC2 bootstrap. The bootstrap builds
the image, waits for the JCasC-defined `ci` node, retrieves its generated
inbound-agent secret over the controller's local interface, and starts the
Compose `ci` profile. No browser configuration is required.

The generated connection secret remains in the root-owned
`/srv/jenkins/ci-agent.env` runtime file. It does not pass through Terraform
variables or state.

## Manual recovery

To rebuild the image manually on the Jenkins host:

```sh
sudo docker build \
  --tag quantops-jenkins-ci-agent:0.1.0 \
  /path/to/quant-pricing-engine/ci/agent
```

If the container stops while its generated runtime file is still present,
restart it with:

```sh
cd /srv/jenkins
sudo docker compose --env-file ci-agent.env --profile ci up -d ci-agent
```

The secret stays on the controller host and is never committed to this
repository. If the runtime file is lost, replace the lab instance so the IaC
bootstrap recreates the connection rather than configuring the node by hand.
