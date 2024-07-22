FROM amazonlinux:2023

# This image can be used to do Python 3 & NodeJS tests.
# It contains:

#   * CLI utilities: git, make, wget, etc
#   * Python 3
#   * NodeJS
#   * Yarn
#   * Application Python dependencies

ENV NODE_VERSION="20.x"
ENV TERRAFORM_VERSION="1.9.2"
ENV AWS_CLI_VERSION="2.17.13"

# Install NodeJS
RUN curl -fsSL https://rpm.nodesource.com/setup_${NODE_VERSION} | bash -
RUN dnf install -y nodejs

# CLI utilities
RUN dnf install -y gcc gcc-c++ git make openssl unzip wget zip jq


# Python 3
RUN \
        dnf install -y python3-devel && \
        dnf install -y python3-pip && \
        python3 -m pip install setuptools


ARG USER
RUN \
        echo "user:x:${USER}:0:root:/:/bin/bash" >> /etc/passwd

# Install Requirements
COPY workflows/dev-requirements.txt /dev-requirements.txt
COPY workflows/requirements.txt /requirements.txt
RUN python3 -m pip install -r requirements.txt
RUN python3 -m pip install -r dev-requirements.txt

WORKDIR /CIRRUS-DAAC
