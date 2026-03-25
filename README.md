# Movie Finder

AI-powered movie discovery and Q&A. Describe a film you half-remember — the system searches a semantically-embedded movie dataset, enriches candidates with live IMDb data, and answers follow-up questions once you have confirmed your pick.

---

## Architecture at a glance

```
Browser (Angular 21 SPA)
        │  REST + SSE  (JWT Bearer)
        ▼
FastAPI Backend  ──────────────────────────────────────────────────────────┐
        │                                                                  │
        ▼                                                                  ▼
LangGraph Chain                                                   PostgreSQL
 ├── RAG Search  ──► Qdrant Cloud (vector store — 3072-dim embeddings)    │
 ├── IMDb Enrichment ──► imdbapi.dev (no auth required)             users / sessions /
 ├── Validation                                                      messages
 ├── Presentation
 ├── Confirmation ◄── user picks a candidate
 ├── Q&A Agent  (Claude — answers questions about the confirmed movie)
 └── Refinement  (up to 3 re-query cycles on dead-end)
                                                  LLMs: Anthropic Claude (chain)
                                                        OpenAI (embeddings)
```

**Deployment:** Azure Container Apps · Azure Database for PostgreSQL Flexible Server · Azure Container Registry · Azure Key Vault
**CI/CD:** Jenkins (CONTRIBUTION → INTEGRATION → RELEASE pipeline modes)

---

## Repository map

This is a **multi-repo monorepo** managed through Git submodules. Each submodule is an independently versioned and deployable unit.

| Submodule | Path | GitHub | Description |
|-----------|------|--------|-------------|
| backend | [`backend/`](backend/) | [movie-finder-backend](https://github.com/aharbii/movie-finder-backend) | FastAPI app + LangGraph pipeline integration root |
| frontend | [`frontend/`](frontend/) | [movie-finder-frontend](https://github.com/aharbii/movie-finder-frontend) | Angular 21 SPA |
| docs | [`docs/`](docs/) | [movie-finder-docs](https://github.com/aharbii/movie-finder-docs) | Architecture, API spec, DevOps guides |
| infrastructure | [`infrastructure/`](infrastructure/) | [movie-finder-infrastructure](https://github.com/aharbii/movie-finder-infrastructure) | IaC and provisioning scripts |

The **backend** submodule itself integrates four further sub-projects as nested submodules:

| Sub-project | Path | Description |
|-------------|------|-------------|
| app | `backend/app/` | FastAPI routers, auth, session store |
| chain | `backend/chain/` | LangGraph multi-agent pipeline |
| imdbapi | `backend/imdbapi/` | Async IMDb REST API client |
| rag_ingestion | `backend/rag_ingestion/` | Kaggle dataset → embed → Qdrant ingestion |

---

## Quick start — full stack (Docker)

**Prerequisites:** Docker 24+, git 2.20+

```bash
# 1. Clone with all submodules (backend nested submodules are included)
git clone --recurse-submodules https://github.com/aharbii/movie-finder.git
cd movie-finder

# 2. Create your environment file
cp .env.example .env
$EDITOR .env
# Required secrets (see Environment variables below):
#   DB_PASSWORD, APP_SECRET_KEY,
#   ANTHROPIC_API_KEY, OPENAI_API_KEY,
#   QDRANT_ENDPOINT, QDRANT_API_KEY

# 3. Build and start all services
docker compose up --build

# Services
#   Frontend:   http://localhost:80
#   Backend:    http://localhost:8000
#   API docs:   http://localhost:8000/docs   (FastAPI interactive docs)
#   PostgreSQL: localhost:5432
```

> **Qdrant is not included in docker-compose.** The backend always connects to the production Qdrant Cloud cluster. Obtain `QDRANT_ENDPOINT` and `QDRANT_API_KEY` from the RAG team.

---

## Quick start — backend standalone

If you only need the API (no frontend):

```bash
cd backend/
make setup          # installs deps, pre-commit hooks, copies .env
$EDITOR .env        # fill in required API keys
make db-start       # starts local PostgreSQL container
make run-dev        # http://localhost:8000  (hot-reload)
```

See [`backend/README.md`](backend/README.md) for full backend documentation.

---

## Quick start — frontend standalone

If you only need the Angular UI (pointing at a running backend):

```bash
cd frontend/
npm ci
npm start           # http://localhost:4200  (proxies /api → localhost:8000)
```

See [`frontend/README.md`](frontend/README.md) for full frontend documentation.

---

## Environment variables

Copy `.env.example` to `.env` and fill in all values. Never commit `.env`.

| Variable | Required | Description |
|----------|----------|-------------|
| `DB_PASSWORD` | Yes | PostgreSQL password |
| `DATABASE_URL` | Yes | Full PostgreSQL connection URL |
| `APP_SECRET_KEY` | Yes | JWT signing secret (`openssl rand -hex 32`) |
| `ANTHROPIC_API_KEY` | Yes | Claude models (LangGraph chain) |
| `OPENAI_API_KEY` | Yes | OpenAI text-embedding-3-large (RAG search) |
| `QDRANT_ENDPOINT` | Yes | Qdrant Cloud cluster URL (from RAG team) |
| `QDRANT_API_KEY` | Yes | Qdrant Cloud API key (from RAG team) |
| `QDRANT_COLLECTION` | Yes | Collection name — default: `movies` |
| `LANGCHAIN_API_KEY` | No | LangSmith tracing (optional observability) |

The `imdbapi.dev` REST API requires no authentication.

---

## Tech stack

| Layer | Technology |
|-------|-----------|
| Frontend | Angular 21, TypeScript 5.9, Vitest, ESLint 9, nginx |
| Backend | Python 3.13, FastAPI, LangGraph, asyncpg |
| AI — chain | Anthropic Claude (Haiku for classification, Sonnet for reasoning) |
| AI — embeddings | OpenAI `text-embedding-3-large` (3072 dimensions) |
| Vector store | Qdrant Cloud |
| Relational DB | PostgreSQL 16 |
| Package manager | npm (frontend), uv (backend — workspace) |
| Containerisation | Docker multi-stage builds |
| CI/CD | Jenkins (Multibranch Pipelines) |
| Registry | Azure Container Registry (ACR) |
| Cloud | Azure Container Apps, Azure Database for PostgreSQL Flexible Server, Azure Key Vault |

---

## API reference

The full API specification lives at [`docs/openapi.yaml`](docs/openapi.yaml) (OpenAPI 3.1.0).

A browsable Swagger UI is at [`docs/swagger-ui.html`](docs/swagger-ui.html) — open it locally or via GitHub Pages.

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/auth/register` | — | Create account, returns JWT pair |
| `POST` | `/auth/login` | — | Authenticate, returns JWT pair |
| `POST` | `/auth/refresh` | — | Exchange refresh token for new JWT pair |
| `POST` | `/chat` | Bearer | Send message, receive SSE stream |
| `GET` | `/chat/sessions` | Bearer | List all sessions for current user |
| `GET` | `/chat/{session_id}/history` | Bearer | Get full message history for a session |
| `DELETE` | `/chat/{session_id}` | Bearer | Delete session and its messages |
| `GET` | `/health` | — | Liveness probe |

Access tokens expire in **30 minutes**. Refresh tokens expire in **7 days**.

---

## CI/CD overview

Three pipeline modes are automatically selected based on Git context:

| Mode | Trigger | What happens |
|------|---------|-------------|
| CONTRIBUTION | Feature branch / PR | Lint + test only. Fast feedback, no build. |
| INTEGRATION | Push to `main` | + Docker build + push `:sha8` `:latest` to ACR + optional staging deploy |
| RELEASE | `v*` tag | + Push `:v1.2.3` to ACR + production deploy (manual approval on backend) |

Documentation is validated separately by the `.github/workflows/docs.yml` GitHub Actions workflow.
Docs-related pull requests run generated-page preparation plus `mkdocs build`, and pushes to `main`
build and deploy the documentation site to GitHub Pages.

See [`docs/devops-setup.md`](docs/devops-setup.md) for Jenkins setup, Azure provisioning, and credential configuration.

---

## Documentation index

| Document | Audience | Description |
|----------|----------|-------------|
| [ONBOARDING.md](ONBOARDING.md) | New team members | Day-zero setup for every role |
| [CONTRIBUTING.md](CONTRIBUTING.md) | All contributors | Branching, commits, PRs, releases |
| [backend/README.md](backend/README.md) | Backend / AI teams | Backend architecture and commands |
| [backend/INTEGRATION.md](backend/INTEGRATION.md) | All teams | Cross-repo workflow and secret sharing |
| [backend/CONTRIBUTING.md](backend/CONTRIBUTING.md) | Backend contributors | Python code standards, testing |
| [frontend/README.md](frontend/README.md) | Frontend team | Angular architecture and commands |
| [frontend/CONTRIBUTING.md](frontend/CONTRIBUTING.md) | Frontend contributors | TypeScript standards, testing |
| [docs/devops-setup.md](docs/devops-setup.md) | DevOps / Platform | Jenkins + Azure full setup guide |
| [docs/openapi.yaml](docs/openapi.yaml) | API consumers | OpenAPI 3.1.0 machine-readable spec |
| [docs/swagger-ui.html](docs/swagger-ui.html) | API consumers | Interactive API browser |
| [docs/workspace.dsl](docs/workspace.dsl) | Architects | Structurizr C4 architecture model |
| [docs/architecture.mdj](docs/architecture.mdj) | Architects | StarUML class and sequence diagrams |

---

## Submodule workflow cheatsheet

```bash
# After cloning — initialise all nested submodules
git submodule update --init --recursive

# Pull latest from upstream for all submodules
git submodule update --remote --merge

# Update a specific submodule to latest main
cd backend/chain && git fetch && git checkout main && git pull && cd ../..
git add backend/chain
git commit -m "chore(chain): bump to latest main"

# After pulling changes that moved a submodule pointer
git pull && git submodule update --init --recursive
```

---

## Getting help

| Who | Contact |
|-----|---------|
| Backend / App team | See `backend/CONTRIBUTING.md` |
| Frontend team | See `frontend/CONTRIBUTING.md` |
| AI / Chain team | See `backend/chain/CONTRIBUTING.md` |
| IMDb API team | See `backend/imdbapi/CONTRIBUTING.md` |
| RAG / Data team | See `backend/rag_ingestion/CONTRIBUTING.md` |
| DevOps / Platform | See `docs/devops-setup.md` |
