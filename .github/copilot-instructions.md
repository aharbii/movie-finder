# GitHub Copilot — Movie Finder project instructions

Movie Finder is a full-stack AI application: natural-language film description → semantic search →
IMDb enrichment → streamed Q&A. Multi-repo structure using Git submodules.

Each repo and submodule may carry its own `.github/copilot-instructions.md`; keep them aligned
with the corresponding `CLAUDE.md`, `GEMINI.md`, and `AGENTS.md`.

---

## Repo structure

| Path                     | Role                                        |
| ------------------------ | ------------------------------------------- |
| `backend/`               | FastAPI + uv workspace root (Python 3.13)   |
| `backend/app/`           | FastAPI routes, auth, SSE streaming         |
| `backend/chain/`         | LangGraph 8-node AI pipeline                |
| `backend/imdbapi/`       | Async IMDb REST client                      |
| `backend/rag_ingestion/` | Offline embedding ingestion (standalone uv) |
| `frontend/`              | Angular 21 SPA                              |
| `docs/`                  | MkDocs documentation site                   |
| `infrastructure/`        | Azure IaC (Terraform/Bicep — issue #22)     |

GitHub issues: always create in `aharbii/movie-finder` first, then link from submodule repos.

---

## Python standards (backend)

- Python 3.13, `uv` workspace (`backend/` root), `ruff` + `mypy --strict`
- Line length 100. No bare `except:`. No `os.getenv()` — use `config.py` + Pydantic `BaseSettings`.
- Async all the way. No blocking I/O in async context.
- Docstrings on all public functions and classes (Google style).
- Tests with `pytest --asyncio-mode=auto`. Coverage must not regress.
- Pre-commit hooks: `uv run pre-commit run --all-files` (each submodule has its own config).

## TypeScript standards (frontend)

- Angular 21 standalone components only — no NgModules.
- Signals for all reactive state. No `BehaviorSubject` for component state.
- Strict mode: `noImplicitAny`, `strictNullChecks`. No `any` — use `unknown` + narrowing.
- ESLint 9 flat config + Prettier. Tests with Vitest.

---

## Design patterns — follow these, do not drift

| Pattern                   | Where                   | Rule                                                                  |
| ------------------------- | ----------------------- | --------------------------------------------------------------------- |
| **State machine**         | `chain/` (LangGraph)    | New behaviour = new node or edge, not branching inside existing nodes |
| **Strategy**              | Embedding/LLM providers | New provider = new class implementing the interface                   |
| **Dependency injection**  | `app/` routes           | Use FastAPI `Depends()`. Never instantiate inside route handlers.     |
| **Repository**            | Database layer          | No raw SQL in route handlers. Data access in repository classes.      |
| **Smart/Dumb components** | Angular                 | Smart = owns services + state. Dumb = `@Input()` only.                |
| **Facade service**        | Angular HTTP            | Components never call `HttpClient` directly.                          |
| **Configuration object**  | All submodules          | All env vars loaded once in `config.py`.                              |

---

## Architecture — always update when changing structure

- **PlantUML** (`.puml` in `docs/architecture/plantuml/`) — canonical UML. Never generate `.mdj` StarUML files.
- **Structurizr C4** (`docs/architecture/workspace.dsl`) — L1–L3 views.
- **ADRs** (`docs/architecture/decisions/`) — required for tech stack, dependency, or pattern changes.

---

## Secrets and environment

- Never commit secrets. `detect-secrets` pre-commit hook enforces this.
- Production secrets in Azure Key Vault. CI secrets in Jenkins credentials store.
- When adding a new secret: update `.env.example` in every affected repo + flag to user.

---

## Branching and commits

```
main  ← protected, PR required, 1 approval
  └── feature/<kebab-case>
  └── fix/<kebab-case>
  └── chore/<kebab-case>
  └── docs/<kebab-case>
  └── hotfix/<kebab-case>
```

Conventional Commits: `feat(chain): add Gemini embedding provider`

---

## Cross-cutting — check these for every change

1. GitHub issues in parent + submodule repo (linked)
2. Branch in submodule + `chore/` pointer bump in parent
3. ADR if tech stack or pattern changes
4. `.env.example` updated in every affected repo
5. Dockerfile + docker-compose updated
6. Jenkins `Jenkinsfile` reviewed
7. PlantUML diagrams updated
8. Structurizr `workspace.dsl` updated
9. Docs updated (`README.md`, `CHANGELOG.md`, `docs/`)
10. All sibling submodules assessed for impact
