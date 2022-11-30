FROM alpine:3.16

WORKDIR /opt/reflect-agent

# System dependencies
RUN apk --no-cache add \
  bind-tools \
  wireguard-tools \
  iptables \
  ip6tables \
  inotify-tools \
  jq \
  websocat

# Install 3proxy from source
ENV THREEPROXY_VERSION=0.9.4

RUN apk add alpine-sdk && \
  export DIR=$(mktemp -d) && \
  cd $DIR && \
  wget https://github.com/3proxy/3proxy/archive/refs/tags/${THREEPROXY_VERSION}.tar.gz && \
  tar -xf ${THREEPROXY_VERSION}.tar.gz && \
  rm ${THREEPROXY_VERSION}.tar.gz && \
  mv 3proxy* 3proxy && \
  cd 3proxy && \
  make -f Makefile.Linux || true && \
  mv bin/3proxy /opt/reflect-agent/3proxy && \
  cd && \
  rm -rf $DIR && \
  apk del alpine-sdk

WORKDIR /opt/reflect-agent/src

# Copy in all bash scripts.
COPY src/ .

# Entry point.
CMD ["sh", "./entrypoint.sh"]
