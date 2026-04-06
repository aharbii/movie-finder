# Security Policy

## Supported versions

| Component                   | Version   | Supported |
| --------------------------- | --------- | --------- |
| `movie-finder-backend`      | `main`    | ✅        |
| `movie-finder-chain`        | `main`    | ✅        |
| `imdbapi-client`            | `main`    | ✅        |
| `movie-finder-rag`          | `main`    | ✅        |
| `movie-finder-frontend`     | `main`    | ✅        |
| `movie-finder-infrastructure` | `main`  | ✅        |
| All pre-release / tags      | any       | ❌        |

## Reporting a vulnerability

**Do not open a public issue for security vulnerabilities.**

For vulnerabilities that could be exploited by a third party (auth bypass, token theft,
injection, data exposure), please use
[GitHub's private security advisory](https://github.com/aharbii/movie-finder/security/advisories/new).

For lower-severity security concerns (hardening improvements, defence-in-depth, missing
validation), you may open an issue using the **Security Vulnerability** template.

### What to include

- Affected component and version/commit
- Description of the vulnerability and attack scenario
- Steps to reproduce
- Potential impact
- Proposed fix (if any)

### Response timeline

| Severity | Initial response | Fix target   |
| -------- | ---------------- | ------------ |
| Critical | 24 hours         | 72 hours     |
| High     | 48 hours         | 1 week       |
| Medium   | 1 week           | Next release |
| Low      | 2 weeks          | Backlog      |

## Disclosure policy

We follow coordinated disclosure. Please allow time for a fix to be prepared before
disclosing publicly. We will credit reporters in the release notes unless anonymity
is requested.

## Known security issues

Open security issues are tracked in the main repo with the `security` label:
<https://github.com/aharbii/movie-finder/labels/security>

High-priority open items: see [CLAUDE.md](CLAUDE.md#known-open-issues-do-not-duplicate).
