# TundraSoft Bun Runtime Image

<!-- DESCRIPTION-START -->
A lightweight Bun runtime image built on Alpine Linux with S6 overlay, native musl binaries, and developer-friendly utilities.
<!-- DESCRIPTION-END -->

[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/TundraSoft/bun/build-docker.yml?event=push&logo=github&label=build)](https://github.com/TundraSoft/bun/actions/workflows/build-docker.yml)
[![Security Scan](https://img.shields.io/github/actions/workflow/status/TundraSoft/bun/security-scan.yml?logo=adguard&label=security)](https://github.com/TundraSoft/bun/actions/workflows/security-scan.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/tundrasoft/bun.svg?logo=docker)](https://hub.docker.com/r/tundrasoft/bun)
[![License](https://img.shields.io/github/license/TundraSoft/bun.svg)](https://github.com/TundraSoft/bun/blob/main/LICENSE)

---

## Table of Contents

- [Quick Start](#quick-start)
- [Available Tags](#available-tags)
- [Features](#features)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Running Applications](#running-applications)
  - [Environment Variables](#environment-variables)
  - [Permissions](#permissions)
  - [Volumes](#volumes)
- [Build-Time Optimization](#build-time-optimization)
- [Development Mode](#development-mode)
- [Service Management](#service-management)
- [Cron Jobs](#cron-jobs)
- [Building](#building)
- [Security](#security)
- [Components](#components)
- [Reference](#reference)
- [Changelog](#changelog)
- [Contributing](#contributing)

---

## Quick Start

### Available Registries

This image is published to both Docker Hub and the GitHub Container Registry:

- Docker Hub: `tundrasoft/bun`
- GitHub Container Registry: `ghcr.io/tundrasoft/bun`

```bash
# Pull from Docker Hub
docker pull tundrasoft/bun:latest

# Pull from GitHub Container Registry
docker pull ghcr.io/tundrasoft/bun:latest

# Run a local Bun application (mount your code into /app)
docker run -d \
  -p 8080:8080 \
  -e FILE=/app/server.ts \
  -v $(pwd):/app \
  --name bun-app \
  tundrasoft/bun:latest

# Run with a custom timezone and a package.json script
docker run -d \
  -e TZ=Asia/Kolkata \
  -e SCRIPT=start \
  -v $(pwd):/app \
  --name my-bun-app \
  tundrasoft/bun:latest
```

With no `FILE` or `SCRIPT` set, the container runs a small built-in demo server on port `8080` so you can confirm the image works.

---

## Available Tags

<!-- TAGS-START -->
| Version | Tags |
|---------|------|
| [latest](https://hub.docker.com/r/tundrasoft/bun/tags?name=latest) | Latest stable release |
| [edge](https://hub.docker.com/r/tundrasoft/bun/tags?name=edge) | Edge/development version |
| [1.3](https://hub.docker.com/r/tundrasoft/bun/tags?name=1.3) | [1.3.14](https://hub.docker.com/r/tundrasoft/bun/tags?name=1.3.14), [1.3.13](https://hub.docker.com/r/tundrasoft/bun/tags?name=1.3.13), [1.3.12](https://hub.docker.com/r/tundrasoft/bun/tags?name=1.3.12), [1.3.11](https://hub.docker.com/r/tundrasoft/bun/tags?name=1.3.11), [1.3.10](https://hub.docker.com/r/tundrasoft/bun/tags?name=1.3.10) |

<!-- TAGS-END -->

---

## Features

- Latest Bun runtime — an all-in-one JavaScript/TypeScript runtime, bundler, test runner, and package manager
- Alpine Linux base — minimal, secure base OS
- Native musl binaries — uses Bun's official Alpine/musl builds, so no glibc shims are required
- S6 overlay — process supervision and service management
- Non-root `tundra` user (UID/GID 1000)
- Node.js compatibility — run many Node.js packages and built-in modules out of the box
- Hot reload and watch — built-in `--hot` and `--watch` modes
- Timezone support
- Cron support — dynamic cron job loading with environment-variable substitution
- Health monitoring — built-in health checks

---

## Usage

### Basic Usage

Use as a base image in your Dockerfile:

```dockerfile
# From Docker Hub
FROM tundrasoft/bun:latest
COPY . /app
```

```dockerfile
# From GitHub Container Registry
FROM ghcr.io/tundrasoft/bun:latest
COPY . /app
```

For specific versions:
```dockerfile
FROM tundrasoft/bun:1.3.14
# or with a specific Alpine version
FROM tundrasoft/bun:alpine-3.22-1.3.14
```

### Running Applications

The image decides what to run based on two environment variables:

- `FILE` — run a single file directly (`bun run <FILE>`)
- `SCRIPT` — run a script defined in `package.json` (`bun run <SCRIPT>`)

`SCRIPT` takes precedence over `FILE`. If neither is set, a minimal demo server is started.

Run a file:
```bash
docker run -p 8080:8080 \
  -e FILE=/app/server.ts \
  -v $(pwd):/app \
  tundrasoft/bun:latest
```

Run a package.json script:
```bash
docker run -v $(pwd):/app \
  -e SCRIPT=start \
  tundrasoft/bun:latest
```

Run with environment variables:
```bash
docker run -d \
  -e FILE=/app/server.ts \
  -e PUID=1001 \
  -e PGID=1001 \
  -e TZ=America/New_York \
  -v $(pwd):/app \
  tundrasoft/bun:latest
```

### Environment Variables

<!-- ENV-VARS-START -->
| Variable | Description | Default |
|----------|-------------|---------|
| `SCRIPT` | Run a script from `package.json` (takes precedence over `FILE`) | N/A |
| `FILE` | The file to run directly with `bun run` | N/A |
| `BUN_INSTALL` | Directory for Bun's global installs and module cache | `/bun` |
| `PUID` | User ID for the `tundra` user | `1000` |
| `PGID` | Group ID for the `tundra` group | `1000` |
| `TZ` | Timezone (e.g., `Asia/Kolkata`, `America/New_York`) | `UTC` |
| `NODE_ENV` | Standard Node/Bun environment hint (e.g., `production`) | N/A |
| `DEBUG` | Enable debug mode with verbose output (1 to enable) | N/A |
| `WATCH` | Restart on file changes via `--watch` (1 to enable) | N/A |
| `HOT` | Hot-reload in place via `--hot` (1 to enable; takes precedence over `WATCH`) | N/A |
| `S6_CMD_WAIT_FOR_SERVICES_MAXTIME` | Max time (ms) to wait for services to start (0 = infinite) | `0` |
| `S6_KILL_FINISH_MAXTIME` | Grace period (ms) for graceful shutdown | `5000` |
<!-- ENV-VARS-END -->

### Permissions

Unlike Deno, Bun does not implement a runtime permission sandbox — code runs with the same privileges as the process. There are therefore no `--allow-*` flags or `ALLOW_*` environment variables.

Isolate untrusted workloads at the container boundary instead:

```bash
# Drop capabilities, read-only rootfs, and run as the non-root tundra user
docker run --read-only --tmpfs /tmp --tmpfs /run \
  --user 1000:1000 --cap-drop=ALL \
  -e FILE=/app/main.ts \
  -v $(pwd):/app:ro \
  tundrasoft/bun:latest
```

See [Security](#security) for hardening guidance.

### Volumes

| Path | Description |
|------|-------------|
| `/app` | Application root directory (recommended to mount as a volume) |
| `/crons` | Directory for cron job files (automatically loaded) |
| `/bun` | Bun cache and global install directory (`BUN_INSTALL`, for persisting dependencies) |

---

## Build-Time Optimization

Install dependencies during the image build to eliminate cold-start downloads.

Install from a lockfile (best layer caching):
```dockerfile
FROM tundrasoft/bun:latest

# Copy manifests first so this layer is cached until they change
COPY package.json bun.lock /app/
RUN bun install --frozen-lockfile

COPY . /app

ENV FILE=/app/index.ts
```

Install production-only dependencies:
```dockerfile
FROM tundrasoft/bun:latest

COPY package.json bun.lock /app/
RUN bun install --frozen-lockfile --production

COPY . /app

ENV SCRIPT=start
```

Compile to a single-file executable:
```dockerfile
FROM tundrasoft/bun:latest AS build

COPY . /app
RUN bun install --frozen-lockfile
RUN bun build /app/index.ts --compile --outfile /app/server

FROM tundrasoft/bun:latest
COPY --from=build /app/server /app/server
ENV FILE=/app/server
```

Benefits:

- Faster cold starts — no dependency downloads at runtime
- Reproducible builds — `--frozen-lockfile` pins exact versions
- Offline compatible — works in isolated environments
- Layer caching — a separate install layer caches better
- No surprise downloads in production

---

## Development Mode

Combine `DEBUG`, `WATCH`/`HOT`, and a volume mount for a fast feedback loop.

Watch mode (restart on change):
```bash
docker run -it \
  -e DEBUG=1 \
  -e WATCH=1 \
  -e FILE=/app/main.ts \
  -v $(pwd):/app \
  -p 8080:8080 \
  tundrasoft/bun:latest
```

Hot reload (update in place, preserve state):
```bash
docker run -it \
  -e HOT=1 \
  -e FILE=/app/server.ts \
  -v $(pwd):/app \
  -p 8080:8080 \
  tundrasoft/bun:latest
```

- `DEBUG=1`: verbose startup output with argument inspection
- `WATCH=1`: file watching with a full restart on changes (`bun --watch`)
- `HOT=1`: hot module reloading in place (`bun --hot`), taking precedence over `WATCH`

With a package.json script:
```bash
docker run -it \
  -e DEBUG=1 \
  -e HOT=1 \
  -e SCRIPT=dev \
  -v $(pwd):/app \
  -p 8080:8080 \
  tundrasoft/bun:latest
```

---

## Service Management

This image uses [S6 Overlay](https://github.com/just-containers/s6-overlay) for process supervision and service management. The Bun service runs your application under S6, which provides:

- Automatic restart on failure
- Graceful shutdown handling
- Signal handling
- Logging integration
- Health monitoring

### Service Startup and Shutdown Configuration

Control S6 service supervision timeouts:

```bash
# Custom startup timeout (30 seconds max wait)
docker run -d \
  -e S6_CMD_WAIT_FOR_SERVICES_MAXTIME=30000 \
  -e FILE=/app/server.ts \
  tundrasoft/bun:latest

# Extended graceful shutdown (10 seconds)
docker run -d \
  -e S6_KILL_FINISH_MAXTIME=10000 \
  -e FILE=/app/server.ts \
  tundrasoft/bun:latest

# Infinite startup wait (for slow-starting apps)
docker run -d \
  -e S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
  -e FILE=/app/server.ts \
  tundrasoft/bun:latest
```

### Service Triggers

S6 provides dependency management through trigger points:

| Trigger | Description |
|---------|-------------|
| `os-ready` | Container booted, basic setup complete |
| `config-start` | Start configuration changes |
| `config-ready` | Configuration complete |
| `service-start` | Application services begin |
| `service-ready` | All services initialized |

### Adding Custom Services

You can extend the image with additional services:

```dockerfile
FROM tundrasoft/bun:latest

RUN apk add --no-cache redis

RUN mkdir -p /etc/s6-overlay/s6-rc.d/redis/dependencies.d
RUN echo "longrun" > /etc/s6-overlay/s6-rc.d/redis/type

RUN cat > /etc/s6-overlay/s6-rc.d/redis/run << 'EOF'
#!/command/with-contenv sh
exec 2>&1
exec redis-server --bind 127.0.0.1
EOF

RUN chmod +x /etc/s6-overlay/s6-rc.d/redis/run
RUN touch /etc/s6-overlay/s6-rc.d/redis/dependencies.d/service-start
RUN touch /etc/s6-overlay/s6-rc.d/user/contents.d/redis
```

---

## Cron Jobs

The image supports dynamic cron job loading with environment-variable substitution:

1. Create cron files in the `/crons` directory
2. Use environment variables with `$VARIABLE_NAME` syntax
3. Pass the environment variables when running the container
4. S6 loads and installs the jobs at startup

### Basic Scheduled Task

`/crons/daily-cleanup`:
```bash
# Run cleanup at 3 AM daily
0 3 * * * find /tmp -type f -mtime +7 -delete
```

```bash
docker run -d \
  -v /host/crons:/crons:ro \
  tundrasoft/bun:latest
```

### Application Health Check

`/crons/health-check`:
```bash
# Check application health every 5 minutes
*/5 * * * * curl -f http://localhost:8080/health || exit 1
```

```bash
docker run -d \
  -p 8080:8080 \
  -e FILE=/app/server.ts \
  -v /host/crons:/crons:ro \
  -v $(pwd):/app \
  tundrasoft/bun:latest
```

### Environment Substitution

`/crons/maintenance-jobs`:
```bash
$BACKUP_TIME /usr/local/bin/backup.sh >> /var/log/cron-backup.log 2>&1
$LOG_ROTATE_TIME logrotate /etc/logrotate.conf
$CLEANUP_TIME rm -rf /tmp/bun-cache-*
```

```bash
docker run -d \
  -e BACKUP_TIME='0 2 * * *' \
  -e LOG_ROTATE_TIME='0 0 * * *' \
  -e CLEANUP_TIME='0 4 * * 0' \
  -v /host/crons:/crons:ro \
  tundrasoft/bun:latest
```

---

## Building

```bash
docker build \
  --build-arg ALPINE_VERSION=latest \
  --build-arg BUN_VERSION=1.3.14 \
  -t my-bun-image .
```

### Build Arguments

<!-- BUILD-ARGS-START -->
| Argument | Description | Example |
|----------|-------------|---------|
| `ALPINE_VERSION` | Alpine Linux version (base image) | `latest`, `3.22`, `3.21` |
| `BUN_VERSION` | Bun runtime version | `1.3.14`, `1.2.19` |
<!-- BUILD-ARGS-END -->

The `x86_64` image uses Bun's `x64-musl-baseline` build for maximum CPU compatibility (no AVX2 requirement); `arm64` uses `aarch64-musl`. 32-bit ARM (armv7) is not supported, as Bun does not ship binaries for it.

---

## Security

This repository runs layered security scanning:

- Trivy, CodeQL, Semgrep, and Grype
- Secret detection with GitLeaks
- Automated reporting to the GitHub Security tab
- Daily scheduled scans

### Security Model

Bun has no built-in permission sandbox, so isolation is enforced at the container level rather than by the runtime.

Container runtime hardening:
```bash
# Read-only root filesystem
docker run --read-only --tmpfs /tmp --tmpfs /run tundrasoft/bun:latest

# Specific user and dropped capabilities
docker run --user 1000:1000 --cap-drop=ALL tundrasoft/bun:latest

# Resource limits
docker run --memory=512m --cpus=1 --pids-limit=100 tundrasoft/bun:latest
```

File system:
```bash
# Mount application files as read-only
docker run -v $(pwd):/app:ro tundrasoft/bun:latest

# Mount secrets read-only
docker run -v /host/secrets:/secrets:ro,Z tundrasoft/bun:latest
```

Production:
```bash
# Use specific version tags, not 'latest'
docker run tundrasoft/bun:1.3.14

# Use custom networks
docker network create --driver bridge secure-app-net
docker run --network secure-app-net tundrasoft/bun:1.3.14

# Enable logging
docker run --log-driver=json-file --log-opt max-size=10m tundrasoft/bun:1.3.14
```

For security issues, use [GitHub's private vulnerability reporting](https://github.com/TundraSoft/bun/security/advisories/new).

---

## Components

Base system:
- Alpine Linux 3.22 — minimal and reliable
- S6 Overlay v3 — process supervision with lifecycle management
- OpenSSL 3.x — cryptographic and TLS support

Runtime:
- Bun — all-in-one JavaScript/TypeScript runtime
- Node.js compatibility via Bun's Node API compatibility layer
- TypeScript and JSX executed directly, no separate build step

Utilities:
- cURL — HTTP client
- Bash/sh — shell scripting
- Healthcheck script — S6-integrated service monitoring

---

## Reference

### Container Lifecycle

| Stage | Description | Services |
|-------|-------------|----------|
| Boot | Initialize system and user | `os-ready` → `service-ready` |
| Config | Load configuration | `config-start` → `config-ready` |
| Main | Run application/cron | `bun` or `crond` |
| Shutdown | Clean termination | S6 async handlers |

### Directory Structure

```
/bun/             - Bun cache & global installs (mounted volume)
/app/             - Application code
/etc/s6-overlay/  - S6 service definitions
/etc/crontabs/    - Cron jobs (if using cron)
/etc/timezone     - TZ configuration
/run/s6/          - S6 runtime (temporary)
```

### Docker Compose Example

```yaml
services:
  app:
    image: tundrasoft/bun:latest
    environment:
      - FILE=/app/src/main.ts
      - TZ=UTC
    volumes:
      - ./src:/app
      - bun-cache:/bun
    ports:
      - "8000:8000"
    healthcheck:
      test: ["CMD", "/usr/bin/healthcheck.sh"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  bun-cache:
```

### Troubleshooting

Application not starting:
```bash
# View logs for startup errors
docker logs <container-id>

# Run with DEBUG for verbose output
docker run -it -e DEBUG=1 -e FILE=/app/main.ts tundrasoft/bun:latest

# Check healthcheck status
docker exec <container-id> /usr/bin/healthcheck.sh

# Verify the file exists and is readable
docker exec <container-id> ls -la /app/main.ts
```

Slow cold start (first-run dependency download):
```bash
# Persist the cache with a volume
docker run -v bun-cache:/bun -e FILE=/app/main.ts tundrasoft/bun:latest
```
```dockerfile
# Or install dependencies during the build
FROM tundrasoft/bun:latest
COPY package.json bun.lock /app/
RUN bun install --frozen-lockfile
COPY . /app
ENV FILE=/app/main.ts
```

Module resolution problems ("Cannot find module"):
```bash
# Ensure dependencies are installed into /app/node_modules
docker run -v $(pwd):/app -w /app tundrasoft/bun:latest bun install
```

Watch/hot mode not reloading:
```bash
# Verify the source is mounted and reload mode is active
docker run -it -e WATCH=1 -e DEBUG=1 \
  -e FILE=/app/main.ts \
  -v $(pwd):/app \
  tundrasoft/bun:latest
```

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines, and [CHANGELOG.md](CHANGELOG.md) for release notes.

---

[View on GitHub](https://github.com/TundraSoft/bun) · [Docker Hub](https://hub.docker.com/r/tundrasoft/bun) · [Report an issue](https://github.com/TundraSoft/bun/issues)
