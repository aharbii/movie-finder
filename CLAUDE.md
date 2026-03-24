# Claude Code — Project Context

Loaded automatically at the start of every Claude Code session for this repo.
Keep this file human-maintained and committed — it is the shared source of truth
for how Claude should work within this project.

---

## Project overview

**Movie Finder** is a full-stack, enterprise-grade AI application.
A user describes a half-remembered film in natural language; the system finds it,
enriches it with live IMDb metadata, and answers follow-up questions via a streamed chat UI.

**Repo structure:** recursive Git submodules.

| Path | Submodule repo | Role |
|---|---|---|
| `backend/` | `movie-finder-backend` | FastAPI + LangGraph orchestrator |
| `backend/app/` | (nested) | FastAPI application layer |
| `backend/chain/` | `movie-finder-chain` | LangGraph 8-node AI pipeline |
| `backend/imdbapi/` | `imdbapi-client` | Async IMDb REST client |
| `backend/rag_ingestion/` | `movie-finder-rag` | Offline embedding ingestion |
| `frontend/` | `movie-finder-frontend` | Angular 21 SPA |
| `docs/` | `movie-finder-docs` | MkDocs documentation site |
| `infrastructure/` | `movie-finder-infrastructure` | IaC / Azure provisioning |

---

## Architecture diagrams

**PlantUML is the canonical UML tool** for this project.

- Source files: `docs/architecture/plantuml/*.puml` (10 diagrams, committed)
- Generated PNGs: produced at doc-build time, gitignored
- Render command: `plantuml -png docs/architecture/plantuml/*.puml`
- Or via: `./scripts/prepare-docs.sh` (renders PNGs as part of doc prep)
- VS Code preview: `Option+D` / `Alt+D` with the **jebbs.plantuml** extension
  (pre-configured in `.vscode/settings.json`)

**Do not write StarUML `.mdj` files programmatically.** The `.mdj` format requires
explicit pixel coordinates for every view element — AI-generated files are always
broken. The user converts `.puml` diagrams to StarUML manually for stakeholder reviews.

The Structurizr DSL (`docs/architecture/workspace.dsl`) handles C4 views (L1–L3 + deployment).

---

## Technology stack

| Layer | Stack |
|---|---|
| Frontend | Angular 21, TypeScript 5.9, nginx, SSE (`EventSource`) |
| Backend | Python 3.13, FastAPI 0.115+, asyncpg, python-jose, bcrypt |
| AI pipeline | LangGraph 0.2+, LangChain 0.3+, Claude Haiku (classify), Claude Sonnet (reason/Q&A) |
| Embeddings | OpenAI `text-embedding-3-large` (3072-dim) |
| Vector store | Qdrant Cloud (always external — no local container) |
| Database | PostgreSQL 16 (asyncpg pool; raw DDL schema — no Alembic yet) |
| CI/CD | Jenkins (Multibranch Pipelines) → Azure Container Registry → Azure Container Apps |
| Package manager | `uv` (Python workspace), `npm` (frontend) |

---

## Key conventions

### Git
- Feature branches + PR workflow (see `CONTRIBUTING.md`)
- Submodule changes require commits in the submodule repo first, then a pointer bump in the parent
- Never `git add -A` — submodule state and secrets can be accidentally staged

### Python (backend)
- `uv` workspace: `backend/` is the root, `app/`, `chain/`, `imdbapi/` are members
- `rag_ingestion/` is intentionally outside the workspace (separate lifecycle)
- Linting: `ruff` · Type checking: `mypy --strict` · Tests: `pytest --asyncio-mode=auto`
- Pre-commit hooks defined in `backend/.pre-commit-config.yaml`

### TypeScript (frontend)
- Standalone Angular components (no NgModules)
- Signals for reactive state; `EventSource` for SSE streaming
- Linting: ESLint 9 flat config · Formatting: Prettier · Tests: Vitest

### Documentation
- Run `./scripts/prepare-docs.sh` before `mkdocs serve` — it copies submodule READMEs
  and renders PlantUML PNGs
- `docs/` is a submodule — changes to docs files must be committed there first

---

## Known open issues (do not duplicate)

GitHub issues already tracked — reference by number when relevant:

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
