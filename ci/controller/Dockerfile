# Declarative Jenkins controller image. Build execution stays on CI agents.
FROM docker.io/jenkins/jenkins:lts-jdk21

COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

COPY --chown=jenkins:jenkins jenkins.yaml /usr/share/jenkins/ref/casc_configs/jenkins.yaml

# JCasC supplies the secured initial configuration; do not disable the wizard
# without this configuration and a host-local controller.env file.
ENV CASC_JENKINS_CONFIG=/usr/share/jenkins/ref/casc_configs/jenkins.yaml
ENV JAVA_OPTS=-Djenkins.install.runSetupWizard=false
