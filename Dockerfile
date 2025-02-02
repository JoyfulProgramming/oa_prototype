FROM dynatrace/oneagent
# FROM ruby:3.4.1-bookworm

# COPY --from=dynatrace/oneagent/linux/oneagent-codemodules:sdk / /
# ENV LD_PRELOAD /opt/dynatrace/oneagent/agent/lib64/liboneagentproc.so

# Install OneAgent - this should be first to ensure proper instrumentation

# RUN wget -O /tmp/oneagent.sh ${ONEAGENT_INSTALLER_SCRIPT_URL} --header="Authorization: Api-Token ${ONEAGENT_INSTALLER_DOWNLOAD_TOKEN}" && \
#     sh /tmp/oneagent.sh && \
#     rm /tmp/oneagent.sh

    # /var/log/dynatrace/oneagent/installer/installation_8.log

# RUN apk add --no-cache ruby

# ENV DEBIAN_FRONTEND=noninteractive
# RUN apt-get update && \
#     apt-get install -y tzdata && \
#     apt-get install -y \
#     strace \
#     build-essential \
#     git \
#     cmake \
#     curl \
#     vim \
#     wget \
#     && rm -rf /var/lib/apt/lists/*

# ENV ONEAGENT_SDK_DIR=/opt/dynatrace-oneagent-sdk
# WORKDIR $ONEAGENT_SDK_DIR

# Install Ruby

RUN microdnf install -y dnf

RUN dnf install -y gcc make bzip2 openssl-devel zlib-devel libffi-devel libyaml-devel tar gzip findutils libffi pkg-config git vim

RUN curl -O https://cache.ruby-lang.org/pub/ruby/3.2/ruby-3.2.2.tar.gz
RUN tar -xzf ruby-3.2.2.tar.gz
RUN cd ruby-3.2.2 && ./configure --with-libffi-dir=/usr --with-libyaml-dir=/usr && make -j$(nproc) && make install

RUN git clone https://github.com/Dynatrace/OneAgent-SDK-for-C.git /sdk

RUN gem install ffi

VOLUME [".:/app"]
WORKDIR /app

# RUN mkdir -p /mnt/root

# Add OneAgent-specific environment variables
# ENV LD_PRELOAD="/opt/dynatrace/oneagent/agent/lib64/liboneagentproc.so"

# ENTRYPOINT ["/bin/bash"]
