# Immutable CI execution environment for the Jenkins inbound agent.
# The controller remains a minimal Jenkins service; builds run on this image.
FROM docker.io/jenkins/inbound-agent:latest-jdk21

USER root

ARG TERRAFORM_VERSION=1.10.5

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      gnupg \
      python3 \
      python3-pip \
      unzip; \
    install -m 0755 -d /etc/apt/keyrings; \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc; \
    chmod a+r /etc/apt/keyrings/docker.asc; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" > /etc/apt/sources.list.d/docker.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      docker-buildx-plugin \
      docker-ce-cli \
      docker-compose-plugin; \
    curl -fsSLo /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"; \
    curl -fsSLo /tmp/terraform_SHA256SUMS "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS"; \
    grep " terraform_${TERRAFORM_VERSION}_linux_amd64.zip$" /tmp/terraform_SHA256SUMS | (cd /tmp && sha256sum -c -); \
    unzip -q /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin; \
    rm -f /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip /tmp/terraform_SHA256SUMS; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

USER jenkins
