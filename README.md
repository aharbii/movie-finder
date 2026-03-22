# Movie Finder AI Application

An enterprise-grade Full-Stack AI Movie Finder built for PwC's AI Engineer Technical Assessment. The application leverages a LangGraph ReACT Agent to search for movies based on plot descriptions using Qdrant vector embeddings, and fetches real-time posters and extensive metadata via the IMDBApi.

## Architecture & Tech Stack
- **Backend**: Python 3.11+, FastAPI, PostgreSQL, Asyncpg, Alembic, LangChain, Qdrant Client.
- **Frontend**: Angular 16+ (Standalone), TailwindCSS (v3), RxJS.
- **Infrastructure**: Docker Compose, Jenkins CI/CD, Git Submodules, GitHub Actions for Mkdocs.
- **Observability**: LangSmith Telemetry for LLM Agents.

## Prerequisites
To run this project locally, ensure you have the following installed:
- [Docker & Docker Compose](https://docs.docker.com/get-docker/)
- [Git](https://git-scm.com/)
- [uv](https://github.com/astral-sh/uv) (for Python lightning-fast dependency management)
- [Node.js v18+](https://nodejs.org/) and `npm` (for Angular local development)

## Local Environment Setup
Before starting the application, you need to configure your environment variables.
1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
2. Fill in the required API keys in `.env`:
   - `OPENAI_API_KEY`: Your OpenAI API key (or leave as `sk-testkey` for mocked, cost-free local testing).
   - `KAGGLE_USERNAME` & `KAGGLE_KEY`: Required only for RAG data ingestion (fetch Wikipedia Movie Plots).

## Running the Application 🐳
The easiest way to run the entire stack (Postgres, Qdrant, FastAPI backend, Angular frontend) is via Docker Compose:

```bash
# 1. Ensure submodules are loaded natively
git submodule update --init --recursive

# 2. Build and start ALL services natively
cd infrastructure
docker-compose up -d --build
```
Once deployed, the instances will map locally:
- **Frontend UI Application**: http://localhost:4200 (or mapped UI port depending on Compose mapping)
- **Backend API Docs (Swagger interface)**: http://localhost:8000/docs
- **Qdrant DB Vector Dashboard**: http://localhost:6333/dashboard

## Data Ingestion & RAG Setup
The Qdrant Vector database is initially empty. To populate it with the Kaggle Wikipedia Movie Plots dataset:
```bash
# Provide Kaggle credentials in the .env prior to executing
cd backend

# Sync environments for the specific RAG pipelines group
uv sync --group rag

# Trigger Data Analysis and subsequent Pipeline Population
uv run python rag_ingestion/ingest.py
```
*Note*: This process programmatically filters for "American" & "British" cinematic volumes, chunks structural attributes natively, and embeds the plotting vectors utilizing OpenAI's `text-embedding-3-small` algorithms safely mapped to localized models.

## Detailed Local Development Scripts
If you prefer expanding the API and UI sequentially via CLI commands directly without Dockerized wrappers:

### Backend FastApi Engine
```bash
cd backend
uv sync
uv run alembic upgrade head
uv run uvicorn app.main:app --reload --port 8000
```

### Frontend Angular Structure
```bash
cd frontend
npm install
npm install -D tailwindcss@3 postcss autoprefixer

# Run locally 
npm run start
```

Please review the `CONTRIBUTING.md` standards prior to modifying the architecture!

## Project Lifecycle & Development Stages

### 1. Contributing and Developing Locally the Architecture
The root infrastructure provides a fully containerized Hot-Reloading Development Environment utilizing `infrastructure/docker-compose.dev.yml`, avoiding native installations entirely!
- **Architectural Structuring (C4 & UML)**: We deploy **Structurizr** utilizing Docker out-of-the-box to dynamically render high-level C4 Models mapping your `.dsl` architecture definitions. For intricate low-level sequence and class modeling pipelines, we standardize definitively on **StarUML**.
- **Containerized Dev Loop**: Executing `docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d` within `infrastructure` natively binds your local `./backend` and `./frontend` mapping directories straight into the active containers! Code edits synchronously trigger backend `uvicorn --reload` and frontend HMR logic universally seamlessly.
- **Microservices Routing**: Postgres (`5433:5432`), Qdrant (`6333`), and the Structurizr dashboard (`8081`) logically isolate networking natively mapping seamlessly against backend structures.

### 2. Contributing and Developing Locally the RAG Ingestion
The RAG ingestion pipeline fetches Kaggle's Wikipedia Movie Plots, filters dataset parameters, and populates Qdrant.
- **Setup**: `cd backend && uv sync --group rag`
- **Execution**: `uv run python rag_ingestion/ingest.py`
- **Local AI Context**: You avoid OpenAI API charges entirely natively by providing an `OLLAMA_BASE_URL` in your `.env`. The ingestion pipeline utilizes isolated `nomic-embed-text` dimensions natively.

### 3. Contributing and Developing Locally the Backend API, and AI Agent
The FastAPI backend serves the core Retrieval Agent powered natively by LangChain abstractions logically querying Qdrant parameters.
- **Setup Engine**: Navigate to `backend/` and execute `uv sync`.
- **Database Migrations**: Bind schema layouts flawlessly natively via `uv run alembic upgrade head`.
- **Execution**: `uv run uvicorn app.main:app --reload --port 8000`
- **AI Agent Mocking**: Using the `.env` placeholder natively completely avoids hallucinated testing parameters. Qdrant is mock-searched authentically locally via open-source Ollama embeddings natively.

### 4. Contributing and Developing Locally the Frontend
The Angular 16+ application handles user workflows natively utilizing extensive RxJS pipelines embedded inside a standalone Tailwind CSS architecture framework.
- **Setup Pipeline**: `cd frontend && npm install`
- **Development Proxy**: Execute `npm run start` natively to spin up local Angular configurations logically routing towards your backend environments smoothly!

### 5. The RAG Manual CI
A manual CI Job is configured natively to synchronize embedding updates structurally mapping data changes via Automated Pipelines triggering `rag_ingestion/ingest.py`. Developers can trigger this manual workflow intuitively natively from source control branches prior to structural production releases!

### 6. The Testing CI Job
All native architectural structural PRs strictly enforce logically passing sequential regression paradigms. CI pipelines execute natively:
- **Backend Matrices**: `uv run pytest tests/` mapping code-coverage flawlessly.
- **Frontend Scaffolding**: `npm run test` ensuring isolated DOM logic constraints structurally pass sequentially.

### 7. Production
Dockerfiles actively structure logically minimal containerized distributions tracking optimal builds natively:
- **Backend Server**: Leverages a `production` multi-stage build securely locking Python dependencies utilizing system-level bindings statically executing as a non-root `appuser`.
- **Frontend App**: Deploys multi-stage environments natively compiling Javascript logic effectively deploying artifacts securely within extreme lightweight Nginx Alpine proxies reliably mapping internet routes statically!
