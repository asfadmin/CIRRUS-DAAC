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

ENV NODE_VERSION "12.x"
ENV TERRAFORM_VERSION "0.14.0"

# Add NodeJS and Yarn repos & update package index
RUN \
        curl -sL https://rpm.nodesource.com/setup_${NODE_VERSION} | bash - && \
        curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
        yum update -y

# CLI utilities
RUN yum install -y gcc git make openssl unzip wget zip

# Python 3 & NodeJS
RUN \
        yum install -y python3-devel && \
        yum install -y nodejs yarn

# AWS & Terraform
RUN \
        yum install -y awscli && \
        wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
        unzip *.zip && \
        chmod +x terraform && \
        mv terraform /usr/local/bin

# Application Python dependencies
ADD requirements.txt /requirements/
ADD dev-requirements.txt /requirements/
RUN pip3 install -r /requirements/requirements.txt -r /requirements/dev-requirements.txt

WORKDIR /CIRRUS-DAAC
