# Claude Code — Movie Finder project context

Loaded automatically at the start of every Claude Code session for this repo.
Human-maintained and committed — shared source of truth for how Claude works in this project.

---

## Project overview

**Movie Finder** is a full-stack, enterprise-grade AI application.
A user describes a half-remembered film in natural language; the system finds it via semantic
search, enriches it with live IMDb metadata, and answers follow-up questions via a streamed chat UI.

**Repo structure:** recursive Git submodules — each submodule is an independently versioned repo.

| Path | GitHub repo | Role |
|---|---|---|
| `.` | `aharbii/movie-finder` | Parent orchestrator |
| `backend/` | `aharbii/movie-finder-backend` | FastAPI + uv workspace root |
| `backend/app/` | (nested in backend) | FastAPI application layer |
| `backend/chain/` | `aharbii/movie-finder-chain` | LangGraph 8-node AI pipeline |
| `backend/imdbapi/` | `aharbii/imdbapi-client` | Async IMDb REST client |
| `backend/rag_ingestion/` | `aharbii/movie-finder-rag` | Offline embedding ingestion |
| `frontend/` | `aharbii/movie-finder-frontend` | Angular 21 SPA |
| `docs/` | `aharbii/movie-finder-docs` | MkDocs documentation site |
| `infrastructure/` | `aharbii/movie-finder-infrastructure` | IaC / Azure provisioning |

---

## GitHub repos and issue tracking

All issues (bugs, features, findings, RFCs) are created in **`aharbii/movie-finder`** first.
Submodule repos have linked child issues.

```bash
# 1. Create parent issue
gh issue create --repo aharbii/movie-finder --title "feat: <title>" --label "enhancement"
# 2. Create submodule issue linked to parent
gh issue create --repo aharbii/<submodule-repo> --title "feat: <title>" \
  --body "Part of aharbii/movie-finder#<N>"
# List open issues before starting any task
gh issue list --repo aharbii/movie-finder --state open
```

---

## AI agent context files

This project supports multiple AI coding agents. Each reads its own context file per submodule:

| Agent | File | Notes |
|---|---|---|
| **Claude Code** (VSCode extension + CLI) | `CLAUDE.md` | Primary tool. VSCode extension and CLI share the same context. |
| **Gemini CLI** | `GEMINI.md` | Fallback when Claude usage limit is reached. |
| **OpenAI Codex CLI** | `AGENTS.md` | Alternative for collaborators. Auto-generated from `GEMINI.md`. |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Per-repo file. Root and submodules can each define their own Copilot instructions. |

**Maintenance rule:** any structural change (new pattern, new tool, new workflow, VSCode config update) must be mirrored across `CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, and `.github/copilot-instructions.md` in every affected repo.

### Claude Code: VSCode extension vs CLI

They are **the same agent** — same model, same `CLAUDE.md` context, same capabilities. The difference:
- **VSCode extension** (primary): has IDE context — open file, selection, diagnostics, file tree. Use this for all interactive development.
- **CLI** (`claude` in terminal): no IDE context. Useful for scripted automation, CI usage, or working outside VSCode. Not worth switching to for interactive work.

**Recommendation:** use the VSCode extension as your default. Fall back to Gemini CLI when Claude's usage limit is hit. The CLI provides no benefit over the extension for interactive tasks.

---

## Available toolchain

| Tool | Purpose |
|---|---|
| `gh` | GitHub CLI — issues, PRs, secrets, repos |
| `git` | Version control and submodule workflow |
| `docker` / `docker compose` | Build and run containers locally |
| `uv` | Python package manager (backend workspace) |
| `npm` | Frontend package manager |
| `plantuml` | Render `.puml` → PNG locally |
| `mkdocs` | Documentation site (run `./scripts/prepare-docs.sh` first) |

**Structurizr C4 viewer** (local):
```bash
docker compose -f docker-compose.docs.yml up   # → http://localhost:8080
```

**OpenAPI docs** (when backend is running): `http://localhost:8000/docs`

---

## VSCode setup

Every submodule that can be opened as a standalone workspace has its own committed `.vscode/`
directory with settings, extensions, launch configs, and tasks.

**Workspace hierarchy — each workspace includes all capabilities of its children.**

| Workspace | `.vscode/` contents | Scope |
|---|---|---|
| Root (`movie-finder/`) | settings, extensions, `launch.json`, `tasks.json` | All packages: backend (app/chain/imdbapi/rag) + frontend + docs + Docker full stack |
| `backend/` | settings, extensions, `launch.json`, `tasks.json` | All backend packages: app + chain + imdbapi + rag_ingestion |
| `backend/chain/` | settings, extensions, `launch.json`, `tasks.json` | chain only |
| `backend/rag_ingestion/` | settings, extensions, `launch.json`, `tasks.json` | rag_ingestion only (standalone uv) |
| `backend/imdbapi/` | settings, extensions, `launch.json`, `tasks.json` | imdbapi only |
| `frontend/` | settings, extensions, `launch.json`, `tasks.json` | Angular SPA only |
| `docs/` | settings, extensions | PlantUML + Markdown editing |
| `infrastructure/` | settings, extensions | IaC editing (Terraform/Bicep) |

### Python interpreter paths

| Submodule | Interpreter path in `.vscode/settings.json` | How to create |
|---|---|---|
| `backend/` | `${workspaceFolder}/.venv/bin/python` | `uv sync --all-packages` from `backend/` |
| `backend/chain/` | `${workspaceFolder}/../.venv/bin/python` | Same as above (workspace member) |
| `backend/imdbapi/` | `${workspaceFolder}/../.venv/bin/python` | Same as above (workspace member) |
| `backend/rag_ingestion/` | `${workspaceFolder}/.venv/bin/python` | `uv sync` from `rag_ingestion/` (standalone) |

### Key VSCode behaviours configured

- **Format on save:** Ruff (Python), Prettier (TypeScript/HTML/SCSS)
- **Code actions on save:** `source.fixAll.ruff`, `source.organizeImports.ruff` (Python); `source.fixAll.eslint` (TypeScript)
- **Rulers:** 100 chars (Python), 120 chars (TypeScript/docs)
- **Test discovery:** pytest with `--asyncio-mode=auto` (Python), Vitest (frontend)
- **PlantUML preview:** `Option+D` / `Alt+D` with `jebbs.plantuml` extension
- **Hidden artifacts:** `__pycache__`, `.mypy_cache`, `.ruff_cache`, `node_modules`, `dist`, `.angular`

---

## Architecture diagrams

### PlantUML (canonical software architecture)

Source files in `docs/architecture/plantuml/` — **always update `.puml` files for any architectural change.**

| File | Content |
|---|---|
| `01-domain-model.puml` | Core domain entities and relationships |
| `02-system-architecture.puml` | High-level system overview |
| `03-backend-architecture.puml` | Backend internal structure |
| `04-langgraph-pipeline.puml` | LangGraph 8-node pipeline flow |
| `05-langgraph-statemachine.puml` | State machine transitions |
| `06-frontend-architecture.puml` | Angular component architecture |
| `07-seq-authentication.puml` | Auth sequence (login, refresh, revoke) |
| `08-seq-chat-sse.puml` | Chat SSE streaming sequence |
| `09-seq-langgraph-execution.puml` | Full pipeline execution sequence |
| `10-deployment-azure.puml` | Azure deployment topology |

Render: `plantuml -png docs/architecture/plantuml/*.puml` or `./scripts/prepare-docs.sh`
PNGs are gitignored — generated at doc-build time.

**Never generate `.mdj` StarUML files programmatically.** The format requires explicit pixel
coordinates for every element. User converts `.puml` to StarUML manually for stakeholder reviews.

### Structurizr C4 (architecture levels)

`docs/architecture/workspace.dsl` — Structurizr DSL defining L1–L3 + deployment views.
`workspace.json` is the export (gitignored, regenerated by Structurizr Lite).

Update `workspace.dsl` whenever components, containers, or inter-system relations change.

### Architecture Decision Records (ADRs)

Location: `docs/architecture/decisions/`
Index: `docs/architecture/decisions/index.md` (also contains the ADR template)

**When to write an ADR:**
- Any change to tech stack, external dependencies, or cloud provider
- New design pattern introduced project-wide
- Security or auth model changes
- Significant API contract decisions
- Anything that future developers would ask "why did they do it this way?"

**How to create an ADR:**
```bash
# Copy the template from the index, name it ADR-NNN-short-title.md
# Status: Proposed → Accepted / Superseded / Deprecated
# Commit to docs/ submodule first, then bump pointer in parent
```

---

## Technology stack

| Layer | Stack |
|---|---|
| Frontend | Angular 21, TypeScript 5.9, nginx, SSE (`EventSource`) |
| Backend | Python 3.13, FastAPI 0.115+, asyncpg, python-jose, bcrypt |
| AI pipeline | LangGraph 0.2+, LangChain 0.3+, Claude Haiku (classify), Claude Sonnet (reason/Q&A) |
| Embeddings | OpenAI `text-embedding-3-large` (3072-dim) |
| Vector store | Qdrant Cloud (always external — no local container ever) |
| Database | PostgreSQL 16 (asyncpg pool; raw DDL schema — no Alembic yet, see #3) |
| Observability | LangSmith (tracing for LangGraph pipeline, opt-in via `LANGSMITH_TRACING=true`) |
| CI/CD | Jenkins (Multibranch Pipelines) → Azure Container Registry → Azure Container Apps |
| Package manager | `uv` (Python workspace), `npm` (frontend) |

---

## Coding standards

### Python (all backend submodules)

- **Line length:** 100 characters (`ruff`, `mypy`)
- **Type annotations:** Required on all public functions and methods — `mypy --strict` must pass
- **No `type: ignore`** without an inline comment explaining why
- **No bare `except:`** — always catch specific exception types
- **No mutable default arguments** — use `None` + `if x is None: x = []`
- **Imports:** `isort` order enforced by `ruff` (stdlib → third-party → local)
- **Docstrings:** Required on all public classes and functions (Google style)
- **`ruff` rules in scope:** `E`, `F`, `I`, `N`, `UP`, `B`, `C4`, `SIM`
- **Async all the way:** Never call blocking I/O in an async context

### TypeScript (frontend)

- **Strict mode on** — `noImplicitAny`, `strictNullChecks` enforced
- **No `any`** — use `unknown` + type narrowing instead
- **Standalone components** — no NgModules ever
- **Signals** for all reactive state — no `BehaviorSubject` for component state
- **Immutability** — prefer `readonly` and `const` everywhere applicable
- **ESLint 9 flat config + Prettier** — must pass before commit

### Both

- **No secrets in code** — `detect-secrets` pre-commit hook enforces this
- **No `console.log` / `print()`** left in production code — use proper logging
- **Descriptive names** — no single-letter variables outside of loop counters and mathematical contexts
- **Tests are not optional** — every feature and bug fix ships with tests

---

## Design patterns

Follow these patterns consistently. When extending a component, match the existing pattern
rather than introducing a new one.

### Backend / Python

| Pattern | Where used | Rule |
|---|---|---|
| **Strategy** | Embedding providers (`rag_ingestion/`, `chain/`) | New provider = new class implementing the provider interface; no `if provider == "openai"` branching in core logic |
| **State machine** | LangGraph pipeline (`chain/`) | New behaviour = new node or edge, not branching inside existing nodes |
| **Dependency injection** | FastAPI (`app/`) | Use `Depends()` for all shared resources (db pool, auth, config) — never instantiate inside route handlers |
| **Adapter** | `imdbapi/` client | The client wraps the external API and maps to internal domain types; callers never see raw HTTP responses |
| **Repository** | Database layer (`app/`) | Data access methods live in repository classes — no raw SQL in route handlers |
| **Factory** | LangGraph node wiring (`chain/graph.py`) | Node construction is centralised in `graph.py`; nodes are pure functions |
| **Configuration object** | All submodules | Settings loaded once via `config.py` / Pydantic `BaseSettings` — never `os.getenv()` scattered through code |

### Frontend / Angular

| Pattern | Where used | Rule |
|---|---|---|
| **Smart / Dumb components** | Angular components | Smart components own services and state; dumb components take `@Input()` only |
| **Facade service** | HTTP layer | Services wrap `HttpClient` and return typed observables/signals — components never call `HttpClient` directly |
| **Signal-based state** | Reactive state | Use Angular Signals; avoid `BehaviorSubject` for component-local state |

---

## Pre-commit hooks

**Every submodule has its own `.pre-commit-config.yaml`** tailored to its stack.
Install and run from within each submodule's directory.

### Python submodules (`backend/`, `backend/chain/`, `backend/rag_ingestion/`, `backend/imdbapi/`)

```bash
# Install (run once per clone, or after hook version changes)
uv run pre-commit install

# Run manually
uv run pre-commit run --all-files
```

| Hook | Applies to |
|---|---|
| `trailing-whitespace`, `end-of-file-fixer`, `check-yaml` | All |
| `check-added-large-files`, `check-case-conflict`, `check-merge-conflict` | All |
| `detect-private-key`, `detect-secrets` | All |
| `pretty-format-json`, `sort-simple-yaml` | `rag_ingestion/`, `imdbapi/` only |
| `mypy --strict` | All (additional deps vary per submodule — see each `.pre-commit-config.yaml`) |
| `ruff-check --fix`, `ruff-format` | All |

### Frontend (`frontend/`)

```bash
# Prerequisite: node_modules must exist
npm ci

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

| Hook | What it checks |
|---|---|
| `trailing-whitespace`, `end-of-file-fixer`, `check-yaml`, `check-merge-conflict` | File health |
| `detect-private-key`, `detect-secrets` | Secrets (excludes `package-lock.json`) |
| `eslint-frontend` | TypeScript + HTML templates via local `node_modules/.bin/eslint` |
| `prettier-frontend` | Format check via local `node_modules/.bin/prettier` |

### Policy

- **Never `--no-verify`** unless directed by a team lead, and always follow up with a clean commit
- `detect-secrets` false positive → add `# pragma: allowlist secret` inline and update: `detect-secrets scan > .secrets.baseline`
- Hook version bumps (`.pre-commit-config.yaml`) require reinstall: `pre-commit install`

---

## Key conventions

### Git and submodules

- Feature branches + PR workflow — see `CONTRIBUTING.md` for the full branching strategy
- **Never `git add -A`** — submodule state and secrets can be accidentally staged
- Submodule changes: commit in the submodule first, then bump the pointer in the parent
- Submodule pointer bump syntax:
  ```bash
  git add <submodule-path>
  git commit -m "chore(<submodule>): bump to latest main"
  ```

### Branching

```
main          ← always deployable; protected; requires PR + 1 approval
  └── feature/<kebab-case>    new capability
  └── fix/<kebab-case>        bug fix
  └── chore/<kebab-case>      tooling, deps, CI, scripts
  └── docs/<kebab-case>       documentation only
  └── hotfix/<kebab-case>     urgent production fix
```

### Commit messages (Conventional Commits)

```
<type>(<scope>): <short summary>

[body — explain WHY, not WHAT]

[footer — breaking changes, issue refs: Closes #N]
```

Types: `feat` · `fix` · `chore` · `docs` · `test` · `refactor` · `perf`

### CI/CD pipeline modes

| Mode | Trigger | Stages |
|---|---|---|
| CONTRIBUTION | Feature branch / PR | Lint · Test |
| INTEGRATION | Push to `main` | Lint · Test · Build Docker · Push `:sha8` + `:latest` → ACR |
| RELEASE | `v*` tag | Lint · Test · Build · Push `:v1.2.3` → ACR · Production deploy (manual approval) |

### GitHub branch protection (rulesets)

All 8 repos have a **`main-branch-protection`** ruleset enforcing:
- PRs required before merging to `main`
- 1 approving review required, stale reviews dismissed
- No force-pushes, no deletion of `main`
- Repository admins can bypass (solo developer workflow)

**Note:** `branch_name_pattern` and `tag_name_pattern` ruleset rules require GitHub Enterprise.
On GitHub Free/Pro, branch and tag naming conventions are documented policy (see Branching section)
and enforced via contributor guidelines, not automated gate checks.

### Secrets policy

- **Never commit secrets.** `detect-secrets` pre-commit hook blocks API keys and tokens.
- **Production secrets live in Azure Key Vault** — injected at runtime via managed identity.
- **Never pass secrets through Jenkins build logs** or bake into Docker images.
- **Rotate via Key Vault**, not by editing pipelines.

### Documentation

- Run `./scripts/prepare-docs.sh` before `mkdocs serve` — copies submodule READMEs and renders PNGs
- `docs/` is a submodule — changes must be committed there before bumping the pointer in root
- `CHANGELOG.md` follows [Keep A Changelog](https://keepachangelog.com/) format — always update `[Unreleased]`

---

## Session start protocol

Before implementing anything:
1. `gh issue list --repo aharbii/movie-finder --state open` — check what already exists
2. **Create GitHub issue** in parent repo (and submodule repo, linked to parent)
3. **Create branch** following the branching convention above
4. **Assess the cross-cutting checklist** — identify everything that needs to change
5. **Plan first** for non-trivial changes — align before writing code

---

## Cross-cutting change checklist

Run through this for **every** task before declaring done.

### 1. GitHub issues
- [ ] Issue in `aharbii/movie-finder` (parent repo)
- [ ] Issue in the submodule repo, linked to parent (`Part of aharbii/movie-finder#N`)

### 2. Branch
- [ ] Branch in the submodule repo: `feature/`, `fix/`, `chore/`, `docs/`, `hotfix/`
- [ ] Kebab-case name (e.g., `feature/gemini-embedding-provider`)
- [ ] Parent repo also needs a `chore/` branch to bump the pointer after the submodule merges

### 3. ADR (Architecture Decision Record)
- [ ] Does this change a tech decision, add an external dependency, or introduce a new pattern?
  → Write an ADR in `docs/architecture/decisions/ADR-NNN-title.md` (copy template from `index.md`)

### 4. Implementation
- [ ] Code follows the design patterns established for the component (see above)
- [ ] No pattern drift — if the pattern is wrong, raise it, don't work around it
- [ ] `ruff` + `mypy --strict` pass (Python) or `eslint` + `prettier` pass (TypeScript)
- [ ] Pre-commit hooks pass: `uv run pre-commit run --all-files`
- [ ] **Never** `--no-verify`

### 5. Tests
- [ ] Unit tests for new logic
- [ ] Integration tests for API or pipeline changes
- [ ] Coverage does not regress
- [ ] `pytest --asyncio-mode=auto` passes (Python) or `vitest` passes (TypeScript)

### 6. Environment and secrets
- [ ] `.env.example` updated in **every affected repo**: root, `backend/`, `backend/chain/`, `backend/rag_ingestion/`, `backend/imdbapi/`, `frontend/`
- [ ] New secrets flagged to user for manual addition to:
  - Azure Key Vault (runtime secrets, managed identity)
  - Jenkins credentials store (CI build secrets)
  - GitHub repository secrets (if needed for GH Actions in future)
- [ ] `.gitignore` reviewed for new build artifacts or file types

### 7. Docker
- [ ] `Dockerfile` updated in affected submodule (new deps, env vars, build args)
- [ ] `docker-compose.yml` in submodule updated if service interface changed
- [ ] Root `docker-compose.yml` updated if needed (new service, new env var, port change)

### 8. CI — Jenkins
- [ ] `Jenkinsfile` in affected submodule reviewed — new stages, credentials, or env vars?
- [ ] Jenkins credentials table in `docs/devops-setup.md` updated if new credentials needed
- [ ] New Jenkins credential → flag to user (manual step in Jenkins UI)

### 9. Architecture diagrams
- [ ] **PlantUML** — update the relevant `.puml` file(s) in `docs/architecture/plantuml/`
  (user manually syncs to StarUML — **never generate `.mdj` files**)
- [ ] **Structurizr C4** — update `docs/architecture/workspace.dsl` if components or relations changed
  (verify with `docker compose -f docker-compose.docs.yml up`)
- [ ] Both live in the `docs/` submodule — commit there first

### 10. Documentation
- [ ] `docs/` submodule pages updated for the change (services, devops, architecture)
- [ ] `README.md` in affected submodule updated if interface or usage changed
- [ ] `CHANGELOG.md` updated under `[Unreleased]` in affected submodule
- [ ] OpenAPI schema: FastAPI auto-generates it — verify no unintended breaking changes at `/docs`
- [ ] DevOps setup guide (`docs/devops-setup.md`) updated if new infra, credentials, or secrets

### 10a. AI agent context files
When anything architectural, procedural, or structural changes (new tool, new pattern, new workflow):
- [ ] Update `CLAUDE.md` in every affected submodule
- [ ] Mirror the same change in `GEMINI.md` in every affected submodule
- [ ] Mirror the same change in `AGENTS.md` in every affected submodule
- [ ] If VSCode configs changed: update `.vscode/` tables in all three files
- [ ] If cross-cutting checklist changed: update all three files
- [ ] Root `.github/copilot-instructions.md` updated if stack, patterns, or conventions changed

### 11. Other affected submodules
Explicitly assess each before closing:

| Submodule | Potentially affected by… |
|---|---|
| `backend/chain/` | Embedding model changes, LLM model changes, state shape changes |
| `backend/app/` | API contract changes, new endpoints, auth changes, SSE event shape |
| `backend/imdbapi/` | IMDb API schema changes, retry/timeout config |
| `backend/rag_ingestion/` | Embedding model changes, dataset changes, ingestion output format |
| `frontend/` | API contract changes, new config, SSE event fields |
| `infrastructure/` | New Azure resources, new env vars, new secrets, cost implications |
| `docs/` | Any user-visible change, any architecture change |

### 12. Submodule pointer bump
```bash
# After submodule changes are merged to main:
git add <submodule-path>
git commit -m "chore(<submodule>): bump to latest main"
```

### 13. Pull request
- [ ] PR in submodule repo — title follows Conventional Commits, body references the issue
- [ ] PR in parent repo to bump the submodule pointer
- [ ] Both PRs linked to their respective issues

---

## Known open issues (do not duplicate)

Reference by number when relevant. Issues #2, #3, #4, #5, #6, #7, #8 are the highest priority.

| # | Title | Severity |
|---|---|---|
| #2 | `MemorySaver` non-persistent — breaks multi-replica | Critical |
| #3 | No Alembic migrations, no DB indexes | Critical |
| #4 | No rate limiting on any endpoint | High |
| #5 | Refresh tokens cannot be revoked | High |
| #6 | `sys.exit(1)` in `QdrantVectorStore` library code | High |
| #7 | OpenAI + Qdrant clients re-created per LangGraph node | High |
| #8 | IMDb retry base delay 30 s — blocks SSE stream | High |
| #9 | No CORS middleware | Medium |
| #10 | `confirmed_movie` stored as `TEXT`, not `JSONB` | Medium |
| #11 | No pagination on session listing | Medium |
| #12 | `UserInDB` exposes `hashed_password` through dependency chain | Medium |
| #13 | No input length validation on chat messages | Medium |
| #14 | Shared production Qdrant cluster across all environments | Medium |
| #15 | `total=False` on `MovieFinderState` TypedDict weakens type safety | Low |
| #16 | IMDb stagger delay adds artificial latency | Low |
| #17 | Jenkins relies on free ngrok tunnel for webhooks | Low |
| #18 | `create_agent` import path is non-standard | Low |
| #19 | No batch embedding in RAG ingestion | Medium |
| #21 | Candidate for migration from Jenkins to GitHub Actions | Medium |
| #22 | Infrastructure as Code (Terraform/Bicep) not yet implemented | Medium |
