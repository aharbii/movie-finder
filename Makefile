# =============================================================================
# movie-finder — root orchestration Makefile
#
# Provides top-level targets that orchestrate the full stack and tool profiles.
# Per-service quality commands (lint, test, typecheck) belong in each
# submodule's own Makefile — this file does not duplicate them.
#
# Usage:
#   make help
#   make <target>
#
# Typical first-time flow:
#   git submodule update --init --recursive   # init submodules first
#   cp .env.example .env && $EDITOR .env      # fill in API keys
#   make up                                   # full stack (postgres + backend + frontend)
#
# Docs and architecture viewer:
#   make structurizr   # C4 architecture viewer  → http://localhost:18080
#   make mkdocs        # MkDocs documentation     → http://localhost:8001
# =============================================================================

.PHONY: help up down logs init structurizr mkdocs ps

.DEFAULT_GOAL := help

COMPOSE ?= docker compose

help:
	@echo ""
	@echo "movie-finder — root stack targets"
	@echo "==================================="
	@echo ""
	@echo "  Stack"
	@echo "    up             Start the full application stack (postgres + backend + frontend)"
	@echo "    down           Stop the full stack and remove containers"
	@echo "    logs           Follow logs for all services"
	@echo "    ps             Show running container status"
	@echo ""
	@echo "  Setup"
	@echo "    init           Create .env from template (no-op if .env already exists)"
	@echo ""
	@echo "  Docs & Architecture"
	@echo "    structurizr    Start Structurizr C4 viewer  → http://localhost:18080"
	@echo "    mkdocs         Start MkDocs documentation   → http://localhost:8001"
	@echo ""
	@echo "  Per-service quality commands (lint, test, check) are in each submodule's Makefile:"
	@echo "    backend/   make lint | make check | make test"
	@echo "    frontend/  make lint | make check | make test"
	@echo "    backend/chain/         make check"
	@echo "    backend/imdbapi/       make check"
	@echo "    backend/rag_ingestion/ make check"
	@echo ""

init:
	@if [ ! -f .env ]; then \
		cp .env.example .env && echo ">>> .env created from .env.example — fill in API keys before running 'make up'"; \
	else \
		echo ">>> .env already exists, skipping copy"; \
	fi

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down --remove-orphans

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

structurizr:
	$(COMPOSE) --profile docs up structurizr

mkdocs:
	$(COMPOSE) --profile mkdocs up mkdocs
