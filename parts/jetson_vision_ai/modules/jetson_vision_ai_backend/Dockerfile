# ----------------------------
# 1) Build Stage
# ----------------------------
FROM localhost:5000/jetson_vision_ai_common/stg:latest AS common
FROM nvcr.io/nvidia/deepstream-l4t:7.1-samples-multiarch AS build

USER root

RUN apt-get update && apt-get install -y \
    build-essential cmake git pkg-config \
    libzmq3-dev \
    nlohmann-json3-dev \
    libspdlog-dev \
    libfmt-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libtbb-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=common /opt/vision-common /opt/vision-common
ENV LD_LIBRARY_PATH=/opt/vision-common/lib:$LD_LIBRARY_PATH

WORKDIR /workspace

ARG GIT_REF=b67a8f1224dfa49589ab5aeb3951c0ae6377f686
RUN git clone https://github.com/KimSiHo/vision-backend.git \
    && cd /workspace/vision-backend \
    && git fetch --all --tags --prune \
    && git checkout $GIT_REF \
    && cmake -S . -B build -DCMAKE_PREFIX_PATH=/opt/vision-common -DCMAKE_INSTALL_PREFIX=/opt/vision-backend \
    && cmake --build build -j \
    && cmake --install build

# ----------------------------
# 2) Runtime Stage
# ----------------------------
FROM nvcr.io/nvidia/deepstream-l4t:7.1-samples-multiarch

COPY --from=common /opt/vision-common /opt/vision-common
COPY --from=build /opt/vision-backend /opt/vision-backend

USER root

### for develop
WORKDIR /workspace
RUN git clone https://github.com/KimSiHo/vision-backend.git \
    && cd vision-backend \
    && git fetch --all --tags --prune \
    && git checkout $GIT_REF

RUN apt-get update && apt-get install -y \
    build-essential cmake git pkg-config \
    libzmq3-dev \
    nlohmann-json3-dev \
    libspdlog-dev \
    libfmt-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libtbb-dev \
    vim \
    && rm -rf /var/lib/apt/lists/*
### for develop

ARG PHASE
ENV PHASE=$PHASE

RUN apt-get update && apt-get install -y --no-install-recommends \
    libzmq5 \
    libspdlog1 \
    libfmt8 \
    libgstreamer1.0-0 \
    libgstreamer-plugins-base1.0-0 \
    libtbb12 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash great && \
    mkdir -p /home/great/scripts /etc/vision-backend /opt/vision-backend/models/Primary_Detector && \
    chown -R great:great /etc/vision-backend

##############################
# 설정 파일 및 스크립트 파일 복사
##############################
ADD ./filters/${PHASE}/manage_application.sh /home/great/scripts/manage_application.sh
ADD ./filters/${PHASE}/entrypoint.sh /home/great/scripts/entrypoint.sh
ADD ./filters/${PHASE}/config_infer_primary.txt /etc/vision-backend/config_infer_primary.txt
ADD ./filters/${PHASE}/resnet18_trafficcamnet_pruned.onnx /opt/vision-backend/models/Primary_Detector/resnet18_trafficcamnet_pruned.onnx
ADD ./filters/${PHASE}/config_infer_primary.txt /opt/vision-backend/models/Primary_Detector/labels.txt
ADD ./filters/${PHASE}/config_infer_primary.txt /opt/vision-backend/models/Primary_Detector/cal_trt.bin

RUN chmod 755 /home/great/scripts/manage_application.sh
RUN chmod 755 /home/great/scripts/entrypoint.sh
RUN chown great:great /home/great/scripts/manage_application.sh
RUN chown great:great /home/great/scripts/entrypoint.sh

##############################
# entrypoint
##############################
ENTRYPOINT ["/home/great/scripts/entrypoint.sh"]
