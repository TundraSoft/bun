# Changelog Management Guide

This project maintains `CHANGELOG.md` automatically, following the [Keep a Changelog](https://keepachangelog.com/) format.

## How It Works

When a PR is merged to `main` (or a conventional commit is pushed), the build workflow:

1. Extracts the PR title, number, author, and commit messages.
2. Categorizes the change from title keywords, defaulting to "Changed".
3. Adds a dated entry (`YYYY-MM-DD`) with a PR link and author, skipping duplicates.
4. Commits with `[skip ci]` to avoid a rebuild.

### Categorization

| Keywords | Category |
|----------|----------|
| `feat`, `feature`, `add`, `new` | Added |
| `fix`, `bug`, `issue`, `resolve` | Fixed |
| `security`, `cve`, `vulnerability`, `patch` | Security |
| `docs`, `documentation`, `readme` | Documentation |
| `chore`, `refactor`, `perf`, `style`, `test` | Changed |
| `deprecat` | Deprecated |
| `remov` | Removed |

## Format

```markdown
## [YYYY-MM-DD]

### Added
- PR title ([#123](https://github.com/TundraSoft/bun/pull/123)) by @author

### Fixed
- Another PR title ([#124](https://github.com/TundraSoft/bun/pull/124)) by @author
```

## Best Practices

- Use clear, conventional PR titles — the title becomes the changelog entry and drives categorization. Ambiguous titles fall back to "Changed".
- Reference related issues in the PR body for traceability.
- For releases or bulk updates, edit `CHANGELOG.md` directly; the automation won't duplicate an entry that already references the same PR number.

## Notes

- Entries are grouped by merge date in reverse chronological order.
- Duplicate detection is by PR number.
- To remove an entry, edit `CHANGELOG.md` directly and commit; the automation will not re-add it.

## References

- [Keep a Changelog](https://keepachangelog.com/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
