# JetBrains AI (Junie) — Movie Finder project guidelines

Movie Finder is a full-stack AI application: natural-language film description → semantic search →
IMDb enrichment → streamed Q&A. Multi-repo structure using Git submodules.

---

## Repo structure

| Path                       | GitHub repo                           | Role                          |
| -------------------------- | ------------------------------------- | ----------------------------- |
| `.`                        | `aharbii/movie-finder`                | Parent orchestrator           |
| `backend/`                 | `aharbii/movie-finder-backend`        | FastAPI + uv workspace root   |
| `backend/app/`             | (nested in backend)                   | FastAPI routes, auth, SSE     |
| `backend/chain/`           | `aharbii/movie-finder-chain`          | LangGraph 8-node AI pipeline  |
| `backend/chain/imdbapi/`   | `aharbii/imdbapi-client`              | Async IMDb REST client        |
| `backend/rag_ingestion/`   | `aharbii/movie-finder-rag`            | Offline embedding ingestion   |
| `frontend/`                | `aharbii/movie-finder-frontend`       | Angular 21 SPA                |
| `docs/`                    | `aharbii/movie-finder-docs`           | MkDocs documentation site     |
| `infrastructure/`          | `aharbii/movie-finder-infrastructure` | IaC / Azure provisioning      |

---

## Technology stack

| Layer        | Stack                                                                   |
| ------------ | ----------------------------------------------------------------------- |
| Frontend     | Angular 21, TypeScript 5.9, nginx, SSE (`EventSource`)                  |
| Backend      | Python 3.13, FastAPI 0.115+, asyncpg, python-jose, bcrypt               |
| AI pipeline  | LangGraph 0.2+, LangChain 0.3+, Claude Haiku (classify), Sonnet (Q&A)  |
| Embeddings   | OpenAI `text-embedding-3-large` (3072-dim)                              |
| Vector store | Qdrant Cloud (always external — no local container ever)                |
| Database     | PostgreSQL 16 (asyncpg pool, raw DDL schema)                            |
| CI/CD        | Jenkins → Azure Container Registry → Azure Container Apps               |
| Package mgr  | `uv` (Python workspace), `npm` (frontend)                               |

---

## GitHub issues

- All cross-repo issues originate in `aharbii/movie-finder`
- Inspect templates in `.github/ISSUE_TEMPLATE/` and a recent example before creating issues
- Child issues only in repos that will actually change — use `linked_task.yml` template
- PR descriptions must disclose the AI authoring tool and model

```bash
gh issue list --repo aharbii/movie-finder --state open
```

---

## Workflow rules

- **Branches:** `feature/<kebab>`, `fix/<kebab>`, `chore/<kebab>`, `docs/<kebab>`, `hotfix/<kebab>`
- **Commit style:** Conventional Commits — `feat(scope): short summary`
- **Submodule changes:** commit in the submodule first, then bump the pointer in the parent
- **Never `git add -A`** — stage files explicitly
- **Submodule pointer bump:** `git add <path>` → `chore(<sub>): bump to latest main`

---

## Dev contract — all quality checks run inside Docker

```bash
make pre-commit   # lint + type check + format (runs inside Docker)
make test         # pytest (Python) or vitest (frontend), inside Docker
make lint         # ruff check (Python) or eslint (frontend)
make typecheck    # mypy --strict (Python) or tsc (frontend)
```

**Never `--no-verify` on commits.**

---

## Python standards (backend)

- **Line length:** 100 (`ruff` + `mypy`)
- **Type annotations:** required on all public functions — `mypy --strict` must pass
- **No `type: ignore`** without an explanatory comment
- **No bare `except:`** — catch specific exceptions
- **Imports:** `ruff` isort order (stdlib → third-party → local)
- **Docstrings:** Google style on all public classes and functions
- **Async all the way:** no blocking I/O in async context
- **Config:** Pydantic `BaseSettings` in `config.py` — never `os.getenv()` in business logic
- **DI:** FastAPI `Depends()` for db pool, auth, config — never instantiate inside route handlers

---

## TypeScript standards (frontend)

- **Strict mode** — `noImplicitAny`, `strictNullChecks` enforced
- **No `any`** — use `unknown` + type narrowing
- **Standalone components only** — no NgModules
- **Signals** for all reactive state — no `BehaviorSubject` for component state
- **ESLint 9 flat config + Prettier** must pass before commit

---

## Design patterns

| Pattern      | Where              | Rule                                                              |
| ------------ | ------------------ | ----------------------------------------------------------------- |
| Strategy     | Embedding/store    | New provider = new class; no `if provider == "openai":` branches |
| State machine| LangGraph chain    | New behaviour = new node or edge, not branching inside nodes      |
| DI           | FastAPI app        | `Depends()` for all shared resources                              |
| Repository   | DB layer           | Data access in repository classes, not route handlers             |
| Factory      | `graph.py`         | Node wiring centralised; nodes are pure functions                 |
| Adapter      | `imdbapi/` client  | Wraps external API, maps to internal domain types                 |
| Config object| All submodules     | `BaseSettings` loaded once; no scattered `os.getenv()`            |

---

## Cross-cutting change checklist

Before declaring any task done, verify:

1. GitHub parent issue + child issues in repos that change; Agent Briefing present
2. Branch follows naming convention
3. ADR written for new tech decisions, external deps, or project-wide patterns
4. Implementation matches existing design pattern; pre-commit passes
5. Tests added; coverage doesn't regress
6. `.env.example` updated in all affected repos
7. `Dockerfile` + `docker-compose.yml` updated for dep/env/port changes
8. `Jenkinsfile` / `.github/workflows/` reviewed
9. `.puml` diagrams updated; `workspace.dsl` updated if C4 changed
10. `README.md` + `CHANGELOG.md` updated; `docs/` pages updated
11. All AI context files mirrored (`CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, `.junie/guidelines.md`,
    `.github/copilot-instructions.md`, `.cursorrules`)
12. Submodule pointer bumped after merge

---

## AI Personas

This project uses specialised AI personas. Reference them in JetBrains AI chat or switch to the appropriate tool:

| Persona   | JetBrains AI prompt               | Claude Code    | Gemini CLI       |
|-----------|-----------------------------------|----------------|------------------|
| Architect | "Act as architect: [topic]"       | `/architect`   | `@architect`     |
| Developer | "Act as developer: implement #N"  | `/implement`   | `@developer`     |
| Reviewer  | "Act as reviewer: review PR #N"   | `/review-pr`   | `@reviewer`      |
| Debugger  | "Act as debugger: [symptom]"      | `/debug`       | `@debugger`      |
| Mentor    | "Act as mentor: explain [topic]"  | `/mentor`      | `@mentor`        |
| PM        | "Act as PM: organise backlog"     | `/pm`          | `@pm`            |
| SDET      | "Act as SDET: write tests for X"  | `/sdet`        | n/a              |
| Auditor   | "Act as auditor: audit [area]"    | `/auditor`     | n/a              |

Full persona definitions: `.ai/personas/` directory.
Persona prompts for Copilot Chat: `.github/prompts/` directory.
