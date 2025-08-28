# ----------------------------
# 1) Build Stage
# ----------------------------
FROM localhost:5000/jetson_vision_ai_common/stg:latest AS common
FROM nvcr.io/nvidia/l4t-base:r36.2.0 AS build

USER root

RUN apt-get update && apt-get install -y \
    build-essential cmake git pkg-config \
    libzmq3-dev \
    libspdlog-dev \
    libfmt-dev \
    qtbase5-dev \
    qtdeclarative5-dev qtquickcontrols2-5-dev \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=common /opt/vision-common /opt/vision-common
ENV LD_LIBRARY_PATH=/opt/vision-common/lib:$LD_LIBRARY_PATH

WORKDIR /workspace

ARG GIT_REF=082f1c838c6bc3f593bd2cc1bf35c6a9d5ba0efc
RUN git clone https://github.com/KimSiHo/vision-frontend.git \
    && cd vision-frontend \
    && git fetch --all --tags --prune \
    && git checkout $GIT_REF \
    && cmake -S . -B build -DCMAKE_PREFIX_PATH=/opt/vision-common -DCMAKE_INSTALL_PREFIX=/opt/vision-frontend \
    && cmake --build build -j \
    && cmake --install build

## ----------------------------
# 2) Runtime Stage
## ----------------------------
FROM nvcr.io/nvidia/l4t-base:r36.2.0

COPY --from=common /opt/vision-common /opt/vision-common
COPY --from=build /opt/vision-frontend /opt/vision-frontend

ARG PHASE
ENV PHASE=$PHASE

USER root

RUN apt-get update && apt-get install -y \
    libzmq5 \
    libspdlog1 \
    libfmt8 \
    qtwayland5 libqt5core5a libqt5gui5 libqt5widgets5 \
    qml-module-qtquick-controls2 qml-module-qtquick2 qml-module-qtquick-window2 \
    libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash great
USER great

RUN mkdir -p /home/great/scripts

##############################
# 설정 파일 및 스크립트 파일 복사
##############################
USER root
ADD ./filters/${PHASE}/manage_application.sh /home/great/scripts/manage_application.sh
ADD ./filters/${PHASE}/entrypoint.sh /home/great/scripts/entrypoint.sh

RUN chmod 755 /home/great/scripts/manage_application.sh
RUN chmod 755 /home/great/scripts/entrypoint.sh
RUN chown great:great /home/great/scripts/manage_application.sh
RUN chown great:great /home/great/scripts/entrypoint.sh

##############################
# entrypoint
##############################
ENTRYPOINT ["/home/great/scripts/entrypoint.sh"]
