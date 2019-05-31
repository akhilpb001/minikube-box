#!/bin/bash
set -x

if [ -e /etc/redhat-release ] ; then
  REDHAT_BASED=true
fi

TERRAFORM_VERSION="0.11.7"
PACKER_VERSION="1.2.4"
MINIKUBE_VERSION="v1.0.1"
HELM_VERSION="v2.10.0"

# create new ssh key
[[ ! -f /home/ubuntu/.ssh/mykey ]] \
&& mkdir -p /home/ubuntu/.ssh \
&& ssh-keygen -f /home/ubuntu/.ssh/mykey -N '' \
&& chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# install packages
if [ ${REDHAT_BASED} ] ; then
  yum -y update
  yum install -y docker ansible unzip wget tar
else 
  apt-get update
  apt-get -y install docker.io ansible unzip
fi
# add docker privileges
usermod -G docker ubuntu
# install pip
pip install -U pip && pip3 install -U pip
if [[ $? == 127 ]]; then
    wget -q https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    python3 get-pip.py
fi
# install awscli and ebcli
pip install -U awscli
pip install -U awsebcli

# terraform
T_VERSION=$(/usr/local/bin/terraform -v | head -1 | cut -d ' ' -f 2 | tail -c +2)
T_RETVAL=${PIPESTATUS[0]}

[[ $T_VERSION != $TERRAFORM_VERSION ]] || [[ $T_RETVAL != 0 ]] \
&& wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# packer
P_VERSION=$(/usr/local/bin/packer -v)
P_RETVAL=$?

[[ $P_VERSION != $PACKER_VERSION ]] || [[ $P_RETVAL != 1 ]] \
&& wget -q https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
&& unzip -o packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm packer_${PACKER_VERSION}_linux_amd64.zip

# minikube
M_VERSION=$(/usr/local/bin/minikube version | head -1 | cut -d ' ' -f 3 | tail -c +2)
M_RETVAL=${PIPESTATUS[0]}

[[ $M_VERSION != $MINIKUBE_VERSION ]] || [[ $M_RETVAL != 0 ]] \
&& wget -qO minikube https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-linux-amd64 \
&& chmod +x minikube \
&& cp minikube /usr/local/bin \
&& rm minikube

# helm
H_VERSION=$(/usr/local/bin/helm version | head -1 | cut -d ',' -f 1 | cut -d ':' -f 3)
H_RETVAL=${PIPESTATUS[0]}

[[ $H_VERSION != $HELM_VERSION ]] || [[ $H_RETVAL != 0 ]] \
&& wget -q https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz \
&& tar -xzf helm-${HELM_VERSION}-linux-amd64.tar.gz \
&& cp linux-amd64/helm /usr/local/bin \
&& rm -rf linux-amd64/ helm-v2.10.0-linux-amd64.tar.gz

# clean up
if [ ! ${REDHAT_BASED} ] ; then
  apt-get clean
fi
