FROM jenkins/jenkins:2.516.1-lts-jdk21

ENV JAVA_OPTS="-Dorg.apache.commons.jelly.tags.fmt.timeZone=America/Chicago \
               # Relocate builds directory outside of JENKINS_HOME - https://www.jenkins.io/doc/book/managing/system-properties/#jenkins-model-jenkins-buildsdir
               # This contains the historical builds for a job
               -Djenkins.model.Jenkins.buildsDir=/var/jenkins_builds/\${ITEM_FULL_NAME} \
               # Relocate workspace directory outside of JENKINS_HOME - https://www.jenkins.io/doc/book/managing/system-properties/#jenkins-model-jenkins-workspacesdir
               # This contains the workspace for the build and should be safe to wipe at any time
               # TODO: Move to EBS if Fargate adds support in the future
               -Djenkins.model.Jenkins.workspacesDir=/var/jenkins_workspaces/\${ITEM_FULL_NAME} \
               # https://plugins.jenkins.io/extended-read-permission/
               -Dhudson.security.ExtendedReadPermission=true \
               -Djenkins.security.SystemReadPermission=true \
               # https://github.com/jenkinsci/amazon-ecs-plugin#my-parallel-jobs-dont-start-at-the-same-time
               -Dhudson.slaves.NodeProvisioner.initialDelay=0 -Dhudson.slaves.NodeProvisioner.MARGIN=50 -Dhudson.slaves.NodeProvisioner.MARGIN0=0.85 \
               -Dhudson.model.DirectoryBrowserSupport.CSP= \
               -Djenkins.install.runSetupWizard=false ${JAVA_OPTS} \
               -XX:InitialRAMPercentage=75 \
               -XX:MaxRAMPercentage=75"
ENV CASC_JENKINS_CONFIG /usr/share/jenkins/ref/casc_configs
COPY files/casc_configs/ /usr/share/jenkins/ref/casc_configs/
COPY files/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt