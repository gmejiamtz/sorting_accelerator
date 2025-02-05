FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

ENV LANG C.UTF-8
ARG INSTALL_ZSH="true"

RUN apt-get update
RUN apt-get -y install wget unzip
RUN mkdir /tools
#install oss-cad-suite for everything
RUN cd /tools && wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2024-11-21/oss-cad-suite-linux-x64-20241121.tgz && tar -xf oss-cad-suite-linux-x64-20241121.tgz && export PATH="/tools/oss-cad-suite/bin:$PATH" && rm oss-cad-suite-linux-x64-20241121.tgz

#install sv2v
RUN cd /tools && wget https://github.com/zachjs/sv2v/releases/download/v0.0.12/sv2v-Linux.zip && unzip sv2v-Linux.zip && rm sv2v-Linux.zip