# GitHub Copilot — Movie Finder

Movie Finder: full-stack AI app — natural-language film description → Qdrant semantic search → IMDb enrichment → streamed Q&A via SSE.

Multi-repo Git submodule structure. Each submodule may carry its own `.github/copilot-instructions.md`.

---

## Repo structure

| Path                     | Role                                        |
|--------------------------|---------------------------------------------|
| `backend/`               | FastAPI + uv workspace root (Python 3.13)   |
| `backend/app/`           | FastAPI routes, auth, SSE streaming         |
| `backend/chain/`         | LangGraph 8-node AI pipeline                |
| `backend/chain/imdbapi/` | Async IMDb REST client                      |
| `frontend/`              | Angular 21 SPA                              |
| `docs/`                  | MkDocs + PlantUML + Structurizr + ADRs      |
| `infrastructure/`        | Azure IaC                                   |

---

## Python standards (backend)

- Python 3.13, `uv` workspace, `ruff` + `mypy --strict`, line length 100
- No bare `except:` — catch specific types
- No `os.getenv()` — use `config.py` + Pydantic `BaseSettings`
- No `print()` in production — use structured logging
- No `type: ignore` without an explanatory inline comment
- Async all the way — no blocking I/O in async context
- Google-style docstrings on all public functions and classes
- Tests: `pytest --asyncio-mode=auto`

## TypeScript standards (frontend)

- Angular 21 standalone components only — no NgModules
- Signals for all reactive state — no `BehaviorSubject` for component state
- Strict mode: `noImplicitAny`, `strictNullChecks`. No `any` — use `unknown` + narrowing
- ESLint 9 flat config + Prettier must pass

---

## Design patterns — follow these, do not introduce new ones without an ADR

| Pattern                  | Where              | Rule                                                       |
|--------------------------|--------------------|------------------------------------------------------------|
| State machine            | `chain/` LangGraph | New behaviour = new node/edge — not branching inside nodes |
| Strategy                 | Providers          | New provider = new class — no `if provider ==` branching   |
| Dependency injection     | `app/` routes      | `Depends()` only — never instantiate inside handlers       |
| Repository               | DB layer           | No raw SQL in route handlers                               |
| Smart/Dumb components    | Angular            | Smart = owns services + state. Dumb = `@Input()` only      |
| Facade service           | Angular HTTP/SSE   | Components never call `HttpClient` or `EventSource` directly |
| Configuration object     | All submodules     | All env vars once in `config.py` — no scattered `os.getenv()` |

---

## Hard rules

- Never `git add -A` — submodule state and secrets can be staged accidentally
- Never commit secrets — `detect-secrets` pre-commit hook enforces this
- Never `--no-verify` on pre-commit
- Conventional Commits: `type(scope): summary`
- PR descriptions must disclose the AI authoring tool and model

---

## Architecture — always update when changing structure

- PlantUML (`.puml` in `docs/architecture/plantuml/`) — canonical UML, never `.mdj`
- Structurizr C4 (`docs/architecture/workspace.dsl`) — L1–L3 views
- ADRs (`docs/architecture/decisions/`) — required for tech stack, dependency, or pattern changes

---

## Persona prompts for Copilot Chat

Use `#file:` to load a persona before asking complex questions:

| Persona  | File                                |
|----------|-------------------------------------|
| Architect | `#file:.github/prompts/architect.md` |
| Developer | `#file:.github/prompts/developer.md` |
| Reviewer  | `#file:.github/prompts/reviewer.md`  |
| Debugger  | `#file:.github/prompts/debugger.md`  |
| Mentor    | `#file:.github/prompts/mentor.md`    |
| PM        | `#file:.github/prompts/pm.md`        |
