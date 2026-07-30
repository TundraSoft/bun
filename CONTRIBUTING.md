# Contributing to TundraSoft Docker Images

Thanks for your interest in contributing. This document covers how to set up, test, and submit changes.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Reporting Issues](#reporting-issues)
- [Suggesting Features](#suggesting-features)
- [Security Issues](#security-issues)
- [Code Standards](#code-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)
- [Code of Conduct](#code-of-conduct)

---

## Getting Started

### Prerequisites

- Docker (latest stable version)
- Git
- Basic knowledge of Dockerfiles and containerization

### Quick Start

1. Fork the repository
2. Clone your fork locally
3. Create a feature branch
4. Make your changes
5. Test thoroughly
6. Submit a pull request

---

## Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/REPO_NAME.git
cd REPO_NAME

# Add upstream remote
git remote add upstream https://github.com/TundraSoft/REPO_NAME.git

# Create a feature branch
git checkout -b feature/your-feature-name

# Build the image locally
docker build -t local-test .

# Test the image
docker run --rm -it local-test
```

Use a recent Docker with BuildKit enabled, and ensure sufficient disk space for image builds.

---

## How to Contribute

We welcome bug fixes, feature additions, documentation improvements, tests, build/Dockerfile improvements, security enhancements, and cleanup/refactoring.

Workflow:

1. Check existing issues before starting work
2. Open an issue to discuss major changes
3. Fork and branch from `main`
4. Make focused commits with clear messages
5. Test thoroughly
6. Update documentation as needed
7. Submit a pull request with a detailed description

---

## Reporting Issues

Before reporting, search existing issues, test with the latest version, and gather the relevant environment details (OS, Docker version, image tag).

Use the bug report issue template and include a clear description, environment details, reproduction steps, expected vs. actual behaviour, and any error messages or logs.

---

## Suggesting Features

- Be specific about the use case
- Explain the problem the feature solves
- Consider alternatives and mention them
- Provide examples where applicable

Open a feature request issue and discuss it with the maintainers before starting work.

---

## Security Issues

Do not open public issues for security vulnerabilities. Use [GitHub's private vulnerability reporting](../../security/advisories/new) and allow time for assessment and a fix before public disclosure.

General practices: scan images for vulnerabilities, keep base images updated, follow least privilege, avoid including sensitive information in images, and use multi-stage builds to minimize the attack surface.

---

## Code Standards

### Dockerfile

- Use specific base image versions.
- Group related `RUN` commands to minimize layers and clean up caches in the same layer.
- Use meaningful `LABEL`s.
- Run as a non-root user where possible.
- Prefer `COPY` over `ADD`.
- Expose only the ports you need.
- Use exec form for `ENTRYPOINT`/`CMD`.

### Shell scripts

- Start with `set -euo pipefail`.
- Use meaningful variable names and quote expansions.
- Handle errors explicitly and write diagnostics to stderr.

---

## Testing

Before submitting a PR, verify:

- The image builds successfully on the supported architectures
- The container starts and runs without errors
- Services function as expected
- Environment variables and volume mounts work
- Security scans pass without critical issues

```bash
# Build
docker build -t test-image .

# Basic functionality
docker run --rm test-image --version

# Service behaviour
docker run -d --name test-container test-image
docker logs test-container
docker stop test-container

# Multi-architecture
docker buildx build --platform linux/amd64,linux/arm64 .
```

---

## Documentation

- Update `README.md` for new features and environment variables.
- Update `CHANGELOG.md` with your changes.
- Keep version tags and examples current.
- Add inline comments only for non-obvious logic.

---

## Pull Request Process

Before submitting:

- Ensure your fork is up to date with upstream and rebased on `main`
- Test locally
- Update documentation as needed
- Ensure CI checks pass

In the PR description, cover: what changed, the type of change, how it was tested, and any related issues.

Review process: automated checks must pass, followed by maintainer review and merge.

---

## Code of Conduct

Be respectful and constructive. Harassment, discrimination, personal attacks, and spam are not tolerated. Report violations to the maintainers; consequences range from a warning to a permanent ban.
