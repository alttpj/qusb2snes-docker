FROM ubuntu:20.04 AS builder
RUN apt-get update \
      && DEBIAN_FRONTEND="noninteractive" apt-get -q -y --no-install-recommends install build-essential qt5-default qt5-qmake qtbase5-dev qtbase5-dev-tools qtdeclarative5-dev libqt5serialport5-dev libqt5websockets5-dev git curl ca-certificates \
      && rm -rf /var/lib/apt/lists/*
WORKDIR /workspace
# other example: ARG QUSB2SNES_TAG=v0.7.19.3
ARG QUSB2SNES_TAG=master
ENV QUSB2SNES_TAG=${QUSB2SNES_TAG}
RUN git clone https://github.com/Skarsnik/QUsb2snes.git --depth 1 --branch ${QUSB2SNES_TAG}
WORKDIR /workspace/QUsb2snes
RUN qmake QUSB2SNES_NOGUI=1 CONFIG+='release'
RUN make -j$(cat /proc/cpuinfo | grep 'processor.*:' | wc -l)

FROM ubuntu:20.04
WORKDIR /app
COPY --from=builder /workspace/QUsb2snes/QUsb2Snes /app/
RUN DEBIAN_FRONTEND="noninteractive" apt-get update && apt-get -q -y --no-install-recommends install libqt5core5a libqt5serialport5 libqt5websockets5 \
      && rm -rf /var/lib/apt/lists/* \
      && mkdir -p /root/.local/share/QUsb2Snes && ln -s /dev/stdout /root/.local/share/QUsb2Snes/log.txt
USER 1001
ENTRYPOINT ["./QUsb2Snes", "-nogui"]
CMD ["-retroarch"]

