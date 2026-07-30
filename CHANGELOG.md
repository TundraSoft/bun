# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [2026-07-30]

### Fixed
- fix(test): poll HTTP readiness in smoke test to avoid s6 up-before-listen race ([#0](https://github.com/TundraSoft/bun/pull/0)) by @Abhinav_A_V

---

## [2026-07-29]

### Added
- Initial Bun runtime image on Alpine Linux with S6 overlay, native musl binaries, health checks, and CI automation
