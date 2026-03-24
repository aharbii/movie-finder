# Movie Finder — Developer Onboarding

Welcome to the project. This guide takes you from zero to a fully running local environment without needing to ask anyone.

---

## Table of contents

1. [What is Movie Finder?](#1-what-is-movie-finder)
2. [Repository structure](#2-repository-structure)
3. [Prerequisites](#3-prerequisites)
4. [Get the code](#4-get-the-code)
5. [Secrets you need to request](#5-secrets-you-need-to-request)
6. [Run the full stack with Docker](#6-run-the-full-stack-with-docker)
7. [Run the backend for local development](#7-run-the-backend-for-local-development)
8. [Run the frontend for local development](#8-run-the-frontend-for-local-development)
9. [Run tests](#9-run-tests)
10. [Your first contribution](#10-your-first-contribution)
11. [Role-specific guides](#11-role-specific-guides)
12. [Troubleshooting](#12-troubleshooting)

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
movie-finder/                  ← this repo (orchestrator / root)
├── backend/                   ← submodule: FastAPI + LangGraph
│   ├── app/                   ←   submodule: auth, chat, session store
│   ├── chain/                 ←   submodule: LangGraph multi-agent pipeline
│   ├── imdbapi/               ←   submodule: async IMDb REST API client
│   └── rag_ingestion/         ←   submodule: dataset → embed → Qdrant
├── frontend/                  ← submodule: Angular 21 SPA
├── docs/                      ← submodule: API spec, architecture, DevOps guide
├── infrastructure/            ← submodule: IaC and provisioning scripts
├── docker-compose.yml         ← full-stack local development
└── .env.example               ← environment variable template
```

Every `backend/*/` directory is an independent git repository. Changes to each must be committed and pushed separately, then the backend repo's submodule pointer must be updated.

---

## 3. Prerequisites

Install all of the following before continuing.

### Required for everyone

| Tool | Version | Install |
|------|---------|---------|
| git | 2.20+ | System package manager or [git-scm.com](https://git-scm.com) |
| Docker Desktop (or Engine) | 24+ | [docs.docker.com/get-docker](https://docs.docker.com/get-docker/) |

### Required for backend development

| Tool | Version | Install |
|------|---------|---------|
| Python | 3.13+ | [python.org](https://www.python.org) or `pyenv` |
| uv | latest | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |

Verify:
```bash
python --version    # Python 3.13.x
uv --version        # uv 0.5.x or newer
```

### Required for frontend development

| Tool | Version | Install |
|------|---------|---------|
| Node.js | 20+ | [nodejs.org](https://nodejs.org) or `nvm` |
| npm | 11+ | Bundled with Node 20 |

Verify:
```bash
node --version    # v20.x.x
npm --version     # 11.x.x
```

### Recommended IDE extensions

**VS Code:**
- Python + Pylance
- Ruff
- ESLint
- Prettier
- Angular Language Service
- Docker
- GitLens

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
ls backend/imdbapi/src/   # should contain imdbapi/ package
ls frontend/src/app/      # should contain Angular components
```

---

## 5. Secrets you need to request

The application requires external API keys that are not in version control. Request these from the relevant team before starting.

| Secret | Who to ask | Where to put it |
|--------|------------|-----------------|
| `QDRANT_ENDPOINT` | RAG / Data Engineering team | `.env` |
| `QDRANT_API_KEY` | RAG / Data Engineering team | `.env` |
| `ANTHROPIC_API_KEY` | Project lead or team lead | `.env` |
| `OPENAI_API_KEY` | Project lead or team lead | `.env` |

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

## 6. Run the full stack with Docker

This is the fastest way to verify everything works end-to-end.

```bash
# Build and start all services (postgres, backend, frontend)
docker compose up --build

# Run in background
docker compose up --build -d

# Stream logs from a specific service
docker compose logs -f backend
```

**Service endpoints:**

| Service | URL | Notes |
|---------|-----|-------|
| Frontend (Angular SPA) | http://localhost:80 | nginx-served |
| Backend (FastAPI) | http://localhost:8000 | |
| Backend interactive docs | http://localhost:8000/docs | Swagger UI (auto-generated) |
| Backend health check | http://localhost:8000/health | Returns `{"status": "ok"}` |
| PostgreSQL | localhost:5432 | `movie_finder` DB, `movie_finder` user |

**Stop and clean up:**
```bash
docker compose down          # stop containers
docker compose down -v       # also delete the postgres volume (wipes DB data)
```

---

## 7. Run the backend for local development

Hot-reload development without Docker build cycles:

```bash
cd backend/

# One-time setup (installs deps, pre-commit hooks, copies .env)
make setup

# Fill in your API keys if you haven't already
$EDITOR .env

# Start local PostgreSQL (Docker container — no full stack needed)
make db-start
# PostgreSQL is now at localhost:5432
# DB: movie_finder, User: movie_finder, Password: devpassword (from make db-start)

# Start the FastAPI dev server with hot-reload
make run-dev
# Backend: http://localhost:8000
# Docs:    http://localhost:8000/docs
```

Common commands:
```bash
make lint         # check code quality (ruff + mypy)
make lint-fix     # auto-fix safe violations
make test         # run all tests
make test-app     # FastAPI app tests only (needs make db-start)
make test-chain   # LangGraph chain tests
make test-imdbapi # IMDb client tests
make db-stop      # stop the local PostgreSQL container
make db-reset     # wipe and restart the DB (useful after schema changes)
make clean        # remove __pycache__, .pytest_cache, .mypy_cache
```

---

## 8. Run the frontend for local development

The Angular dev server proxies `/api` requests to the backend at `localhost:8000`.

```bash
cd frontend/

# Install dependencies
npm ci

# Start dev server with hot-reload
npm start
# Angular app: http://localhost:4200
# API requests: proxied to http://localhost:8000
```

The backend must be running for the app to function. Use `make run-dev` from `backend/` in a separate terminal, or have `docker compose up backend postgres` running.

Common commands:
```bash
npm run typecheck     # TypeScript type check
npm run lint          # ESLint check
npm run lint:fix      # ESLint auto-fix
npm run format        # Prettier format
npm run test          # Vitest watch mode
npm run test:ci       # Single run with coverage report
npm run build         # Production build → dist/
```

---

## 9. Run tests

### Backend tests

```bash
cd backend/

# All tests (chain + imdbapi — no database needed)
make test

# FastAPI app tests (requires PostgreSQL)
make db-start && make test-app

# Individual packages
make test-chain     # LangGraph pipeline
make test-imdbapi   # IMDb API client
make test-rag       # RAG ingestion pipeline
```

Test coverage reports (Cobertura XML + JUnit XML) are generated in the package root and consumed by Jenkins.

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

## 10. Your first contribution

1. **Create a branch** from `main`:
   ```bash
   git checkout main && git pull
   git checkout -b feature/my-change
   ```

2. **Make your changes** in the relevant submodule (or root if cross-cutting)

3. **Run local checks** before committing:
   ```bash
   # Backend
   make lint && make test

   # Frontend
   npm run typecheck && npm run lint && npm run test:ci
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
   Open the PR on GitHub. Jenkins triggers automatically and runs lint + tests.

6. **Wait for CI green** + 1 reviewer approval, then merge.

> If you are working in a nested submodule (e.g. `backend/chain`), commit and push there first, then update the pointer in `backend/`, then update the pointer in the root repo. See [`CONTRIBUTING.md §Submodule workflow`](CONTRIBUTING.md#submodule-workflow).

---

## 11. Role-specific guides

Jump to the guide that matches your role:

| Role | Start here |
|------|-----------|
| Backend / App engineer | [backend/README.md](backend/README.md) → [backend/CONTRIBUTING.md](backend/CONTRIBUTING.md) |
| AI / Chain engineer | [backend/chain/README.md](backend/chain/README.md) → [backend/chain/CONTRIBUTING.md](backend/chain/CONTRIBUTING.md) |
| IMDb API engineer | [backend/imdbapi/README.md](backend/imdbapi/README.md) → [backend/imdbapi/CONTRIBUTING.md](backend/imdbapi/CONTRIBUTING.md) |
| RAG / Data engineer | [backend/rag_ingestion/README.md](backend/rag_ingestion/README.md) → [backend/rag_ingestion/CONTRIBUTING.md](backend/rag_ingestion/CONTRIBUTING.md) |
| Frontend engineer | [frontend/README.md](frontend/README.md) → [frontend/CONTRIBUTING.md](frontend/CONTRIBUTING.md) |
| DevOps / Platform | [docs/devops-setup.md](docs/devops-setup.md) |

---

## 12. Troubleshooting

### Submodule directory is empty after cloning

```bash
git submodule update --init --recursive
```

### `make setup` fails with "uv: command not found"

Install uv:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
# Then restart your shell or source the profile
source ~/.zshrc   # or ~/.bashrc
```

### Backend server fails to start — "could not connect to database"

The PostgreSQL container must be running and healthy before the backend starts.
```bash
make db-stop && make db-start
# Wait for the container to report "database system is ready to accept connections"
make run-dev
```

### Backend server fails to start — "missing required environment variable"

Open `.env` and ensure all required variables are set. Refer to `.env.example` for the full list. Common missing values:
- `APP_SECRET_KEY` — generate with `openssl rand -hex 32`
- `QDRANT_ENDPOINT` / `QDRANT_API_KEY` — request from RAG team
- `ANTHROPIC_API_KEY` — request from project lead

### Frontend shows "Connection refused" or blank chat responses

The backend is not running or not reachable at port 8000. Start it with `make run-dev` or `docker compose up backend postgres`.

### `npm ci` fails with node version errors

Ensure you are using Node 20+:
```bash
node --version   # should be v20.x.x or later
# Use nvm to switch: nvm use 20
```

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
Update the GitHub webhook payload URL to `<new-url>/github-webhook/`. See [`docs/devops-setup.md §7`](docs/devops-setup.md#7-jenkins--expose-via-ngrok).

### Test failures in CI but passing locally

- Ensure you are on the same Python/Node version as the CI agent (Python 3.13 / Node 20)
- Check if a pre-existing `.env` file is leaking into the test run — CI uses a clean environment
- Run `make clean` (backend) or delete `node_modules/` and re-run `npm ci` (frontend)
