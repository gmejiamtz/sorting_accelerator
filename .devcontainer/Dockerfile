FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

ENV LANG C.UTF-8
ARG INSTALL_ZSH="true"

RUN apt-get update
RUN apt-get -y install wget unzip g++ gcc libc6-dev libffi-dev libgmp-dev make xz-utils zlib1g-dev git gnupg netbase haskell-stack
RUN mkdir /tools
#install oss-cad-suite for everything
RUN cd /tools && wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2024-11-21/oss-cad-suite-linux-x64-20241121.tgz && tar -xf oss-cad-suite-linux-x64-20241121.tgz && export PATH="/tools/oss-cad-suite/bin:$PATH" && rm oss-cad-suite-linux-x64-20241121.tgz

RUN stack upgrade --binary-only

#install sv2v
RUN cd /tools && mkdir sv2v && git clone https://github.com/zachjs/sv2v.git sv2v_repo && cd sv2v_repo && make && cp ./bin/sv2v /tools/sv2v && cd .. && rm -rf sv2v_repo