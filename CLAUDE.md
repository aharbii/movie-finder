# Claude Code — Movie Finder project context

Loaded automatically at the start of every Claude Code session for this repo.
Human-maintained and committed — shared source of truth for how Claude works in this project.

---

## Project overview

**Movie Finder** is a full-stack, enterprise-grade AI application.
A user describes a half-remembered film in natural language; the system finds it via semantic
search, enriches it with live IMDb metadata, and answers follow-up questions via a streamed chat UI.

**Repo structure:** recursive Git submodules — each submodule is an independently versioned repo.

| Path                       | GitHub repo                           | Role                          |
| -------------------------- | ------------------------------------- | ----------------------------- |
| `.`                        | `aharbii/movie-finder`                | Parent orchestrator                           |
| `backend/`                 | `aharbii/movie-finder-backend`        | FastAPI + uv workspace root                   |
| `backend/app/`             | (nested in backend)                   | FastAPI application layer                     |
| `backend/chain/`           | `aharbii/movie-finder-chain`          | LangGraph 8-node AI pipeline                  |
| `backend/chain/imdbapi/`   | `aharbii/imdbapi-client`              | Async IMDb REST client                        |
| `frontend/`                | `aharbii/movie-finder-frontend`       | Angular 21 SPA                                |
| `docs/`                    | `aharbii/movie-finder-docs`           | MkDocs documentation site                     |
| `infrastructure/`          | `aharbii/movie-finder-infrastructure` | IaC / Azure provisioning                      |
| `rag/` †                   | `aharbii/movie-finder-rag`            | Offline embedding ingestion (update = none)   |
| `mcp/qdrant-explorer/` †   | `aharbii/movie-finder-mcp-qdrant`     | DX: Qdrant RAG Evaluator (update = none)      |
| `mcp/langgraph-inspector/` †| `aharbii/movie-finder-mcp-langgraph` | DX: LangGraph State Inspector (update = none) |
| `mcp/schema-inspector/` †  | `aharbii/movie-finder-mcp-schema`     | DX: Postgres Schema Assistant (update = none) |
| `mcp/imdb-sandbox/` †      | `aharbii/movie-finder-mcp-imdb`       | DX: IMDb API Prompt Sandbox (update = none)   |

† Standalone tools — not required to run the app or CI. Not auto-populated by
`git submodule update --init`. Clone explicitly: `git submodule update --init <path>`.

---

## GitHub repos and issue tracking

`aharbii/movie-finder` is the main tracker repo for cross-repo work.

### Issue and PR hygiene

- Inspect the matching issue template, PR template, and one recent issue/PR of the same type
  before creating or editing anything.
- Do not improvise issue titles or bodies. Use the current template structure and section order.
- If a template file and recent live issues diverge, follow the newer live convention already in
  use and flag the template drift in the PR.
- Create child issues only in repos that will actually change.
- Child issues must use that repo's `.github/ISSUE_TEMPLATE/linked_task.yml` (or the matching
  local template), copy the parent context, and keep the description and acceptance criteria
  repo-specific.
- PR descriptions must follow `.github/PULL_REQUEST_TEMPLATE.md`, link the parent issue, and
  disclose the AI authoring tool and model.
- Any AI-assisted review comment or approval must also disclose the tool and model used for that
  review.

```bash
# Check current work before starting
gh issue list --repo aharbii/movie-finder --state open
```

---

## AI agent context files

This project supports multiple AI coding agents. Each reads its own context file per submodule:

| Agent                                    | File                              | Notes                                                                                  |
| ---------------------------------------- | --------------------------------- | -------------------------------------------------------------------------------------- |
| **Claude Code** (VSCode extension + CLI) | `CLAUDE.md`                       | Primary tool. VSCode extension and CLI share the same context.                         |
| **Gemini CLI**                           | `GEMINI.md`                       | Fallback / research agent. Use for Phase 1 exploration and as implementation fallback. |
| **OpenAI Codex CLI**                     | `AGENTS.md`                       | Secondary implementation agent. Reads `ai-context/prompts/` for workflow prompts.      |
| **GitHub Copilot**                       | `.github/copilot-instructions.md` | Per-repo file. Root and submodules can each define their own Copilot instructions.     |
| **JetBrains AI (Junie)**                 | `.junie/guidelines.md`            | Per-repo file for JetBrains IDE AI assistant — project context and coding rules.       |

### Slash commands (Claude Code only)

`.claude/commands/` exists in the root workspace and in every submodule workspace.
Type `/` in Claude Code to see available commands.

| Command                       | Phase          | Where to run            |
| ----------------------------- | -------------- | ----------------------- |
| `/session-start`              | Status check   | Root workspace          |
| `/create-issue [description]` | Issue creation | Root workspace          |
| `/implement [issue-number]`   | Implementation | **Submodule workspace** |
| `/review-pr [pr-number]`      | Code review    | **Submodule workspace** |
| `/bump-submodule [path]`      | After merge    | Root workspace          |

### Copy-paste prompts (Codex CLI / Gemini CLI / Ollama)

`ai-context/prompts/` contains agent-agnostic prompts for Codex, Gemini, and Ollama:

- `ai-context/prompts/implement.md` — use with `codex` or `ollama`
- `ai-context/prompts/review-pr.md` — use with `gh pr diff N | codex "..."` or ollama
- `ai-context/prompts/research.md` — project context block for research sessions

### Agent Briefing pattern

Every GitHub issue **must** include an `## Agent Briefing` section before being handed to any
agent for implementation. The template is in `ai-context/issue-agent-briefing-template.md`.
Issues without an Agent Briefing must NOT be handed to an agent cold — the agent will explore
the codebase speculatively and burn quota finding what the briefing would have told it directly.

**Maintenance rule:** any structural change (new pattern, new tool, new workflow, VSCode config
update, quality check command change) must be mirrored across `CLAUDE.md`, `GEMINI.md`,
`AGENTS.md`, `.github/copilot-instructions.md`, `.junie/guidelines.md`, `.cursorrules`,
`.claude/commands/`, and `ai-context/prompts/` in every affected repo.

---

## Workflow invariants

- `backend`, `frontend`, `docs`, and `infrastructure` are gitlinks in this repo. Parent
  workflow/path filters use the gitlink path itself (for example `docs`), not `docs/**`.
- `backend/chain` and `backend/chain/imdbapi` are gitlinks in `aharbii/movie-finder-backend`
  and follow the same rule there.
- `rag`, `mcp/qdrant-explorer`, `mcp/langgraph-inspector`, `mcp/schema-inspector`,
  `mcp/imdb-sandbox` are gitlinks in this repo with `update = none`.

### Issue hierarchy

`movie-finder` is the tracker but it only knows about its **direct submodules**:

```
movie-finder
  ├── movie-finder-backend      ← movie-finder creates child issues here
  │     ├── movie-finder-chain      ← backend creates sub-issues here
  │     └── imdbapi-client          ← backend creates sub-issues here
  ├── movie-finder-frontend
  ├── movie-finder-docs
  ├── movie-finder-infrastructure
  └── movie-finder-rag          ← movie-finder creates child issues here directly
```

From the movie-finder root: create child issues in the five direct repos above.
When a task involves chain/imdbapi, create a child in `movie-finder-backend`; the
backend workspace then manages its own sub-issues via `/create-issue` in that workspace.
RAG (`rag/`) is now a direct root submodule — create issues in `movie-finder-rag` directly.

- Root-only changes do not need child submodule issues. Create child issues only for repos whose
  files, docs, or gitlink pointers will change.
- If a new standalone issue appears mid-session, switch back to `main` and create a separate
  branch/PR unless stacking is explicitly requested.
- If CI, required checks, or merge policy change, update contributor-facing docs in the same
  change: `README.md`, `CONTRIBUTING.md`, `ONBOARDING.md`, and any affected docs pages.

### Claude Code: VSCode extension vs CLI

They are **the same agent** — same model, same `CLAUDE.md` context, same capabilities. The difference:

- **VSCode extension** (primary): has IDE context — open file, selection, diagnostics, file tree. Use this for all interactive development.
- **CLI** (`claude` in terminal): no IDE context. Useful for scripted automation, CI usage, or working outside VSCode. Not worth switching to for interactive work.

**Recommendation:** use the VSCode extension as your default. Fall back to Gemini CLI when Claude's usage limit is hit. The CLI provides no benefit over the extension for interactive tasks.

---

## Available toolchain

| Tool                        | Purpose                                                                             |
| --------------------------- | ----------------------------------------------------------------------------------- |
| `gh`                        | GitHub CLI — issues, PRs, secrets, repos                                            |
| `git`                       | Version control and submodule workflow                                              |
| `docker` / `docker compose` | Build and run containers locally                                                    |
| `uv`                        | Python package manager (backend workspace)                                          |
| `npm`                       | Frontend package manager                                                            |
| `mkdocs`                    | Documentation site — `make mkdocs` from root (runs prepare-docs + PlantUML + serve) |

**Docs and architecture viewers** (from repo root):

```bash
make mkdocs        # MkDocs site → http://localhost:8001
make structurizr   # Structurizr C4 → http://localhost:18080
```

**OpenAPI docs** (when backend is running): `http://localhost:8000/docs`

---

## MCP servers

Project-level MCP server configuration lives in `.mcp.json` (root workspace).
Claude Code picks this up automatically when you open the root workspace.

### Local MCP servers (project-built)

| Server              | Submodule               | Status       | Purpose                                    |
| ------------------- | ----------------------- | ------------ | ------------------------------------------ |
| `qdrant-evaluator`  | `mcp/qdrant-explorer/`  | ✅ Ready     | Query Qdrant, embed text, evaluate RAG     |
| `langgraph-inspector` | `mcp/langgraph-inspector/` | 🔧 Planned | Inspect LangGraph state machine runs       |
| `schema-inspector`  | `mcp/schema-inspector/` | 🔧 Planned   | Postgres schema assistant (introspect DDL) |
| `imdb-sandbox`      | `mcp/imdb-sandbox/`     | 🔧 Planned   | IMDb API prompt sandbox                    |

### External MCP servers (configured in `.mcp.json`)

| Server     | Package / command                           | Purpose                                       |
| ---------- | ------------------------------------------- | --------------------------------------------- |
| `github`   | `@modelcontextprotocol/server-github`       | Issues, PRs, code search across all repos     |
| `postgres` | `@modelcontextprotocol/server-postgres`     | Live DB queries against the PostgreSQL store  |
| `kaggle`   | `kaggle-mcp` (uvx)                          | Dataset management and Kaggle API access      |
| `langsmith`| `langsmith-mcp` (uvx)                       | LangSmith traces, evaluations, prompts        |
| `azure`    | `@azure/mcp`                                | Azure resource inspection and management      |

**Required env vars for external MCPs:** `GITHUB_PERSONAL_ACCESS_TOKEN`, `DATABASE_URL`,
`KAGGLE_API_TOKEN`, `LANGSMITH_API_KEY`, `LANGSMITH_PROJECT`. Add these to your local `.env`.

---

## VSCode setup

Every submodule that can be opened as a standalone workspace has its own committed `.vscode/`
directory with settings, extensions, launch configs, and tasks.

**Workspace hierarchy — each workspace includes all capabilities of its children.**

| Workspace                | `.vscode/` contents                               | Scope                                                                               |
| ------------------------ | ------------------------------------------------- | ----------------------------------------------------------------------------------- |
| Root (`movie-finder/`)   | settings, extensions, `launch.json`, `tasks.json` | All packages: backend (app/chain/imdbapi) + rag + frontend + docs + Docker full stack |
| `backend/`               | settings, extensions, `launch.json`, `tasks.json` | All backend packages: app + chain + imdbapi                                           |
| `backend/chain/`         | settings, extensions, `launch.json`, `tasks.json` | chain only                                                                            |
| `backend/chain/imdbapi/` | settings, extensions, `launch.json`, `tasks.json` | imdbapi only                                                                          |
| `rag/`                   | settings, extensions, `launch.json`, `tasks.json` | rag only (standalone uv)                                                              |
| `frontend/`              | settings, extensions, `launch.json`, `tasks.json` | Angular SPA only                                                                    |
| `docs/`                  | settings, extensions                              | PlantUML + Markdown editing                                                         |
| `infrastructure/`        | settings, extensions                              | IaC editing (Terraform/Bicep)                                                       |

### Python interpreter paths

| Submodule                | Interpreter path in `.vscode/settings.json` | How to create                                |
| ------------------------ | ------------------------------------------- | -------------------------------------------- |
| `backend/`               | `${workspaceFolder}/.venv/bin/python`       | `uv sync --all-packages` from `backend/`     |
| `backend/chain/`         | `${workspaceFolder}/../.venv/bin/python`    | Same as above (workspace member)             |
| `backend/chain/imdbapi/` | `${workspaceFolder}/../.venv/bin/python`    | Same as above (workspace member)             |
| `rag/`                   | `${workspaceFolder}/.venv/bin/python`       | `uv sync` from `rag/` (standalone)           |

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

| File                              | Content                                |
| --------------------------------- | -------------------------------------- |
| `01-domain-model.puml`            | Core domain entities and relationships |
| `02-system-architecture.puml`     | High-level system overview             |
| `03-backend-architecture.puml`    | Backend internal structure             |
| `04-langgraph-pipeline.puml`      | LangGraph 8-node pipeline flow         |
| `05-langgraph-statemachine.puml`  | State machine transitions              |
| `06-frontend-architecture.puml`   | Angular component architecture         |
| `07-seq-authentication.puml`      | Auth sequence (login, refresh, revoke) |
| `08-seq-chat-sse.puml`            | Chat SSE streaming sequence            |
| `09-seq-langgraph-execution.puml` | Full pipeline execution sequence       |
| `10-deployment-azure.puml`        | Azure deployment topology              |

Render: `make mkdocs` (full build) or VS Code `Alt+D` / `Option+D` (live preview per file).
PNGs are gitignored — generated at doc-build time by the mkdocs container.

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
# Copy the template from the index, name it NNNN-short-title.md
# Status: Proposed → Accepted / Superseded / Deprecated
# Commit to docs/ submodule first, then bump pointer in parent
```

---

## Technology stack

| Layer           | Stack                                                                               |
| --------------- | ----------------------------------------------------------------------------------- |
| Frontend        | Angular 21, TypeScript 5.9, nginx, SSE (`EventSource`)                              |
| Backend         | Python 3.13, FastAPI 0.115+, asyncpg, python-jose, bcrypt                           |
| AI pipeline     | LangGraph 0.2+, LangChain 0.3+, Claude Haiku (classify), Claude Sonnet (reason/Q&A) |
| Embeddings      | OpenAI `text-embedding-3-large` (3072-dim)                                          |
| Vector store    | Qdrant Cloud (always external — no local container ever)                            |
| Database        | PostgreSQL 16 (asyncpg pool; raw DDL schema — no Alembic yet, see #3)               |
| Observability   | LangSmith (tracing for LangGraph pipeline, opt-in via `LANGSMITH_TRACING=true`)     |
| CI/CD           | Jenkins (Multibranch Pipelines) → Azure Container Registry → Azure Container Apps   |
| Package manager | `uv` (Python workspace), `npm` (frontend)                                           |

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

| Pattern                  | Where used                                       | Rule                                                                                                               |
| ------------------------ | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------ |
| **Strategy**             | Embedding providers (`rag/`, `chain/`)           | New provider = new class implementing the provider interface; no `if provider == "openai"` branching in core logic |
| **State machine**        | LangGraph pipeline (`chain/`)                    | New behaviour = new node or edge, not branching inside existing nodes                                              |
| **Dependency injection** | FastAPI (`app/`)                                 | Use `Depends()` for all shared resources (db pool, auth, config) — never instantiate inside route handlers         |
| **Adapter**              | `imdbapi/` client                                | The client wraps the external API and maps to internal domain types; callers never see raw HTTP responses          |
| **Repository**           | Database layer (`app/`)                          | Data access methods live in repository classes — no raw SQL in route handlers                                      |
| **Factory**              | LangGraph node wiring (`chain/graph.py`)         | Node construction is centralised in `graph.py`; nodes are pure functions                                           |
| **Configuration object** | All submodules                                   | Settings loaded once via `config.py` / Pydantic `BaseSettings` — never `os.getenv()` scattered through code        |

### Frontend / Angular

| Pattern                     | Where used         | Rule                                                                                                          |
| --------------------------- | ------------------ | ------------------------------------------------------------------------------------------------------------- |
| **Smart / Dumb components** | Angular components | Smart components own services and state; dumb components take `@Input()` only                                 |
| **Facade service**          | HTTP layer         | Services wrap `HttpClient` and return typed observables/signals — components never call `HttpClient` directly |
| **Signal-based state**      | Reactive state     | Use Angular Signals; avoid `BehaviorSubject` for component-local state                                        |

---

## Pre-commit hooks

Every submodule has its own `.pre-commit-config.yaml`. Run from within the submodule directory.
**Never `--no-verify`.**

```bash
# Python submodules (backend, chain, imdbapi, rag)
uv run pre-commit install   # once per clone
uv run pre-commit run --all-files

# Frontend
npm ci && pre-commit install
pre-commit run --all-files
```

Hooks cover: whitespace, YAML, secrets (`detect-secrets`), `ruff-check --fix`, `ruff-format`, `mypy --strict` (Python); `eslint`, `prettier` (frontend).
`detect-secrets` false positive → `# pragma: allowlist secret` + `detect-secrets scan > .secrets.baseline`.

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

| Mode         | Trigger             | Stages                                                                           |
| ------------ | ------------------- | -------------------------------------------------------------------------------- |
| CONTRIBUTION | Feature branch / PR | Lint · Test                                                                      |
| INTEGRATION  | Push to `main`      | Lint · Test · Build Docker · Push `:sha8` + `:latest` → ACR                      |
| RELEASE      | `v*` tag            | Lint · Test · Build · Push `:v1.2.3` → ACR · Production deploy (manual approval) |

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

- Run `make mkdocs` from repo root — runs prepare-docs, renders PlantUML PNGs, and serves at :8001
- `docs/` is a submodule — changes must be committed there before bumping the pointer in root
- `CHANGELOG.md` follows [Keep A Changelog](https://keepachangelog.com/) format — always update `[Unreleased]`

---

## Session start protocol

**Shortcut:** run `/session-start` in Claude Code for a quick status summary before anything else.

Before implementing anything:

1. `gh issue list --repo aharbii/movie-finder --state open` — check what already exists
2. Inspect the matching issue/PR templates and a recent example of the same type
3. **Create GitHub issue** in `aharbii/movie-finder`, then create child issues only in repos that
   will actually change — use `/create-issue [description]` or follow the manual steps below
4. **Ensure the issue has an Agent Briefing section** (template: `ai-context/issue-agent-briefing-template.md`)
   before any implementation starts — without it, agents explore the codebase speculatively
5. **Create branch from `main`** following the branching convention above; new standalone issues
   get a separate branch/PR unless stacking is explicitly requested
6. **Assess the cross-cutting checklist** — identify everything that needs to change
7. **Plan first** for non-trivial changes — align before writing code

---

## Cross-cutting change checklist

Run through this for **every** task before declaring done.
Full detail in `ai-context/issue-agent-briefing-template.md` → "Cross-cutting updates" section.

| #   | Category             | Key gate                                                                                              |
| --- | -------------------- | ----------------------------------------------------------------------------------------------------- |
| 1   | **GitHub issues**    | Parent issue + child issues only in repos that change; Agent Briefing present                         |
| 2   | **Branch**           | `feature/fix/chore/docs/hotfix` + kebab-case; parent needs pointer-bump branch                        |
| 3   | **ADR**              | New tech decision, dependency, or project-wide pattern → write ADR                                    |
| 4   | **Implementation**   | Matches existing design pattern; `ruff`+`mypy` / `eslint`+`prettier` pass; pre-commit pass            |
| 5   | **Tests**            | Unit + integration tests; coverage doesn't regress; `pytest --asyncio-mode=auto` / `vitest` pass      |
| 6   | **Env & secrets**    | `.env.example` updated in every affected repo; new secrets flagged for Key Vault + Jenkins            |
| 7   | **Docker**           | `Dockerfile` + `docker-compose.yml` updated if deps, env vars, or service interface changed           |
| 8   | **CI**               | `Jenkinsfile` / `.github/workflows/` reviewed; credentials table updated                              |
| 9   | **Diagrams**         | `.puml` files updated (never `.mdj`); `workspace.dsl` updated if C4 relations changed                 |
| 10  | **Docs**             | `docs/` pages, `README.md`, `CHANGELOG.md` updated; OpenAPI verified                                  |
| 10a | **AI context**       | `CLAUDE.md` / `GEMINI.md` / `AGENTS.md` / `.junie/guidelines.md` / `.cursorrules` mirrored; `.claude/commands/` + `ai-context/prompts/` updated |
| 11  | **Other submodules** | Explicitly assess chain / app / imdbapi / rag / frontend / infra / docs                               |
| 12  | **Pointer bump**     | `git add <submodule>` → `chore(<sub>): bump to latest main` after merge                               |
| 13  | **PR**               | Submodule PR + parent pointer-bump PR; both linked to issues; AI tool + model disclosed               |

---

## Known open issues (do not duplicate)

Reference by number when relevant. Issues #2, #3, #4, #5, #6, #7, #8 are the highest priority.

| #   | Title                                                             | Severity |
| --- | ----------------------------------------------------------------- | -------- |
| #2  | `MemorySaver` non-persistent — breaks multi-replica               | Critical |
| #3  | No Alembic migrations, no DB indexes                              | Critical |
| #4  | No rate limiting on any endpoint                                  | High     |
| #5  | Refresh tokens cannot be revoked                                  | High     |
| #6  | `sys.exit(1)` in `QdrantVectorStore` library code                 | High     |
| #7  | OpenAI + Qdrant clients re-created per LangGraph node             | High     |
| #8  | IMDb retry base delay 30 s — blocks SSE stream                    | High     |
| #9  | No CORS middleware                                                | Medium   |
| #10 | `confirmed_movie` stored as `TEXT`, not `JSONB`                   | Medium   |
| #11 | No pagination on session listing                                  | Medium   |
| #12 | `UserInDB` exposes `hashed_password` through dependency chain     | Medium   |
| #13 | No input length validation on chat messages                       | Medium   |
| #14 | Shared production Qdrant cluster across all environments          | Medium   |
| #15 | `total=False` on `MovieFinderState` TypedDict weakens type safety | Low      |
| #16 | IMDb stagger delay adds artificial latency                        | Low      |
| #17 | Jenkins relies on free ngrok tunnel for webhooks                  | Low      |
| #18 | `create_agent` import path is non-standard                        | Low      |
| #19 | No batch embedding in RAG ingestion                               | Medium   |
| #21 | Candidate for migration from Jenkins to GitHub Actions            | Medium   |
| #22 | Infrastructure as Code (Terraform/Bicep) not yet implemented      | Medium   |
