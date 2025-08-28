FROM nvcr.io/nvidia/deepstream-l4t:7.1-samples-multiarch AS build

USER root

RUN apt-get update && apt-get install -y \
    build-essential cmake git pkg-config \
    libzmq3-dev \
    libspdlog-dev \
    libfmt-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN git clone https://github.com/KimSiHo/vision-common.git \
    && cd /workspace/vision-common \
    && cmake -S . -B build -DCMAKE_INSTALL_PREFIX=/opt/vision-common \
    && cmake --build build -j \
    && cmake --install build
