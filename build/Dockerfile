FROM amazonlinux:2

# This dockerfile is mainly for making a dev environment

RUN yum update -y && \
    curl -sL https://rpm.nodesource.com/setup_10.x | bash - && curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
    yum install -y python3-devel make git nodejs yarn openssl wget awscli zip gcc unzip && \
    wget https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_linux_amd64.zip && unzip *.zip && chmod +x terraform && mv terraform /usr/local/bin

ADD requirements.txt /requirements/
ADD dev-requirements.txt /requirements/
RUN pip3 install -r /requirements/requirements.txt -r /requirements/dev-requirements.txt

WORKDIR /CIRRUS-core
