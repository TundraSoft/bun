ARG ALPINE_VERSION=latest\
    BUN_VERSION

FROM tundrasoft/alpine:${ALPINE_VERSION}

LABEL maintainer="Abhinav A V <36784+abhai2k@users.noreply.github.com>" \
      org.opencontainers.image.title="Bun Runtime on Alpine Linux" \
      org.opencontainers.image.description="Lightweight Bun runtime image built on Alpine Linux with S6 overlay, native musl binaries, and developer-friendly utilities" \
      org.opencontainers.image.vendor="TundraSoft" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.url="https://github.com/TundraSoft/bun" \
      org.opencontainers.image.documentation="https://github.com/TundraSoft/bun/blob/main/README.md" \
      org.opencontainers.image.source="https://github.com/TundraSoft/bun.git"

ARG BUN_VERSION \
  TARGETPLATFORM

# Bun ships native musl binaries, so no glibc/distroless shim is needed on Alpine.
ENV BUN_INSTALL=/bun\
    BUN_VERSION=${BUN_VERSION}\
    BUN_INSTALL_BIN=/usr/local/bin\
    BUN_RUNTIME_TRANSPILER_CACHE_PATH=0\
    DO_NOT_TRACK=1\
    FILE=\
    SCRIPT=\
    DEBUG=\
    WATCH=\
    HOT=\
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0\
    S6_KILL_FINISH_MAXTIME=5000

# S6: MAXTIME=0 waits indefinitely for services to start; 5000ms shutdown grace.

# Download Bun with wget (provided by the base image) rather than curl, to keep
# curl and its nghttp2-libs dependency out of the image.
RUN set -eux; \
  apk --update --no-cache add libgcc libstdc++; \
  case "${TARGETPLATFORM}" in \
  "linux/amd64"|"linux/x86_64") export BUN_ARCH="x64-musl-baseline" ;; \
  "linux/arm64"|"linux/arm/v8") export BUN_ARCH="aarch64-musl" ;; \
  "linux/arm/v7") echo "ERROR: Bun does not provide pre-built binaries for 32-bit ARM (armv7). Only x86_64 and arm64 are supported." && exit 1 ;; \
  *) echo "Unsupported platform: ${TARGETPLATFORM}" ; exit 1 ;; \
  esac; \
  wget -qO /tmp/bun.zip https://github.com/oven-sh/bun/releases/download/bun-v${BUN_VERSION}/bun-linux-${BUN_ARCH}.zip; \
  unzip -q -o /tmp/bun.zip -d /tmp; \
  mv /tmp/bun-linux-${BUN_ARCH}/bun /usr/local/bin/bun; \
  chmod 0755 /usr/local/bin/bun; \
  ln -s /usr/local/bin/bun /usr/local/bin/bunx; \
  mkdir -p ${BUN_INSTALL}; \
  setgroup /usr/local/bin/bun ${BUN_INSTALL}; \
  rm -rf /tmp/bun.zip /tmp/bun-linux-${BUN_ARCH};

# x86_64 uses the baseline musl variant so it runs on CPUs without AVX2.

COPY /rootfs /

# nosemgrep: dockerfile.security.missing-user.missing-user
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s CMD ["/usr/bin/healthcheck.sh"]

WORKDIR /app
