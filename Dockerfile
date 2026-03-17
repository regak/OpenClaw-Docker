FROM ubuntu:24.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive
ARG OPENCLAW_REPO=https://github.com/pjasicek/OpenClaw.git
ARG OPENCLAW_REF=master

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    cmake \
    g++ \
    git \
    libsdl2-dev \
    libsdl2-gfx-dev \
    libsdl2-image-dev \
    libsdl2-mixer-dev \
    libsdl2-ttf-dev \
    make \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 --branch "${OPENCLAW_REF}" "${OPENCLAW_REPO}" OpenClaw

WORKDIR /src/OpenClaw
RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build --parallel

FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsdl2-2.0-0 \
    libsdl2-gfx-1.0-0 \
    libsdl2-image-2.0-0 \
    libsdl2-mixer-2.0-0 \
    libsdl2-ttf-2.0-0 \
    timidity \
    freepats \
    && rm -rf /var/lib/apt/lists/*

ENV TIMIDITY_CFG=/etc/timidity/timidity.cfg

WORKDIR /opt/openclaw
COPY --from=builder /src/OpenClaw/Build_Release/openclaw /opt/openclaw/openclaw

# Runtime assets are required from the original game and should be mounted under /opt/openclaw/Build_Release
RUN mkdir -p /opt/openclaw/Build_Release

ENTRYPOINT ["/opt/openclaw/openclaw"]
