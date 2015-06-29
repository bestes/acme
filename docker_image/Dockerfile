FROM ubuntu:14.04.2
MAINTAINER bestes@sourcenow.com

# Modified and extended Ansible image for the ACME demo

# Ansible version is up here so changing it will rebuild the entire image. It
# might have been a while, so other packages would have updates as well.
ENV ANSIBLE_VERSION stable-1.9

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y    \
        curl                 \
        git                  \
        inetutils-ping       \
        net-tools            \
        openssh-client       \
        python-httplib2      \
        python-jinja2        \
        python-keyczar       \
        python-paramiko      \
        python-pip           \
        python-pkg-resources \
        python-setuptools    \
        python-yaml          \
        unzip                \
        vim                  \
        wget                 \
        zip                  \
        --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Install Ansible
RUN mkdir /etc/ansible/
RUN echo '[local]\nlocalhost\n' > /etc/ansible/hosts
RUN git clone http://github.com/ansible/ansible.git /opt/ansible
WORKDIR /opt/ansible
RUN git checkout ${ANSIBLE_VERSION}
RUN git submodule update --init

ENV PATH /opt/ansible/bin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin
ENV PYTHONPATH /opt/ansible/lib
ENV ANSIBLE_LIBRARY /opt/ansible/library

# Install awscli and boto
RUN pip install awscli boto
RUN echo "complete -C aws_completer aws" >> /root/.bashrc

# Install jq
RUN curl -o /usr/local/bin/jq https://stedolan.github.io/jq/download/linux64/jq
RUN chmod +x /usr/local/bin/jq

# Do a few preparations for the setup script
RUN mkdir /root/.ssh            && \
    chmod go-rwx /root/.ssh     && \
    mkdir /root/.aws            && \
    mkdir /root/.ansible        && \
    mkdir /root/conf            && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

VOLUME /root/conf

RUN git clone https://github.com/bestes/acme.git /root/acme

COPY setup.sh /root/
WORKDIR /root

CMD bash -C '/root/setup.sh';'bash'
