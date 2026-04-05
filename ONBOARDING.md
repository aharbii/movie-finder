# Movie Finder — Developer Onboarding

Welcome to the project. This guide takes you from zero to a fully running local environment without needing to ask anyone.

---

## Table of contents

1. [What is Movie Finder?](#1-what-is-movie-finder)
2. [Repository structure](#2-repository-structure)
3. [Prerequisites](#3-prerequisites)
4. [Get the code](#4-get-the-code)
5. [Secrets you need to request](#5-secrets-you-need-to-request)
6. [Ports and URLs at a glance](#6-ports-and-urls-at-a-glance)
7. [Run the full stack with Docker](#7-run-the-full-stack-with-docker)
8. [Run the backend for local development](#8-run-the-backend-for-local-development)
9. [Run the frontend for local development](#9-run-the-frontend-for-local-development)
10. [Run tests](#10-run-tests)
11. [Working in a submodule standalone workspace](#11-working-in-a-submodule-standalone-workspace)
12. [Your first contribution](#12-your-first-contribution)
13. [Role-specific guides](#13-role-specific-guides)
14. [Troubleshooting](#14-troubleshooting)

---

## 1. What is Movie Finder?

Movie Finder is a fullstack AI application. Users describe a film they half-remember in natural language. The system:

1. Searches a semantically-embedded corpus of movies (vector search via Qdrant)
2. Enriches the top candidates with live data from IMDb
3. Presents ranked candidates and asks the user to confirm their pick
4. Switches to Q&A mode once a movie is confirmed — answering follow-up questions via Claude

The conversation is streamed in real time over Server-Sent Events (SSE). There is no page reload at any point.

**User-facing screens:**

- `/login` and `/register` — authentication
- `/chat` — main interface: session sidebar, message thread, movie cards panel

---

## 2. Repository structure

```
movie-finder/                      ← this repo (orchestrator / root)
├── backend/                       ← submodule: FastAPI + LangGraph integration root
│   ├── app/                       ←   directory: auth, chat, session store (FastAPI)
│   ├── chain/                     ←   submodule: LangGraph multi-agent pipeline
│   │   └── imdbapi/               ←     submodule: async IMDb REST API client (nested)
│   └── rag_ingestion/             ←   submodule: dataset → embed → Qdrant
├── frontend/                      ← submodule: Angular 21 SPA
├── docs/                          ← submodule: API spec, architecture, DevOps guide
├── infrastructure/                ← submodule: IaC and provisioning scripts
├── docker-compose.yml             ← full-stack local development
└── .env.example                   ← environment variable template
```

Every labelled submodule is an independent git repository. Changes must be committed and pushed in the submodule first, then the parent repo's submodule pointer must be updated.

---

## 3. Prerequisites

Both the backend and frontend use a **Docker-only developer contract**: all quality commands
(lint, test, typecheck) run inside containers. You do not need a host Python, uv, Node.js,
or npm installation.

### Required for everyone

| Tool                       | Version | Install                                                            |
| -------------------------- | ------- | ------------------------------------------------------------------ |
| git                        | 2.20+   | System package manager or [git-scm.com](https://git-scm.com)       |
| Docker Desktop (or Engine) | 24+     | [docs.docker.com/get-docker](https://docs.docker.com/get-docker/)  |
| make                       | 3.81+   | Standard on macOS/Linux; `winget install GnuWin32.Make` on Windows |

### Recommended VS Code extensions

- Remote Containers (Dev Containers)
- Python + Pylance + Ruff (backend work inside the container)
- ESLint + Prettier + Angular Language Service (frontend work inside the container)
- Docker, GitLens

---

## 4. Get the code

```bash
git clone --recurse-submodules https://github.com/aharbii/movie-finder.git
cd movie-finder
```

The `--recurse-submodules` flag initialises all nested submodules in one step. If you forgot it:

```bash
git submodule update --init --recursive
```

Confirm the submodules are populated:

```bash
ls backend/chain/src/     # should contain chain/ package
ls backend/chain/imdbapi/src/   # should contain imdbapi/ package
ls frontend/src/app/      # should contain Angular components
```

---

## 5. Secrets you need to request

The application requires external API keys that are not in version control. Request these from the relevant team before starting.

| Secret              | Who to ask                  | Where to put it |
| ------------------- | --------------------------- | --------------- |
| `QDRANT_URL`        | RAG / Data Engineering team | `.env`          |
| `QDRANT_API_KEY_RO` | RAG / Data Engineering team | `.env`          |
| `ANTHROPIC_API_KEY` | Project lead or team lead   | `.env`          |
| `OPENAI_API_KEY`    | Project lead or team lead   | `.env`          |

You generate these yourself:

```bash
# APP_SECRET_KEY — random 32-byte hex string
openssl rand -hex 32

# DB_PASSWORD — any strong password (used only locally)
openssl rand -hex 16
```

Copy the template and fill in all values:

```bash
cp .env.example .env
$EDITOR .env
```

> The `imdbapi.dev` REST API requires no key — the backend calls it unauthenticated.

---

## 6. Which stack to run

There are two separate compose stacks. **Never run both at the same time** — they bind to the same ports (5432, 8000) by default.

| You want to…                                              | Use this stack                    | Command                           |
| --------------------------------------------------------- | --------------------------------- | --------------------------------- |
| Run the full app (postgres + backend + frontend together) | Root compose (`movie-finder/`)    | `make up` from root               |
| Develop the backend (hot-reload, source mounts, debugger) | Backend standalone (`backend/`)   | `make up` from `backend/`         |
| Develop the frontend (Angular live reload)                | Frontend standalone (`frontend/`) | `make editor-up` from `frontend/` |

> The root compose uses the production `runtime` image — no source mounts, no hot-reload.
> For backend development, use `cd backend/ && make up` instead.

---

## 7. Ports and URLs at a glance

Every service has a fixed default port. All are configurable via `.env` if there is a conflict.

| Service                       | Default URL                                              | Who starts it                                         |
| ----------------------------- | -------------------------------------------------------- | ----------------------------------------------------- |
| Frontend (nginx / dev server) | http://localhost:80 (prod) · http://localhost:4200 (dev) | `make up` from root / `make editor-up` in `frontend/` |
| Backend (FastAPI)             | http://localhost:8000                                    | `make up` from root / `make up` in `backend/`         |
| Backend Swagger UI            | http://localhost:8000/docs                               | Same as backend                                       |
| Backend liveness              | http://localhost:8000/health/live                        | Same as backend                                       |
| Backend readiness             | http://localhost:8000/health/ready                       | Same as backend (checks DB connection)                |
| PostgreSQL                    | localhost:5432                                           | `make up` from root / `make up` in `backend/`         |
| MkDocs docs site              | http://localhost:8001                                    | `make mkdocs` from repo root                          |
| Structurizr C4                | http://localhost:18080                                   | `make structurizr` from repo root                     |
| PlantUML server               | http://localhost:18088                                   | `make plantuml` from repo root                        |

> Qdrant Cloud is always **external** — no local Qdrant container exists.

---

## 8. Run the full stack with Docker

This is the fastest way to verify everything works end-to-end. The backend container automatically runs `alembic upgrade head` before uvicorn starts — allow up to 45 seconds for the backend to become healthy on first boot.

```bash
# From the repo root
make up              # start postgres + backend + frontend (detached)
make logs            # stream all service logs
make down            # stop and remove containers
```

Or with raw compose if you need rebuild:

```bash
docker compose up --build
```

**Service endpoints:**

| Service                  | URL                                | Notes                                  |
| ------------------------ | ---------------------------------- | -------------------------------------- |
| Frontend (Angular SPA)   | http://localhost:80                | nginx-served                           |
| Backend (FastAPI)        | http://localhost:8000              |                                        |
| Backend interactive docs | http://localhost:8000/docs         | Swagger UI (auto-generated)            |
| Backend liveness         | http://localhost:8000/health/live  | Returns `{"status": "ok"}`             |
| Backend readiness        | http://localhost:8000/health/ready | Returns 503 if DB unreachable          |
| PostgreSQL               | localhost:5432                     | `movie_finder` DB, `movie_finder` user |

**Stop and clean up:**

```bash
make down                        # stop containers
docker compose down -v           # also delete the postgres volume (wipes DB data)
```

---

## 8. Run the backend for local development

The backend uses a Docker-only developer contract. All commands run inside containers.

```bash
cd backend/

# One-time setup: build dev image, create .env from template, install git hook
make init

# Fill in your API keys
$EDITOR .env

# Start postgres + backend (hot-reload)
make up
# Backend: http://localhost:8000
# Docs:    http://localhost:8000/docs

# Follow logs
make logs

# Open a shell inside the running container
make shell

# Stop the stack
make down
```

Common quality commands (run from `backend/`):

```bash
make lint           # ruff check (report only)
make fix            # ruff check --fix + ruff format (auto-apply)
make typecheck      # mypy --strict
make test           # pytest app/tests/
make test-coverage  # pytest + coverage XML/HTML + JUnit report
make pre-commit     # full hook suite
```

---

## 9. Run the frontend for local development

The frontend uses a Docker-only developer contract. All commands run inside containers.
The dev server proxies `/api` requests to the backend at `localhost:8000`.

```bash
cd frontend/

# One-time setup: pull image, npm ci, install git hook
make init

# Start dev container (dev server with hot-reload)
make editor-up
# Angular app: http://localhost:4200
# API requests: proxied to http://localhost:8000
```

The backend must be running for the app to function. Use `make up` from `backend/` in a
separate terminal, or have `docker compose up backend postgres` running.

Common quality commands (run from `frontend/`):

```bash
make typecheck      # tsc --noEmit
make lint           # ESLint check
make fix            # ESLint auto-fix + Prettier format
make test           # Vitest watch mode
make test-coverage  # single run with coverage report (JUnit + Cobertura XML)
make check          # typecheck + lint + test-coverage
make shell          # open shell inside the container
make editor-down    # stop the dev container
```

---

## 10. Run tests

### Backend tests

```bash
cd backend/

# Run all backend app tests (PostgreSQL starts automatically inside Docker)
make test

# Run with coverage report (Cobertura XML + JUnit XML for Jenkins)
make test-coverage
```

To test child repos (chain, imdbapi, rag_ingestion) run `make test` from within each
child directory (e.g. `cd backend/chain && make test`).

### Frontend tests

```bash
cd frontend/

npm run test:ci
# Reports generated at:
#   coverage/lcov.info             (LCOV — for local tools)
#   coverage/cobertura-coverage.xml (Cobertura — for Jenkins)
#   $VITEST_JUNIT_OUTPUT_FILE       (JUnit XML — for Jenkins)
```

---

## 11. Working in a submodule standalone workspace

You do not need to clone the entire `movie-finder` monorepo to work on a single service.
Each submodule is a fully independent repository with its own Docker contract and VS Code
configuration. Clone only what you need.

### Which repo to clone

| Your role              | Clone this                                         |
| ---------------------- | -------------------------------------------------- |
| Backend (FastAPI app)  | `https://github.com/aharbii/movie-finder-backend`  |
| AI pipeline (chain)    | `https://github.com/aharbii/movie-finder-chain`    |
| IMDb API client        | `https://github.com/aharbii/imdbapi-client`        |
| RAG / Data engineering | `https://github.com/aharbii/movie-finder-rag`      |
| Frontend               | `https://github.com/aharbii/movie-finder-frontend` |

> **Note:** `movie-finder-chain` has `imdbapi-client` as a nested submodule.
> Clone it with `git clone --recurse-submodules`.

### Backend (FastAPI) — standalone

```bash
git clone --recurse-submodules https://github.com/aharbii/movie-finder-backend.git
cd movie-finder-backend

make init           # build dev image, create .env from template
$EDITOR .env        # fill in: APP_SECRET_KEY, QDRANT_URL, QDRANT_API_KEY_RO,
                    #           QDRANT_COLLECTION_NAME, ANTHROPIC_API_KEY, OPENAI_API_KEY
make up             # starts postgres + backend
                    # Backend: http://localhost:8000
                    # Swagger: http://localhost:8000/docs

# VS Code: attach to the running 'backend' container
# Dev Containers: Attach to Running Container...

make lint && make test   # quality checks
make down                # stop
```

### Chain (LangGraph) — standalone

```bash
git clone --recurse-submodules https://github.com/aharbii/movie-finder-chain.git
cd movie-finder-chain

make init           # build image, create .env, install git hook
$EDITOR .env        # fill in: QDRANT_URL, QDRANT_API_KEY_RO, QDRANT_COLLECTION_NAME,
                    #           OPENAI_API_KEY, ANTHROPIC_API_KEY
make editor-up      # start container (stays running for VS Code attach + interactive use)

# VS Code: attach to the running 'chain' container

make lint && make test   # quality checks (no live credentials needed for tests)
make editor-down         # stop
```

### IMDb API client — standalone

```bash
git clone https://github.com/aharbii/imdbapi-client.git
cd imdbapi-client

make init           # no API key required
make editor-up      # start container

make test           # all tests (no live network calls — fully mocked)
make editor-down
```

### RAG ingestion — standalone

```bash
git clone https://github.com/aharbii/movie-finder-rag.git
cd movie-finder-rag

make init           # build image, create .env, install git hook
$EDITOR .env        # fill in: QDRANT_URL, QDRANT_API_KEY_RW, QDRANT_COLLECTION_NAME,
                    #           OPENAI_API_KEY, KAGGLE_API_TOKEN
make editor-up      # start workspace container

make test           # run tests
make ingest         # run the full ingestion pipeline (writes to Qdrant Cloud)
make editor-down
```

### Frontend — standalone

```bash
git clone https://github.com/aharbii/movie-finder-frontend.git
cd movie-finder-frontend

make init           # pull image, npm ci, install git hook
make editor-up      # start dev server  →  http://localhost:4200
                    # proxies /api to http://localhost:8000
                    # (start the backend separately if you need live API calls)

# VS Code: attach to the running 'movie-finder-frontend-dev' container

make check          # typecheck + lint + test-coverage
make editor-down    # stop
```

### Branching convention (applies in every repo)

```
feature/<what-you-are-building>    e.g. feature/sse-reconnect-logic
fix/<what-you-are-fixing>          e.g. fix/imdbapi-retry-delay
chore/<maintenance-task>           e.g. chore/bump-langchain-to-0-3-5
docs/<what-you-are-documenting>    e.g. docs/add-api-sequence-diagram
hotfix/<critical-fix>              e.g. hotfix/broken-refresh-token
```

Rules:

- All lowercase, kebab-case
- Branch from `main`
- Keep branches short-lived; open a PR when ready

### Commit message format

```
feat(chain): add gemini embedding provider
fix(imdbapi): reduce retry base delay from 30s to 2s
chore(frontend): bump angular to 21.3.0
docs(backend): clarify Docker-only workflow in README
```

`<type>(<scope>): <summary in imperative mood, ≤72 chars>`

### When you are done — submodule pointer bump

If your work lives in a child repo and needs to be reflected in a parent:

```bash
# In the direct parent repo (e.g. backend/):
git add chain/
git commit -m "chore(chain): bump to latest main"
git push

# In the root repo (if the parent also changed):
git add backend/
git commit -m "chore(backend): bump to latest main"
git push
```

---

## 12. Your first contribution

1. **Create a branch** from `main`:

   ```bash
   git checkout main && git pull
   git checkout -b feature/my-change
   ```

2. **Make your changes** in the relevant submodule (or root if cross-cutting)

3. **Run local checks** before committing:

   ```bash
   # Backend (from backend/)
   make lint && make test

   # Frontend (from frontend/)
   make check
   ```

4. **Commit** using conventional commits:

   ```bash
   git add <files>
   git commit -m "feat(chat): improve session title generation"
   ```

   Pre-commit hooks run automatically on `git commit`. Fix any failures before retrying.

5. **Push** and open a pull request:

   ```bash
   git push -u origin feature/my-change
   ```

   Open the PR on GitHub. Jenkins triggers automatically and runs lint + tests. If the change
   affects project documentation, the GitHub Actions docs workflow also runs generated-page
   preparation and `mkdocs build`.

6. **Wait for CI green** + 1 reviewer approval, then merge.

> If you are working in a nested submodule (e.g. `backend/chain`), commit and push there first, then update the pointer in `backend/`, then update the pointer in the root repo. See [`CONTRIBUTING.md §Submodule workflow`](CONTRIBUTING.md#submodule-workflow).

---

## 13. Role-specific guides

Jump to the guide that matches your role:

| Role                   | Start here                                                                                                                                                                                       |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Backend / App engineer | [backend README](https://github.com/aharbii/movie-finder-backend/blob/main/README.md) → [backend CONTRIBUTING.md](https://github.com/aharbii/movie-finder-backend/blob/main/CONTRIBUTING.md)     |
| AI / Chain engineer    | [chain README](https://github.com/aharbii/movie-finder-chain/blob/main/README.md) → [chain CONTRIBUTING.md](https://github.com/aharbii/movie-finder-chain/blob/main/CONTRIBUTING.md)             |
| IMDb API engineer      | [imdbapi README](https://github.com/aharbii/imdbapi-client/blob/main/README.md) → [imdbapi CONTRIBUTING.md](https://github.com/aharbii/imdbapi-client/blob/main/CONTRIBUTING.md)                 |
| RAG / Data engineer    | [rag README](https://github.com/aharbii/movie-finder-rag/blob/main/README.md) → [rag CONTRIBUTING.md](https://github.com/aharbii/movie-finder-rag/blob/main/CONTRIBUTING.md)                     |
| Frontend engineer      | [frontend README](https://github.com/aharbii/movie-finder-frontend/blob/main/README.md) → [frontend CONTRIBUTING.md](https://github.com/aharbii/movie-finder-frontend/blob/main/CONTRIBUTING.md) |
| DevOps / Platform      | [docs/devops/setup.md](https://github.com/aharbii/movie-finder-docs/blob/main/devops/setup.md)                                                                                                   |

---

## 14. Troubleshooting

### Port already in use — "bind: address already in use" on 5432 or 8000

Both the root compose stack and the backend standalone stack default to the same ports. You can only run one at a time.

```bash
# Find which compose stack is using the port
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Stop the backend standalone stack if it is running
cd backend/ && make down

# Then start the root stack
cd .. && make up
```

### Backend container reported as unhealthy

The backend runs `alembic upgrade head` before starting. On first boot with a fresh database this takes 15–30 seconds. The health check `start_period` is 45 seconds — wait for it before concluding there is a problem.

Check what the container is doing:

```bash
docker compose logs backend     # look for "alembic upgrade" and "Application startup complete"
docker inspect movie-finder-backend | grep -A5 '"Health"'
```

If the container exits immediately, a required env var is likely missing from `.env`. Check `.env.example` for the full list and regenerate:

```bash
cp .env.example .env && $EDITOR .env
```

### `make db-backup` or `make db-restore` fails — "No such container"

Each stack has its own backup targets. Use the one that matches which postgres is currently running:

| Running stack                                  | Backup                           | Restore                                              |
| ---------------------------------------------- | -------------------------------- | ---------------------------------------------------- |
| Root compose (`make up` from root)             | `make db-backup` from root       | `make db-restore FILE=backups/db_<ts>.sql` from root |
| Backend standalone (`make up` from `backend/`) | `make db-backup` from `backend/` | `make db-restore FILE=...` from `backend/`           |

Running `make db-backup` from the wrong directory fails because each stack has a different project name (`movie-finder` vs `movie-finder-backend-local`).

### Submodule directory is empty after cloning

```bash
git submodule update --init --recursive
```

### `make init` fails — Docker image pull error

Ensure Docker Desktop is running and you are logged in:

```bash
docker info          # should show server info
docker pull node:20-alpine   # test connectivity
```

### Backend server fails to start — "could not connect to database"

The PostgreSQL container may not be healthy yet. Check its status:

```bash
cd backend/
make logs            # look for "database system is ready to accept connections"
make down && make up # restart the full stack if needed
```

### Backend server fails to start — "missing required environment variable"

Open `.env` and ensure all required variables are set. Refer to `.env.example` for the full list. Common missing values:

- `APP_SECRET_KEY` — generate with `openssl rand -hex 32`
- `QDRANT_URL` / `QDRANT_API_KEY_RO` — request from RAG team
- `ANTHROPIC_API_KEY` — request from project lead

### Frontend shows "Connection refused" or blank chat responses

The backend is not running or not reachable at port 8000. Start it with `make up` from `backend/`
or `docker compose up backend postgres` from the root.

### Docker build fails — "COPY failed: file not found"

The backend submodules are not initialised. Run:

```bash
git submodule update --init --recursive
docker compose up --build
```

### Pre-commit hook blocks commit — "Possible secret detected"

If the flagged value is not a secret, add `# pragma: allowlist secret` as an inline comment on the same line. Then update the baseline:

```bash
detect-secrets scan > .secrets.baseline
git add .secrets.baseline
git commit -m "chore: update secrets baseline"
```

### Jenkins webhook not triggered

The ngrok URL may have changed (free plan). Get the new URL:

```bash
curl -s http://localhost:4040/api/tunnels | python3 -c \
  "import sys,json; print(json.load(sys.stdin)['tunnels'][0]['public_url'])"
```

Update the GitHub webhook payload URL to `<new-url>/github-webhook/`. See [`docs/devops/setup.md §7`](https://github.com/aharbii/movie-finder-docs/blob/main/devops/setup.md#7-jenkins--expose-via-ngrok).

### Test failures in CI but passing locally

- Check if a pre-existing `.env` file is leaking into the test run — CI uses a clean environment
- Run `make ci-down && make init` to force a clean image rebuild (backend or frontend)
