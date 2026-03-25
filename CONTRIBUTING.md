# Contributing to Movie Finder

This guide covers the conventions that apply across all repositories in the Movie Finder project — the orchestrator root, the backend, the frontend, and all nested submodules.

For team-specific details, follow the links in the [role-based index](#role-based-index) below.

---

## Table of contents

1. [Role-based index](#role-based-index)
2. [Branching strategy](#branching-strategy)
3. [Commit messages](#commit-messages)
4. [Pull requests](#pull-requests)
5. [Code standards](#code-standards)
6. [Testing requirements](#testing-requirements)
7. [Submodule workflow](#submodule-workflow)
8. [Release process](#release-process)
9. [CI/CD](#cicd)
10. [Security](#security)

---

## Role-based index

| I am… | My CONTRIBUTING guide |
|-------|----------------------|
| New to the project | Read this file, then [ONBOARDING.md](ONBOARDING.md) |
| Backend / App engineer | [backend/CONTRIBUTING.md](backend/CONTRIBUTING.md) |
| AI / Chain engineer | [backend/chain/CONTRIBUTING.md](backend/chain/CONTRIBUTING.md) |
| IMDb API engineer | [backend/imdbapi/CONTRIBUTING.md](backend/imdbapi/CONTRIBUTING.md) |
| RAG / Data engineer | [backend/rag_ingestion/CONTRIBUTING.md](backend/rag_ingestion/CONTRIBUTING.md) |
| Frontend engineer | [frontend/CONTRIBUTING.md](frontend/CONTRIBUTING.md) |
| DevOps / Platform | [docs/devops-setup.md](docs/devops-setup.md) |

---

## Branching strategy

All repositories follow **trunk-based development** with short-lived feature branches.

```
main          ← always deployable; protected; requires PR + at least 1 approval
  └── feature/<short-description>    new capability
  └── fix/<short-description>        bug fix
  └── chore/<short-description>      tooling, dependencies, CI, scripts
  └── docs/<short-description>       documentation only
  └── hotfix/<short-description>     urgent production fix (merge + tag immediately)
```

**Rules:**
- Never push directly to `main`
- Branch names must be **all lowercase, kebab-case**: `feature/sse-reconnect-logic` ✓ — `Feature/SSE-Reconnect` ✗
- Delete the branch after the PR is merged (GitHub → "Delete branch" button)
- Target merge within the same sprint; stale branches are cleaned up weekly

### GitHub branch and tag protection (rulesets)

All 8 repositories have two active GitHub rulesets enforcing:

| Ruleset | Target | Rules enforced |
|---|---|---|
| `main-branch-protection` | `main` branch | PR required · 1 approval · no force-push · no deletion · stale reviews dismissed |
| `tag-protection` | All tags | No deletion · no force-push |

**Branch and tag naming patterns are documented policy** (see below), not an automated gate.
GitHub's `branch_name_pattern` and `tag_name_pattern` ruleset rules require GitHub Enterprise Cloud
and are not available on GitHub Free/Pro. The naming conventions are enforced by code review.

### Tag naming convention

All release tags must follow [Semantic Versioning](https://semver.org/) with a `v` prefix:

```
v<MAJOR>.<MINOR>.<PATCH>              e.g. v1.2.3
v<MAJOR>.<MINOR>.<PATCH>-<pre>       e.g. v1.2.3-rc.1
```

- Lowercase `v` prefix required
- No leading zeros in version numbers: `v1.02.3` ✗
- Pre-release identifiers: lowercase alphanumeric + dots + hyphens only

---

## Commit messages

All repositories use [Conventional Commits](https://www.conventionalcommits.org/).

```
<type>(<scope>): <short summary>

[optional body — explain WHY, not WHAT]

[optional footer — breaking changes, issue references]
```

**Types:**

| Type | When |
|------|------|
| `feat` | New feature or user-facing capability |
| `fix` | Bug fix |
| `chore` | Tooling, dependency, CI, or script change |
| `docs` | Documentation only |
| `test` | Adding or correcting tests |
| `refactor` | Code restructuring without behaviour change |
| `perf` | Performance improvement |
| `ci` | Pipeline or Jenkins file changes |

**Scope** — the package or area affected:

```
feat(chain): add gemini embedding provider
fix(imdbapi): handle 429 rate-limit in retry loop
chore(frontend): bump angular to 21.3.0
docs(root): add structurizr c4 model
ci(backend): run lint stages in parallel
```

**Summary rules:**
- Lowercase, no trailing period
- Imperative mood: "add", not "added" or "adds"
- ≤ 72 characters

---

## Pull requests

### Before opening a PR

**Backend:**
```bash
make lint    # zero errors required
make test    # zero failures required
```

**Frontend:**
```bash
npm run typecheck
npm run lint
npm run test:ci
```

**Docs-only or docs-affecting changes:**
- If your PR changes the `docs` submodule pointer, `mkdocs.yml`, `requirements-docs.txt`,
  `README.md`, `CONTRIBUTING.md`, `ONBOARDING.md`, or submodule pointers such as
  `backend` / `frontend`,
  GitHub Actions also runs the documentation workflow before merge.
- That workflow prepares generated docs pages from submodule READMEs and runs `mkdocs build`.

Pre-commit hooks run on every `git commit`. They enforce linting, formatting, type checking, and secret detection. If they fail, fix the reported issue before retrying — do not bypass with `--no-verify`.

### PR title

Same format as the commit message summary:

```
feat(chat): add session deletion endpoint
fix(frontend): clear token on 401 interceptor response
```

### PR description

Use the pull request template (`.github/PULL_REQUEST_TEMPLATE.md`). Required sections:

- **What** — what changed and why
- **How to test** — steps a reviewer can follow manually
- **Checklist** — lint, tests, docs, env var changes

### Review requirements

- Minimum **1 approval** from a team member who did not author the PR
- All CI stages must be green before merge is allowed
- All reviewer comments must be resolved (mark as resolved by the commenter, not the author)

### Merge strategy

| Situation | Strategy |
|-----------|----------|
| Feature / fix / chore branch | **Squash and merge** — clean history on `main` |
| Submodule pointer bump | **Merge commit** — preserves the pointer commit |
| Hotfix | Squash and merge, then immediately tag a patch release |

---

## Code standards

### Python (backend, chain, imdbapi, rag_ingestion)

| Tool | Purpose | Config |
|------|---------|--------|
| ruff | Lint + format | `pyproject.toml [tool.ruff]` |
| mypy (strict) | Type checking | `pyproject.toml [tool.mypy]` |
| detect-secrets | Secret scanning | `.secrets.baseline` |

Line length: **100 characters**. Target Python version: **3.13**.

All public functions must have type annotations. `# type: ignore` is allowed only as a last resort, always with a comment.

```bash
# Backend auto-fix
make lint-fix

# Backend check only (what CI runs)
make lint
```

### TypeScript (frontend)

| Tool | Purpose | Config |
|------|---------|--------|
| ESLint 9 (flat config) | Lint | `eslint.config.js` |
| Prettier 3 | Format | `.prettierrc` |
| tsc --noEmit | Type check | `tsconfig.json` |

```bash
# Frontend auto-fix
npm run lint:fix && npm run format

# Frontend check only (what CI runs)
npm run typecheck && npm run lint && npm run format:check
```

---

## Testing requirements

### Universal rules

- All new logic must have corresponding unit tests
- No real network calls in tests — mock at the HTTP boundary
- Test coverage must not decrease on any PR (enforced by CI via Cobertura reports)
- Tests must be deterministic — no time-dependent or order-dependent tests

### Backend

| Package | Test runner | Mock library |
|---------|------------|-------------|
| app | pytest + pytest-asyncio | pytest-mock |
| chain | pytest | pytest-mock |
| imdbapi | pytest | respx (HTTP-level mocking) |
| rag_ingestion | pytest | pytest-mock |

Tests live in `tests/` mirroring `src/`.

```bash
make test           # all packages
make test-app       # FastAPI app only (requires make db-start)
make test-chain     # LangGraph chain
make test-imdbapi   # IMDb client
make test-rag       # RAG ingestion
```

### Frontend

Tests use Vitest with Angular TestBed. Coverage provided by `@vitest/coverage-v8`.

```bash
npm run test:ci     # single run, generates JUnit + Cobertura XML in coverage/
```

---

## Submodule workflow

### Initial clone

```bash
git clone --recurse-submodules https://github.com/aharbii/movie-finder.git
```

### Update all submodules to their latest remote `main`

```bash
git submodule update --remote --merge
```

### Update one submodule

```bash
cd backend/chain
git fetch && git checkout main && git pull
cd ../..
git add backend/chain
git commit -m "chore(chain): bump to latest main"
```

### Pin a submodule to a specific release

```bash
cd backend/chain
git fetch --tags && git checkout v1.2.0
cd ../..
git add backend/chain
git commit -m "chore(chain): pin to v1.2.0"
```

### After pulling root changes that moved a submodule pointer

```bash
git pull
git submodule update --init --recursive
```

---

## Release process

Each repository is released independently following [Semantic Versioning](https://semver.org/).

```
vMAJOR.MINOR.PATCH

MAJOR — breaking API or behaviour change
MINOR — new feature, backwards compatible
PATCH — bug fix, backwards compatible
```

**Steps:**

1. Ensure `main` is green on Jenkins
2. Update `version` in `pyproject.toml` (backend packages) or `package.json` (frontend)
3. Update `CHANGELOG.md` — move items from `[Unreleased]` to the new version section
4. Commit: `git commit -m "chore: release v1.2.0"`
5. Tag: `git tag v1.2.0 -m "v1.2.0"`
6. Push: `git push origin main --tags`

Jenkins detects the `v*` tag and automatically runs the RELEASE pipeline (lint → test → build → push `:v1.2.3` to ACR → production deploy with manual approval for backend).

After releasing a submodule, update the pointer in the backend repo:
```bash
cd backend/chain && git checkout v1.2.0 && cd ../..
git add backend/chain
git commit -m "chore(chain): pin to v1.2.0"
git push
```

---

## CI/CD

### Pipeline modes

| Mode | Git trigger | Stages |
|------|------------|--------|
| CONTRIBUTION | Feature branch / PR | Lint · Test |
| INTEGRATION | Push to `main` | Lint · Test · Build Docker · Push `:sha8` + `:latest` to ACR · (opt) Staging deploy |
| RELEASE | `v*` tag | Lint · Test · Build Docker · Push `:v1.2.3` to ACR · Production deploy |

CONTRIBUTION builds give developers fast feedback (< 5 minutes). Nothing is built or pushed to ACR.

### Documentation workflow

Docs-related pull requests also run `.github/workflows/docs.yml` on GitHub Actions. That check:

- copies generated documentation pages from submodule READMEs
- runs `mkdocs build`
- does **not** deploy GitHub Pages from pull requests

Documentation is deployed to GitHub Pages only on pushes to `main`.

### Required Jenkins credentials

See [`docs/devops-setup.md §9`](docs/devops-setup.md#9-jenkins--credentials) for the full credential table and how to add them.

### Triggering a manual staging deploy

1. Open the `movie-finder-backend` or `movie-finder-frontend` pipeline in Jenkins
2. **Build with Parameters**
3. Set `DEPLOY_STAGING=true`
4. Click **Build**

---

## Security

- **Never commit secrets.** The `detect-secrets` pre-commit hook blocks API keys, passwords, and tokens. If a file is flagged as a false positive, add `# pragma: allowlist secret` inline and update the baseline with `detect-secrets scan > .secrets.baseline`
- **Never use `--no-verify` to bypass pre-commit hooks** unless directed by a team lead, and always follow up with a clean commit
- **Production secrets live in Azure Key Vault.** They are injected into Container Apps at runtime via managed identity. They are never passed through Jenkins build logs or baked into Docker images
- **Rotate secrets via Key Vault**, not by editing pipelines. See [`docs/devops-setup.md §12`](docs/devops-setup.md#12-runtime-secrets--azure-key-vault)
- Report security vulnerabilities privately to the project owner before creating a public issue
