# Agent Briefing Template

Copy this section into every GitHub issue before it is ready for implementation.
An issue without this section must NOT be handed to an agent cold.

Check the **Ready for implementation** box only when all fields are filled.

---

## Agent Briefing

> This section is read by AI agents. Be precise — vague entries cause speculative
> exploration that burns quota.

**Workspace to open:** `[submodule-path]/`

> Example: `backend/chain/` or `frontend/` — open this as your VSCode workspace, not root.

**Branch to create:** `[type]/[kebab-case-title]`

> Example: `fix/imdb-retry-base-delay`

**Iteration scope:** [Full close | Partial — iteration N of M]

> Full close: the PR should use `Closes #N`. Partial: use `Part of #N`.
> If partial, describe what this iteration covers and what the next one will handle.

---

### Files to read first

List every file needed for context. One line each with a reason.

- `path/to/file.py` — [e.g., "defines the class being modified"]
- `path/to/config.py` — [e.g., "shows how settings are loaded"]

---

### Files to create or modify

Be explicit. "Modify" = already exists. "Create" = new file.

- `path/to/existing.py` — modify: [what changes, e.g., "add retry_budget param"]
- `path/to/new_test.py` — create: [what, e.g., "unit tests for retry logic"]

---

### Cross-cutting updates required in this repo

Only list items that change in THIS submodule's repo. Items for other repos go in child issues.

- [ ] `CLAUDE.md` — update if: tech stack, pattern, tool, VSCode config, or workflow changed
- [ ] `GEMINI.md` / `AGENTS.md` — mirror the same change
- [ ] `.claude/commands/implement.md` + `ai-context/prompts/implement.md` — update if quality check command changed (e.g., `uv run pre-commit` → `make check`)
- [ ] `.vscode/settings.json` / `tasks.json` / `launch.json` — update if interpreter path, task, or launch config changed
- [ ] `Dockerfile` / `docker-compose.yml` — update if new deps, env vars, or service config changed
- [ ] `.env.example` — update if new environment variables introduced
- [ ] `Jenkinsfile` / `.github/workflows/` — update if new CI stage, credential, or env var needed
- [ ] `CHANGELOG.md` — always update under [Unreleased]
- [ ] Architecture `.puml` files in `docs/` — note for docs child issue if component structure changed
- [ ] `docs/architecture/workspace.dsl` — note for docs child issue if C4 relations changed

Delete items that do not apply. Leave the list only with what actually changes.

---

### Child issues in other repos

Work that belongs to other repos. Do not implement these here — just link them.

- `aharbii/movie-finder-docs#XX` — [one sentence: what docs change is needed]
- `aharbii/movie-finder-frontend#XX` — [one sentence: what frontend change is needed]
  (delete if none)

---

### Do NOT touch

- `path/to/unrelated.py` — [why out of scope]
- Any file not listed above

---

### Quality checks to run before committing

Use the command that applies to this submodule:

```bash
# Python submodules (backend, chain, imdbapi, rag_ingestion):
uv run pre-commit run --all-files

# Frontend:
npm run lint && npm test

# Docs:
./scripts/prepare-docs.sh && mkdocs build --strict
```

---

### Definition of done

Copy the acceptance criteria from the issue body verbatim. The agent treats this as its exit condition.

- [ ] [criterion 1]
- [ ] [criterion 2]

---

**Ready for implementation:** [ ]

> Check this only when all fields above are filled. Issues without this checked must not be handed to an agent.
