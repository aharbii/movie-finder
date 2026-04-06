# =============================================================================
# movie-finder — root orchestration Makefile
#
# Scope: full-stack lifecycle (postgres + backend + frontend) and supporting
# tooling (docs, architecture viewers, database utilities).
#
# Per-service quality commands (lint, test, typecheck) live in each submodule's
# own Makefile and are intentionally excluded here.
#
# Usage:
#   make help
#   make <target>
#
# Typical first-time flow:
#   git submodule update --init --recursive   # init submodules first
#   make init                                 # create .env from template
#   make up                                   # start full stack
#
# Development flows (choose one, never run both simultaneously):
#   make up                    # full stack: postgres + backend + frontend
#   cd backend/ && make up     # backend standalone: postgres + backend (dev image, hot-reload)
#   cd frontend/ && make editor-up   # frontend standalone: Angular dev server
#
# Docs and architecture viewers:
#   make mkdocs        # MkDocs documentation     → http://localhost:8001
#   make structurizr   # C4 architecture viewer   → http://localhost:18080
# =============================================================================

.PHONY: help init build up down ci-down logs ps shell \
        db-backup db-restore db-upgrade db-downgrade \
        db-current db-history db-revision \
        plantuml structurizr mkdocs \
        submodules-app submodules-tools submodules-all submodules-sync

.DEFAULT_GOAL := help

COMPOSE      ?= docker compose
BACKEND      ?= backend
DB_REVISION  ?= head
MESSAGE      ?= describe_change
FILE         ?=

# Pass host UID/GID to containers that write to host paths (mkdocs, structurizr).
# This prevents generated files from being created as root on the host.
export UID   := $(shell id -u)
export GID   := $(shell id -g)

help:
	@echo ""
	@echo "movie-finder — root stack targets"
	@echo "==================================="
	@echo ""
	@echo "  Setup"
	@echo "    init           Create .env from template (no-op if .env already exists)"
	@echo "    build          Build (or rebuild) all service images"
	@echo ""
	@echo "  Lifecycle"
	@echo "    up             Start the full stack (postgres + backend + frontend) in the background"
	@echo "    down           Stop the full stack and remove containers"
	@echo "    ci-down        Full CI cleanup: stop containers and remove volumes + local images"
	@echo "    logs           Follow logs for all services  (BACKEND=frontend to tail a specific one)"
	@echo "    ps             Show running container status"
	@echo "    shell          Open a shell in the backend container  (SERVICE=postgres to override)"
	@echo ""
	@echo "  Database"
	@echo "    db-backup      Dump the database to backups/db_<timestamp>.sql"
	@echo "    db-restore     Restore from a backup file  (FILE=backups/db_<timestamp>.sql)"
	@echo "                   Safe to run on an existing DB — never drops or truncates data"
	@echo "    db-upgrade     Run Alembic migrations  (DB_REVISION=head by default)"
	@echo "    db-downgrade   Roll back Alembic migrations  (set DB_REVISION=<target>)"
	@echo "    db-current     Show the current Alembic revision"
	@echo "    db-history     Show Alembic migration history"
	@echo "    db-revision    Create a new empty Alembic revision  (MESSAGE=describe_change)"
	@echo ""
	@echo "  Docs & Architecture"
	@echo "    plantuml       Start PlantUML server (VS Code preview) → http://localhost:18088"
	@echo "    mkdocs         Start MkDocs documentation site         → http://localhost:8001"
	@echo "    structurizr    Start Structurizr C4 viewer              → http://localhost:18080"
	@echo ""
	@echo "  Per-service quality commands (lint, test, check) live in each submodule's Makefile:"
	@echo "    backend/                make lint | make check | make test"
	@echo "    frontend/               make lint | make check | make test"
	@echo "    backend/chain/          make check"
	@echo "    backend/chain/imdbapi/  make check"
	@echo "    rag/                    make check"
	@echo ""
	@echo "  Submodules"
	@echo "    submodules-app     Init app submodules (backend, frontend, docs, infra + children)"
	@echo "                       Tool submodules (rag, mcp/*) are skipped — they use update=none"
	@echo "    submodules-tools   Init all tool submodules (rag, mcp/*) explicitly"
	@echo "    submodules-all     Init everything — app submodules + all tool submodules"
	@echo "    submodules-sync    Sync .gitmodules URLs + set update=none in local .git/config"
	@echo ""

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

init:
	@if [ ! -f .env ]; then \
		cp .env.example .env && echo ">>> .env created from .env.example — fill in API keys before running 'make up'"; \
	else \
		echo ">>> .env already exists, skipping copy"; \
	fi

build:
	$(COMPOSE) build

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down --remove-orphans

ci-down:
	$(COMPOSE) down -v --remove-orphans --rmi local

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

shell:
	$(COMPOSE) exec ${SERVICE:-$(BACKEND)} bash

# ---------------------------------------------------------------------------
# Database
# ---------------------------------------------------------------------------

db-backup:
	@mkdir -p backups
	@sh scripts/db-backup.sh

db-restore:
	@[ -n "$(FILE)" ] || (echo "Usage: make db-restore FILE=backups/db_<timestamp>.sql" && exit 1)
	@sh scripts/db-restore.sh "$(FILE)"

db-upgrade:
	$(COMPOSE) exec $(BACKEND) alembic upgrade $(DB_REVISION)

db-downgrade:
	$(COMPOSE) exec $(BACKEND) alembic downgrade $(DB_REVISION)

db-current:
	$(COMPOSE) exec $(BACKEND) alembic current

db-history:
	$(COMPOSE) exec $(BACKEND) alembic history

db-revision:
	$(COMPOSE) exec $(BACKEND) alembic revision -m "$(MESSAGE)"

# ---------------------------------------------------------------------------
# Docs & Architecture
# ---------------------------------------------------------------------------

plantuml:
	$(COMPOSE) --profile plantuml up -d plantuml

structurizr:
	$(COMPOSE) --profile docs up -d structurizr

mkdocs:
	$(COMPOSE) --profile mkdocs up -d mkdocs

# ---------------------------------------------------------------------------
# Submodules
#
# Policy: submodules that are NOT required to run the app or CI use
# update = none in .gitmodules so they are skipped by 'git submodule update
# --init --recursive'. Developers who need them must init explicitly.
#
# Affected submodules (update = none):
#   rag/                — offline embedding pipeline (data management tool)
#   mcp/qdrant-explorer — Qdrant RAG evaluator (DX tool)
#   mcp/langgraph-inspector — LangGraph state inspector (DX tool)
#   mcp/schema-inspector    — Postgres schema assistant (DX tool)
#   mcp/imdb-sandbox        — IMDb API sandbox (DX tool)
# ---------------------------------------------------------------------------

# Tool submodule list — update as new update=none submodules are added
TOOL_SUBMODULES := rag mcp/qdrant-explorer mcp/langgraph-inspector mcp/schema-inspector mcp/imdb-sandbox

submodules-sync:
	@echo ">>> Syncing submodule URLs from .gitmodules to local .git/config..."
	git submodule sync --recursive
	@echo ">>> Setting update=none in local .git/config for tool submodules..."
	@for path in $(TOOL_SUBMODULES); do \
		name=$$(git config -f .gitmodules --name-only --get-regexp "submodule\..*\.path" "$$path" | sed 's/\.path$$//'); \
		git config "$$name.update" none && echo "  $$name → update = none"; \
	done
	@echo ">>> Done. Run 'git config --list | grep submodule' to verify."

submodules-app:
	@echo ">>> Initialising app submodules (backend, frontend, docs, infrastructure)..."
	@$(MAKE) submodules-sync
	git submodule update --init --recursive
	@echo ">>> App submodules ready. Tool submodules (rag, mcp/*) skipped — use 'make submodules-tools' if needed."

submodules-tools:
	@echo ">>> Initialising tool submodules (rag, mcp/*)..."
	git submodule update --init $(TOOL_SUBMODULES)
	@echo ">>> Tool submodules ready."

submodules-all:
	@echo ">>> Initialising all submodules (app + tools)..."
	@$(MAKE) submodules-app
	@$(MAKE) submodules-tools
	@echo ">>> All submodules ready."
