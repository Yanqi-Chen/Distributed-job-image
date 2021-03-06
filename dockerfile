# Copyright (c) Microsoft Corporation
# All rights reserved.
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
# to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'
#
#
# Copyright (c) Peking University 2018
#
# The software is released under the Open-Intelligence Open Source License V1.0.
# The copyright owner promises to follow "Open-Intelligence Open Source Platform
# Management Regulation V1.0", which is provided by The New Generation of 
# Artificial Intelligence Technology Innovation Strategic Alliance (the AITISA).

# tag: qizhi.build.base:hadoop2.7.2-cuda9.0-cudnn7-devel-ubuntu16.04
#
# Base image to build for the system.
# Other images depend on it, so build it like:
#
# docker build -f Dockerfile.build.base -t qizhi.build.base:hadoop2.7.2-cuda9.0-cudnn7-devel-ubuntu16.04 .


# Tag: nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04
# Label: com.nvidia.volumes.needed: nvidia_driver
# Label: maintainer: NVIDIA CORPORATION <cudatools@nvidia.com>
# Ubuntu 16.04
FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

ENV HADOOP_VERSION=2.7.2
ENV NCCL_VERSION=2.4.2-1+cuda9.0
LABEL HADOOP_VERSION=2.7.2

RUN sed -i 's/http:\/\/archive\.ubuntu\.com\/ubuntu\//https:\/\/mirrors\.tuna\.tsinghua\.edu\.cn\/ubuntu\//g' /etc/apt/sources.list

RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get -y update && \
    apt-get -y install python \
        python-pip \
        python-dev \
        python3 \
        python3-pip \
        python3-dev \
        python-yaml \
        python-six \
        build-essential \
        git \
        wget \
        curl \
        unzip \
        automake \
        openjdk-8-jdk \
        openssh-server \
        openssh-client \
        libnccl2=${NCCL_VERSION} \
        libnccl-dev=${NCCL_VERSION} \
        vim \
        lsof \
        libcupti-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget -qO- http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | \
    tar xz -C /usr/local && \
    mv /usr/local/hadoop-${HADOOP_VERSION} /usr/local/hadoop

# # Install Docker from Docker Inc. repositories.
# RUN curl -sSL https://get.docker.com/ | sh

# # Install the magic wrapper.
# ADD ./wrapdocker /usr/local/bin/wrapdocker
# RUN chmod +x /usr/local/bin/wrapdocker

# # Define additional metadata for our image.
# VOLUME /var/lib/docker
# CMD ["wrapdocker"]

# install docker binary files

ENV DOCKER_CHANNEL stable
ENV DOCKER_VERSION 18.06.1-ce

RUN if ! wget -q -O docker.tgz "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz"; then \
        echo >&2 "error: failed to download 'docker-${DOCKER_VERSION}' from '${DOCKER_CHANNEL}' for x86_64"; \
        exit 1; \
    fi; \
    \
    tar --extract \
        --file docker.tgz \
        --strip-components 1 \
        --directory /usr/local/bin/ \
    ; \
    rm docker.tgz; \
    \
    dockerd --version; \
    docker --version

COPY modprobe.sh /usr/local/bin/modprobe
COPY docker-entrypoint.sh /usr/local/bin/
COPY disthelper /root/disthelper
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh && \
    chmod -R a+x /root/disthelper && \
    echo "export PYTHONPATH=/root/disthelper:$PYTHONPATH" >> $HOME/.bashrc

# RUN wget --quiet https://repo.continuum.io/archive/Anaconda3-2018.12-Linux-x86_64.sh -O $HOME/anaconda.sh && \
#     /bin/bash $HOME/anaconda.sh -b -p /root/conda && \
#     rm $HOME/anaconda.sh && \
#     echo "export PATH=/root/conda/bin:$PATH" >> $HOME/.bashrc && \
#     export PATH=/root/conda/bin:$PATH && \
#     conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ && \
#     conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ && \
#     conda config --set show_channel_urls yes && \
#     conda create -n pytorch_env pytorch torchvision cudatoolkit=9.0 -c pytorch && \
#     conda create -n tensorflow_env tensorflow-gpu cudatoolkit=9.0
#     # TODO: Support more frameworks in the future.

# Set default NCCL parameters
RUN echo NCCL_DEBUG=INFO >> /etc/nccl.conf

ENTRYPOINT ["docker-entrypoint.sh"]

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    HADOOP_INSTALL=/usr/local/hadoop \
    NVIDIA_VISIBLE_DEVICES=all

ENV HADOOP_PREFIX=${HADOOP_INSTALL} \
    HADOOP_BIN_DIR=${HADOOP_INSTALL}/bin \
    HADOOP_SBIN_DIR=${HADOOP_INSTALL}/sbin \
    HADOOP_HDFS_HOME=${HADOOP_INSTALL} \
    HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_INSTALL}/lib/native \
    HADOOP_OPTS="-Djava.library.path=${HADOOP_INSTALL}/lib/native"

ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${HADOOP_BIN_DIR}:${HADOOP_SBIN_DIR} \
    LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/usr/local/cuda/lib64:/usr/local/cuda/targets/x86_64-linux/lib/stubs:${JAVA_HOME}/jre/lib/amd64/server

WORKDIR /root
