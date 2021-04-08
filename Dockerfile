FROM debian:stable AS builder
RUN apt-get update && apt-get -q -y --no-install-recommends install build-essential qt5-default qt5-qmake qtbase5-dev qtbase5-dev-tools qtdeclarative5-dev libqt5serialport5-dev libqt5websockets5-dev git curl ca-certificates
WORKDIR /workspace
#ARG QUSB2SNES_TAG=v0.7.19.3
ARG QUSB2SNES_TAG=master
ENV QUSB2SNES_TAG=${QUSB2SNES_TAG}
RUN git clone https://github.com/Skarsnik/QUsb2snes.git --depth 1 --branch ${QUSB2SNES_TAG}
WORKDIR /workspace/QUsb2snes
ENV CFLAGS="-pipe -O2 -fstack-protector-strong --param=ssp-buffer-size=4 -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security -fPIE -fstack-clash-protection -fcf-protection"
ENV CXXFLAGS="${CFLAGS}"
ENV LDFLAGS="-Wl,-z,relro -Wl,-z,now -Wl,-pie -Wl,--hash-style=gnu -Wl,--no-copy-dt-needed-entries -Wl,--as-needed"
RUN qmake QUSB2SNES_NOGUI=1 CONFIG+='release'
RUN make -j$(cat /proc/cpuinfo | grep 'processor.*:' | wc -l)

FROM debian:stable-slim
WORKDIR /app
COPY --from=builder /workspace/QUsb2snes/QUsb2Snes /app/
RUN mkdir -p /root/.local/share/QUsb2Snes && ln -s /dev/stdout /root/.local/share/QUsb2Snes/log.txt
ARG CACHEBUST=1
RUN ldd /app/QUsb2Snes
ENTRYPOINT ["./QUsb2Snes", "-nogui"]
CMD ["-retroarch"]

