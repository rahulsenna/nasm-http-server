FROM --platform=linux/amd64 ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive
ENV VCPKG_ROOT=/opt/vcpkg

RUN apt-get update && apt-get install -y \
    build-essential \
    nasm \
    binutils \
    gcc \
    gdb \
    curl \
    git \
    cmake \
    unzip \
    zip \
    tar \
    golang-go \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install CodeCrafters CLI directly during build
RUN curl https://codecrafters.io/install.sh | sh

# Clone and bootstrap vcpkg
RUN git clone https://github.com/microsoft/vcpkg.git $VCPKG_ROOT && \
    $VCPKG_ROOT/bootstrap-vcpkg.sh

WORKDIR /app

CMD ["/bin/bash"]
