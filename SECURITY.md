# Security

## Reporting

For security vulnerabilities, use [GitHub's private vulnerability reporting](https://github.com/TundraSoft/bun/security/advisories/new). Do not open public issues for security problems.

We prioritise the latest version, since upstream patches are generally available there first.

Contributors should report issues responsibly, review security scan results before merging, keep dependencies updated, and never commit secrets or sensitive information.

---

## Automated scanning

The repository runs the following on every build, on manual trigger, and daily:

- Trivy — container images, filesystems, dependencies, and OS packages. Results in the GitHub Security tab; the container scan hard-fails the build on fixable HIGH/CRITICAL findings (see `.trivyignore`).
- CodeQL — code security analysis. Results in the GitHub Security tab.
- GitLeaks — secret detection across git history and current files. Fails the build if secrets are found.
- Grype — container vulnerability scanning. Results in the GitHub Security tab.
- Semgrep — static analysis (security patterns, Dockerfile rules). Results in the GitHub Security tab.
- Licensee — license detection and validation. Results in the workflow summary.
