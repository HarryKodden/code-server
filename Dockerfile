FROM ubuntu:latest AS builder
RUN apt-get update -qq
RUN apt-get install -y wget zip
ENV TERRAFORM_VERSION=1.4.4
RUN (cd /tmp; wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip; unzip terraform*.zip; mv terraform /usr/local/bin)

FROM linuxserver/code-server:latest
RUN apt-get update -qq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq apt-transport-https ca-certificates curl
RUN curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | apt-key add -qq -
RUN echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update -qq
RUN groupadd docker -g 999
RUN apt-get install -y -qq --no-install-recommends software-properties-common docker-ce docker-compose
RUN apt-add-repository --yes --update ppa:ansible/ansible
RUN apt install -y ansible
RUN ansible-galaxy collection install community.docker

COPY --from=builder /usr/local/bin/terraform /usr/local/bin/

RUN usermod -aG docker abc

RUN apt-get install rclone make vim

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# https://helm.sh/docs/intro/install/
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
RUN apt-get install apt-transport-https --yes
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
RUN apt-get update
RUN apt-get install helm

RUN curl -L https://github.com/Praqma/helmsman/releases/download/v3.11.0/helmsman_3.11.0_linux_amd64.tar.gz | tar zx
RUN mv helmsman /usr/local/bin