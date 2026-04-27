# Changelog — movie-finder

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Added

- Root Docker Compose, Jenkins, and GitHub Actions now pass the backend
  `WITH_PROVIDERS` build arg so chain provider SDKs are installed by selected
  runtime bundle instead of all optional packages
- Root environment template now exposes targeted chain runtime settings for
  classifier, reasoning, embedding, and vector-store providers
- Root `Jenkinsfile` — orchestrates the full release pipeline across all submodules:
  parallel Docker image builds for backend and frontend (pushed to Azure Container
  Registry), automated staging deploy, manual production gate, and production deploy
- Root `.github/workflows/ci.yml` — GitHub Actions mirror of the Jenkins pipeline:
  `resolve-tag` → parallel `build` (backend + frontend Docker) → `deploy-staging`
  (GitHub Environment: `staging`) → `deploy-production` (GitHub Environment: `production`,
  requires reviewer approval); 1:1 parity with the Jenkinsfile flow
- Submodule pointer bumps reflecting all changes in this release cycle across backend,
  frontend, chain, imdbapi, rag_ingestion, and infrastructure

### Changed

- Docker image builds and Azure Container Apps deploys removed from per-repo Jenkinsfiles
  and per-repo GitHub Actions workflows; all build and deploy stages now live exclusively
  in this root pipeline, preventing duplicate builds and centralising release control
- Infrastructure provisioning responsibility moved to `infrastructure/` submodule (Terraform
  IaC) — no more ad-hoc provisioning from per-repo CI scripts

---

## [0.1.0] — 2026-03-22

### Added

- Initial monorepo structure with `backend`, `frontend`, `docs`, and `infrastructure`
  as git submodules
- Root `CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, `.github/copilot-instructions.md` — shared
  AI agent context and workflow instructions
- `.claude/commands/` — slash commands for all registered Claude Code agents
- `ai-context/` — agent-agnostic prompts and issue briefing templates
- Root `docker-compose.yml` — full-stack local dev orchestration
- Root `Makefile` — `mkdocs`, `structurizr`, and submodule helper targets
- `docs/architecture/` — PlantUML diagrams, Structurizr C4 DSL, ADR directory
- `CONTRIBUTING.md`, `ONBOARDING.md` — contributor and new-member guides
