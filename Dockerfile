FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y tzdata && \
    apt-get install -y \
    build-essential \
    git \
    cmake \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

ENV ONEAGENT_SDK_DIR=/opt/dynatrace-oneagent-sdk

RUN git clone https://github.com/Dynatrace/OneAgent-SDK-for-C.git $ONEAGENT_SDK_DIR

WORKDIR $ONEAGENT_SDK_DIR

ENTRYPOINT ["/bin/bash"]
