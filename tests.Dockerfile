FROM amazonlinux:2

# This image can be used to do Python 3 & NodeJS tests.
# It contains:

#   * CLI utilities: git, make, wget, etc
#   * Python 3
#   * NodeJS
#   * Yarn
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


# Python 3 & NodeJS
RUN \
        amazon-linux-extras install python3.8 && \
        ln -s /usr/bin/python3.8 /usr/bin/python3 && \
        ln -s /usr/bin/pip3.8 /usr/bin/pip3 && \
        python3 -m pip install boto3 && \
        yum install -y nodejs yarn \


ARG USER
RUN \
        echo "user:x:${USER}:0:root:/:/bin/bash" >> /etc/passwd

# Install Requirements
COPY workflows/dev-requirements.txt /dev-requirements.txt
COPY workflows/requirements.txt /requirements.txt
RUN python3 -m pip install -r requirements.txt
RUN python3 -m pip install -r dev-requirements.txt

WORKDIR /CIRRUS-DAAC
