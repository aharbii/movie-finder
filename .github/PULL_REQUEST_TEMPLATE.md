## What

<!-- What changed and why? Link the issue or requirement this addresses. -->

Closes #

## Type of change

- [ ] Feature (new capability)
- [ ] Bug fix (non-breaking)
- [ ] Breaking change (API or behaviour change affecting consumers)
- [ ] Chore (tooling, dependencies, CI, refactor)
- [ ] Documentation only

## How to test

<!-- Steps a reviewer can follow to verify this change manually. -->

1.
2.
3.

## Checklist

### Code quality

- [ ] `make lint` (backend) / `npm run typecheck && npm run lint` (frontend) — zero errors
- [ ] `make test` (backend) / `npm run test:ci` (frontend) — zero failures
- [ ] Test coverage has not decreased

### Review

- [ ] Conventional commit title: `type(scope): summary`
- [ ] PR description explains the *why*, not just the *what*
- [ ] Reviewer comments are addressed before requesting re-review

### Submodule changes (if applicable)

- [ ] Nested submodule committed and pushed to its own remote
- [ ] Parent repo submodule pointer updated with `git add <submodule-path>` + commit

### Configuration / environment (if applicable)

- [ ] New environment variables added to `.env.example` with placeholder values and comments
- [ ] `docs/openapi.yaml` updated if any API endpoint was added, changed, or removed
- [ ] `CHANGELOG.md` updated with a summary under `[Unreleased]`

### Security

- [ ] No secrets, credentials, or internal URLs committed
- [ ] `detect-secrets` pre-commit hook passed (or false positives annotated with `# pragma: allowlist secret`)

## Screenshots (for UI changes)

<!-- Before / after screenshots or screen recordings. Delete section if not applicable. -->

## Notes for reviewers

<!-- Anything a reviewer should know that is not obvious from the diff. -->
