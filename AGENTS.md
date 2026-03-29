# OpenAI Codex CLI — Movie Finder project context

Foundational mandate for OpenAI Codex CLI in this repository.
Adhere to these project-specific standards, workflows, and architectural patterns.

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

| Agent | File | Role |
|---|---|---|
| **Claude Code** (VSCode extension + CLI) | `CLAUDE.md` | Primary implementation agent — use slash commands |
| **Gemini CLI** | `GEMINI.md` | Research/exploration + implementation fallback |
| **OpenAI Codex CLI** | `AGENTS.md` | This file — secondary implementation agent |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Per-repo inline suggestions |

### Prompts for Codex CLI

Copy-paste prompts are in `ai-context/prompts/` (available in each submodule too):
- `ai-context/prompts/implement.md` — step-by-step implementation workflow
- `ai-context/prompts/review-pr.md` — PR review workflow (pipe `gh pr diff` into it)
- `ai-context/prompts/research.md` — project context block for research sessions

### Agent Briefing pattern

Every issue must have an `## Agent Briefing` section before you start implementing.
Template: `ai-context/issue-agent-briefing-template.md`
The briefing lists exact files to read — without it, do not explore the codebase speculatively.

**Maintenance rule:** any structural change must be mirrored across `CLAUDE.md`, `GEMINI.md`,
`AGENTS.md`, `.github/copilot-instructions.md`, `.claude/commands/`, and `ai-context/prompts/`
in every affected repo.

---

## Workflow invariants

- `backend`, `frontend`, `docs`, and `infrastructure` are gitlinks in this repo. Parent
  workflow/path filters use the gitlink path itself (for example `docs`), not `docs/**`.
- `backend/chain`, `backend/imdbapi`, and `backend/rag_ingestion` are gitlinks in
  `aharbii/movie-finder-backend` and follow the same rule there.
- Root-only changes do not need child submodule issues. Create child issues only for repos whose
  files, docs, or gitlink pointers will change.
- If a new standalone issue appears mid-session, switch back to `main` and create a separate
  branch/PR unless stacking is explicitly requested.
- If CI, required checks, or merge policy change, update contributor-facing docs in the same
  change: `README.md`, `CONTRIBUTING.md`, `ONBOARDING.md`, and any affected docs pages.

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

Every submodule has its own committed `.vscode/` directory. Workspace coverage is hierarchical —
opening a parent workspace gives you all capabilities of its children.

| Workspace | Scope |
|---|---|
| Root (`movie-finder/`) | All: backend (app/chain/imdbapi/rag) + frontend + docs + Docker full stack |
| `backend/` | All backend packages: app + chain + imdbapi + rag_ingestion |
| `backend/chain/` | chain only |
| `backend/rag_ingestion/` | rag_ingestion only (standalone uv) |
| `backend/imdbapi/` | imdbapi only |
| `frontend/` | Angular SPA only |
| `docs/` | PlantUML + Markdown editing |
| `infrastructure/` | IaC editing (Terraform/Bicep) |

**Python interpreter paths:**
- `backend/`, `chain/`, `imdbapi/` → `backend/.venv` (`uv sync --all-packages` from `backend/`)
- `rag_ingestion/` → `rag_ingestion/.venv` (`uv sync` from `rag_ingestion/`)

**When modifying VSCode configs** (`.vscode/*.json`):
- Keep hierarchy consistent: per-package task → parent workspace re-exposes it with `cwd`
- Verified extension IDs: `ms-python.python`, `ms-python.debugpy`, `charliermarsh.ruff`,
  `ms-python.mypy-type-checker`, `tamasfe.even-better-toml`, `angular.ng-template`,
  `esbenp.prettier-vscode`, `dbaeumer.vscode-eslint`, `vitest.explorer`, `jebbs.plantuml`,
  `hashicorp.terraform`, `ms-azuretools.vscode-bicep`, `ms-azuretools.azure-resources`,
  `ms-azuretools.vscode-docker`, `eamodio.gitlens`, `github.vscode-pull-request-github`,
  `streetsidesoftware.code-spell-checker`, `redhat.vscode-yaml`
- After editing VSCode configs, update `CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, and
  `.github/copilot-instructions.md` as applicable

---

## Technology stack

| Layer | Stack |
|---|---|
| Frontend | Angular 21, TypeScript 5.9, nginx, SSE (`EventSource`) |
| Backend | Python 3.13, FastAPI 0.115+, asyncpg, python-jose, bcrypt |
| AI pipeline | LangGraph 0.2+, LangChain 0.3+, Claude Haiku (classify), Claude Sonnet (reason/Q&A) |
| Embeddings | OpenAI `text-embedding-3-large` (3072-dim) |
| Vector store | Qdrant Cloud (always external — no local container ever) |
| Database | PostgreSQL 16 (asyncpg pool) |
| Observability | LangSmith (tracing for LangGraph pipeline) |
| Package manager | `uv` (Python workspace), `npm` (frontend) |

---

## Coding standards

### Python (all backend submodules)
- **Line length:** 100 characters (`ruff`, `mypy`)
- **Type annotations:** Required on all public functions — `mypy --strict` must pass
- **Async all the way:** Never call blocking I/O in an async context
- **Docstrings:** Required on all public classes and functions (Google style)

### TypeScript (frontend)
- **Strict mode on** — `noImplicitAny`, `strictNullChecks`
- **Standalone components** — no NgModules ever
- **Signals** for all reactive state
- **ESLint 9 + Prettier** — must pass before commit

---

## Cross-cutting change checklist

1. **GitHub issues:** Parent issue in `aharbii/movie-finder` + child issues only in repos that
   will change. Inspect the matching templates and a recent example before filing or editing.
   **Issue must have an Agent Briefing section** before implementation starts.
2. **Branching:** `feature/`, `fix/`, `chore/`, `docs/`, `hotfix/` (kebab-case).
3. **ADR:** Update `docs/architecture/decisions/` for any tech decision.
4. **Implementation:** Follow patterns (Strategy, State machine, Repository, Facade).
5. **Tests:** Unit + Integration tests mandatory.
6. **Env/Secrets:** Update `.env.example` in all affected repos.
7. **Docker:** Update `Dockerfile` and `docker-compose.yml`.
8. **CI:** Review `.github/workflows/*.yml` and `Jenkinsfile` as applicable. Update
   contributor-facing docs when required checks or merge policy change.
9. **Diagrams:** Update PlantUML (`.puml`) and Structurizr (`workspace.dsl`).
10. **Submodule bump:** Commit in submodule, then bump pointer in parent.
10a. **AI agent context files:** Mirror any workflow/structural change across `CLAUDE.md`,
    `GEMINI.md`, `AGENTS.md`, `.github/copilot-instructions.md`, `.claude/commands/`,
    and `ai-context/prompts/` in every affected repo.

For implementation, use: `cat ai-context/prompts/implement.md` — it contains the full workflow.
For review, use: `gh pr diff N --repo REPO > /tmp/pr.txt && cat /tmp/pr.txt | codex "$(cat ai-context/prompts/review-pr.md)"`

---

## Session start protocol (OpenAI Codex CLI)

1. `gh issue list --repo aharbii/movie-finder --state open`
2. Inspect the matching issue/PR templates and a recent example of the same type
3. **Create GitHub issue** in `aharbii/movie-finder`, then create child issues only in repos that
   will actually change
4. **Create branch from `main`** following the branching convention; new standalone issues get a
   separate branch/PR unless stacking is explicitly requested
5. **Assess the cross-cutting checklist**
6. **Plan first** (think and plan thoroughly before writing code for non-trivial changes)
