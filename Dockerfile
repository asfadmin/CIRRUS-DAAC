FROM amazonlinux:2

# This image can be used to do Python 3 & NodeJS development, and
# includes the AWS CLI and Terraform. It contains:

#   * CLI utilities: git, make, wget, etc
#   * Python 3
#   * NodeJS
#   * Yarn
#   * AWS CLI
#   * Terraform
#   * Application Python dependencies

ENV NODE_VERSION "16.x"
ENV TERRAFORM_VERSION "1.5.3"
ENV AWS_CLI_VERSION "2.13.25"

# Add NodeJS and Yarn repos & update package index
RUN \
        yum install https://rpm.nodesource.com/pub_${NODE_VERSION}/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y && \
        yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1 && \
        curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
        yum update -y

# CLI utilities
RUN yum install -y gcc gcc-c++ git make openssl unzip wget zip jq

# AWS & Terraform
RUN \
        wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
        unzip *.zip && \
        chmod +x terraform && \
        mv terraform /usr/local/bin && \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-$AWS_CLI_VERSION.zip" -o "awscliv2.zip" && \
        unzip awscliv2.zip && \
        ./aws/install

# Python 3 & NodeJS
RUN \
        amazon-linux-extras install python3.8 && \
        ln -s /usr/bin/python3.8 /usr/bin/python3 && \
        ln -s /usr/bin/pip3.8 /usr/bin/pip3 && \
        python3 -m pip install boto3 && \
        yum install -y nodejs yarn

# SSM SessionManager plugin
RUN \
        curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm" &&\
        yum install -y session-manager-plugin.rpm

# Add user for keygen in Makefile
ARG USER
RUN \
        echo "user:x:${USER}:0:root:/:/bin/bash" >> /etc/passwd

WORKDIR /CIRRUS-DAAC
