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

| Submodule      | Path                                 | GitHub                                                                                | Description                                       |
| -------------- | ------------------------------------ | ------------------------------------------------------------------------------------- | ------------------------------------------------- |
| backend        | [`backend/`](backend/)               | [movie-finder-backend](https://github.com/aharbii/movie-finder-backend)               | FastAPI app + LangGraph pipeline integration root |
| frontend       | [`frontend/`](frontend/)             | [movie-finder-frontend](https://github.com/aharbii/movie-finder-frontend)             | Angular 21 SPA                                    |
| docs           | [`docs/`](docs/)                     | [movie-finder-docs](https://github.com/aharbii/movie-finder-docs)                     | Architecture, API spec, DevOps guides             |
| infrastructure | [`infrastructure/`](infrastructure/) | [movie-finder-infrastructure](https://github.com/aharbii/movie-finder-infrastructure) | IaC and provisioning scripts                      |

The **backend** submodule itself integrates four further sub-projects as nested submodules:

| Sub-project   | Path                     | Description                               |
| ------------- | ------------------------ | ----------------------------------------- |
| app           | `backend/app/`           | FastAPI routers, auth, session store      |
| chain         | `backend/chain/`         | LangGraph multi-agent pipeline            |
| imdbapi       | `backend/chain/imdbapi/` | Async IMDb REST API client                |
| rag_ingestion | `rag/` | Kaggle dataset → embed → Qdrant ingestion |

---

## Which compose to use

| Scenario                                                       | Stack to use                      | Command                           |
| -------------------------------------------------------------- | --------------------------------- | --------------------------------- |
| Run the full app end-to-end (verify everything works together) | Root compose (`movie-finder/`)    | `make up` from root               |
| Backend development (hot-reload, source mounts, debugger)      | Backend standalone (`backend/`)   | `make up` from `backend/`         |
| Frontend development (Angular dev server, live reload)         | Frontend standalone (`frontend/`) | `make editor-up` from `frontend/` |

> **Never run the root compose and backend standalone at the same time.** Both bind to port 5432 (postgres) and 8000 (backend) by default. Running both causes an "address already in use" error.

---

## Quick start — full stack (Docker)

**Prerequisites:** Docker 24+, git 2.20+

```bash
# 1. Clone with all submodules
git clone --recurse-submodules https://github.com/aharbii/movie-finder.git
cd movie-finder

# 2. Create your environment file
cp .env.example .env
$EDITOR .env
# Required secrets (see Environment variables below):
#   DB_PASSWORD, APP_SECRET_KEY,
#   provider keys for your selected CLASSIFIER/REASONING/EMBEDDING providers,
#   QDRANT_URL, QDRANT_API_KEY_RO

# 3. Build and start all services
make up

# Services
#   Frontend:   http://localhost:80
#   Backend:    http://localhost:8000
#   API docs:   http://localhost:8000/docs   (FastAPI interactive docs)
#   PostgreSQL: localhost:5432
```

The backend container runs `alembic upgrade head` automatically before starting. On first run with a fresh database this adds ~15-30 seconds before the backend is ready.

> **Qdrant is not included in docker-compose.** The default backend profile connects to Qdrant Cloud. Provider SDKs are installed at image build time through `WITH_PROVIDERS`, so choose a bundle that matches your runtime env vars.

---

## Quick start — backend standalone

For backend development (hot-reload, debugger, source mounts):

```bash
cd backend/
make init           # build dev image, create .env from template, install git hook
$EDITOR .env        # fill in required API keys
make up             # start postgres + backend  →  http://localhost:8000
make down           # stop when done
```

See [`movie-finder-backend`](https://github.com/aharbii/movie-finder-backend) for full backend documentation.

---

## Quick start — frontend standalone

If you only need the Angular UI (pointing at a running backend):

```bash
cd frontend/
make init           # pull image, npm ci, install git hook
make editor-up      # start dev container  →  http://localhost:4200  (proxies /api → localhost:8000)
```

See [`movie-finder-frontend`](https://github.com/aharbii/movie-finder-frontend) for full frontend documentation.

---

## Environment variables

Copy `.env.example` to `.env` and fill in all values. Never commit `.env`.

| Variable                   | Required | Description                                                          |
| -------------------------- | -------- | -------------------------------------------------------------------- |
| `WITH_PROVIDERS`           | Yes      | Backend build bundle, default `default-cloud`; use `ollama-qdrant` for Ollama + Qdrant |
| `DB_PASSWORD`              | Yes      | PostgreSQL password                                                  |
| `DATABASE_URL`             | Yes      | Full PostgreSQL connection URL                                       |
| `APP_SECRET_KEY`           | Yes      | JWT signing secret (`openssl rand -hex 32`)                          |
| `CLASSIFIER_PROVIDER`      | Yes      | `anthropic`, `openai`, `groq`, `together`, `ollama`, or `google`     |
| `CLASSIFIER_MODEL`         | Yes      | Lightweight classifier/confirmation model                            |
| `REASONING_PROVIDER`       | Yes      | `anthropic`, `openai`, `groq`, `together`, `ollama`, or `google`     |
| `REASONING_MODEL`          | Yes      | Reasoning and Q&A model                                              |
| `EMBEDDING_PROVIDER`       | Yes      | `openai`, `ollama`, `sentence-transformers`, or `huggingface`        |
| `EMBEDDING_MODEL`          | Yes      | Query embedding model; must match RAG ingestion                      |
| `EMBEDDING_DIMENSION`      | Yes      | Query embedding dimension; must match RAG ingestion                  |
| `VECTOR_STORE`             | Yes      | `qdrant`, `chromadb`, `pinecone`, or `pgvector`                      |
| `VECTOR_COLLECTION_PREFIX` | Yes      | Final target is `{prefix}_{sanitized_model}_{dimension}`             |
| `QDRANT_URL`               | if qdrant | Qdrant Cloud cluster URL                                             |
| `QDRANT_API_KEY_RO`        | if qdrant | Qdrant Cloud read-only API key                                       |
| Provider API keys          | by provider | `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GROQ_API_KEY`, `TOGETHER_API_KEY`, `GOOGLE_API_KEY` |
| `OLLAMA_BASE_URL`          | if ollama | Docker-reachable Ollama endpoint                                     |
| `LANGSMITH_API_KEY`        | No       | LangSmith tracing (optional observability)                           |
| `CORS_ORIGINS`             | Yes      | JSON array of allowed browser origins                                |
| `GLOBAL_RATE_LIMIT`        | No       | Global API fallback rate limit                                       |
| `AUTH_RATE_LIMIT`          | No       | Login/token route rate limit                                         |
| `CHAT_RATE_LIMIT`          | No       | Authenticated chat route rate limit                                  |
| `MAX_MESSAGE_LENGTH`       | No       | Maximum accepted user message length                                 |

The `imdbapi.dev` REST API requires no authentication.
The backend container applies `alembic upgrade head` during startup before the
FastAPI process begins serving requests.

---

## Tech stack

| Layer            | Technology                                                                           |
| ---------------- | ------------------------------------------------------------------------------------ |
| Frontend         | Angular 21, TypeScript 5.9, Vitest, ESLint 9, nginx                                  |
| Backend          | Python 3.13, FastAPI, LangGraph, asyncpg                                             |
| AI — chain       | Anthropic Claude (Haiku for classification, Sonnet for reasoning)                    |
| AI — embeddings  | OpenAI `text-embedding-3-large` (3072 dimensions)                                    |
| Vector store     | Qdrant Cloud                                                                         |
| Relational DB    | PostgreSQL 16                                                                        |
| Package manager  | npm (frontend), uv (backend — workspace)                                             |
| Containerisation | Docker multi-stage builds                                                            |
| CI/CD            | Jenkins (Multibranch Pipelines)                                                      |
| Registry         | Azure Container Registry (ACR)                                                       |
| Cloud            | Azure Container Apps, Azure Database for PostgreSQL Flexible Server, Azure Key Vault |

---

## API reference

The full API specification lives at [`docs/api/openapi.yaml`](https://github.com/aharbii/movie-finder-docs/blob/main/api/openapi.yaml) (OpenAPI 3.1.0).

A browsable Swagger UI is at [`docs/api/swagger-ui.html`](https://github.com/aharbii/movie-finder-docs/blob/main/api/swagger-ui.html) — open it locally or via GitHub Pages.

| Method   | Path                         | Auth   | Description                             |
| -------- | ---------------------------- | ------ | --------------------------------------- |
| `POST`   | `/auth/register`             | —      | Create account, returns JWT pair        |
| `POST`   | `/auth/login`                | —      | Authenticate, returns JWT pair          |
| `POST`   | `/auth/refresh`              | —      | Exchange refresh token for new JWT pair |
| `POST`   | `/chat`                      | Bearer | Send message, receive SSE stream        |
| `GET`    | `/chat/sessions`             | Bearer | List all sessions for current user      |
| `GET`    | `/chat/{session_id}/history` | Bearer | Get full message history for a session  |
| `DELETE` | `/chat/{session_id}`         | Bearer | Delete session and its messages         |
| `GET`    | `/health`                    | —      | Liveness probe                          |

Access tokens expire in **30 minutes**. Refresh tokens expire in **7 days**.

---

## CI/CD overview

Three pipeline modes are automatically selected based on Git context:

| Mode         | Trigger             | What happens                                                             |
| ------------ | ------------------- | ------------------------------------------------------------------------ |
| CONTRIBUTION | Feature branch / PR | Lint + test only. Fast feedback, no build.                               |
| INTEGRATION  | Push to `main`      | + Docker build + push `:sha8` `:latest` to ACR + optional staging deploy |
| RELEASE      | `v*` tag            | + Push `:v1.2.3` to ACR + production deploy (manual approval on backend) |

Documentation is validated separately by the `.github/workflows/docs.yml` GitHub Actions workflow.
Docs-related pull requests run generated-page preparation plus `mkdocs build`, and pushes to `main`
build and deploy the documentation site to GitHub Pages.

See [`docs/devops/setup.md`](https://github.com/aharbii/movie-finder-docs/blob/main/devops/setup.md) for Jenkins setup, Azure provisioning, and credential configuration.

---

## Documentation index

| Document                                                                                               | Audience              | Description                            |
| ------------------------------------------------------------------------------------------------------ | --------------------- | -------------------------------------- |
| [ONBOARDING.md](ONBOARDING.md)                                                                         | New team members      | Day-zero setup for every role          |
| [CONTRIBUTING.md](CONTRIBUTING.md)                                                                     | All contributors      | Branching, commits, PRs, releases      |
| [backend README](https://github.com/aharbii/movie-finder-backend/blob/main/README.md)                  | Backend / AI teams    | Backend architecture and commands      |
| [backend INTEGRATION.md](https://github.com/aharbii/movie-finder-backend/blob/main/INTEGRATION.md)     | All teams             | Cross-repo workflow and secret sharing |
| [backend CONTRIBUTING.md](https://github.com/aharbii/movie-finder-backend/blob/main/CONTRIBUTING.md)   | Backend contributors  | Python code standards, testing         |
| [frontend README](https://github.com/aharbii/movie-finder-frontend/blob/main/README.md)                | Frontend team         | Angular architecture and commands      |
| [frontend CONTRIBUTING.md](https://github.com/aharbii/movie-finder-frontend/blob/main/CONTRIBUTING.md) | Frontend contributors | TypeScript standards, testing          |
| [docs/devops/setup.md](https://github.com/aharbii/movie-finder-docs/blob/main/devops/setup.md)         | DevOps / Platform     | Jenkins + Azure full setup guide       |
| [docs/api/openapi.yaml](https://github.com/aharbii/movie-finder-docs/blob/main/api/openapi.yaml)       | API consumers         | OpenAPI 3.1.0 machine-readable spec    |
| [docs/api/swagger-ui.html](https://github.com/aharbii/movie-finder-docs/blob/main/api/swagger-ui.html) | API consumers         | Interactive API browser                |

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

| Who                | Contact                                                                                              |
| ------------------ | ---------------------------------------------------------------------------------------------------- |
| Backend / App team | See `backend/CONTRIBUTING.md`                                                                        |
| Frontend team      | See `frontend/CONTRIBUTING.md`                                                                       |
| AI / Chain team    | See `backend/chain/CONTRIBUTING.md`                                                                  |
| IMDb API team      | See `backend/chain/imdbapi/CONTRIBUTING.md`                                                          |
| RAG / Data team    | See `rag/CONTRIBUTING.md`                                                          |
| DevOps / Platform  | See [`docs/devops/setup.md`](https://github.com/aharbii/movie-finder-docs/blob/main/devops/setup.md) |
