# Contributing Guidelines

Thank you for contributing to the Movie Finder AI project. To ensure a scalable enterprise development lifecycle mapping to industry compliance systems, please strictly adhere to the following logic standards mapping internal team workflows.

## 1. Submodules Architecture Boundaries
This central root repository natively binds diverse logical domains (e.g. `backend`, `frontend`, `infrastructure`, `docs`) via git submodules bridging isolated environments securely.
- Always run `git submodule update --init --recursive` when cloning fresh or swapping active branches.
- When committing boundary changes (e.g., editing `backend` schemas and correspondingly adjusting `frontend` structures), be mindful you are tracking modifications in isolated Git repositories. **Commit logic within the specific domain folder first**, then seamlessly commit the newly linked submodule reference hash iteratively within this root repository.

## 2. CI/CD Code Style Guides
### Backend (Python 3.11+)
- We deploy `ruff` for incredibly fast logical linting and standardizing formatting templates.
- We utilize `mypy` for strict static type integrations mapping definitions properly.
- Run validations sequentially prior to PR requests:
  ```bash
  cd backend
  uv run ruff check .
  uv run ruff format .
  uv run mypy .
  ```
- **Docstrings Formatting**: Ensure ALL structural algorithms, generic functions, classes, and complex runtime segments strictly conform to standard Python Docstrings. **Provide explicit Type annotations for all inputs and returned instances.**

### Frontend (Angular 16+ / TypeScript)
- Check components sequentially adhering uniformly to `eslint` and `prettier` logic definitions explicitly outlined in `.editorconfig`.
- Build logic strictly encompassing Angular Standalone Component Patterns leveraging modern dependency injection injections natively.

## 3. Pre-Commit Hooks
Before initiating Git pushes upstream, establish our standard Jenkins validation triggers natively on your machine:
```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

## 4. Branch Paradigms & Conventions
- Expand Feature branches safely prefixed natively dictating exact scopes: `feature/backend/jwt-auth`, `fix/frontend/chat-ui`, `chore/docs/c4-model`.
- **Conventional Commits Matrix**: Commit descriptions intrinsically MUST follow the [Conventional Commits pattern](https://www.conventionalcommits.org/); (e.g., `feat(api): expand qdrant searching layers`, `fix(ui): patch markdown regex rendering errors`).

## 5. Security & Testing Requirements
All Pull Requests require passing regression matrices.
- Backend Verification: `uv run pytest tests/`
- Frontend Scaffolding checks: `npm run test`
Do not merge or integrate PR branches without validating exhaustive test-coverage metrics executed transparently inside Jenkins CI servers automatically analyzing your commits!

## 6. Project Lifecycle & Development Stages

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
