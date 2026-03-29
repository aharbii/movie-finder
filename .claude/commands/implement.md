# Implement Issue

Implement GitHub issue #$ARGUMENTS.

---

## Step 1 — Detect the current repo

```bash
git remote get-url origin
```

Extract the repo slug (e.g., `aharbii/movie-finder-chain`). Use as REPO for all gh commands.

---

## Step 2 — Read the issue

```bash
gh issue view $ARGUMENTS --repo REPO
```

Find the **Agent Briefing** section. It tells you:
- Workspace to open (confirm you are in the right one)
- Branch to create
- Files to read first
- Files to create or modify
- Cross-cutting updates required in this repo
- Whether this PR fully closes or partially addresses the issue
- Child issues in other repos to note (do not implement those here)
- Definition of done

**If there is no Agent Briefing:** stop and ask the user to add one. Do not explore.

---

## Step 3 — Read the parent issue for context (if this is a child issue)

```bash
gh issue view [PARENT_NUMBER] --repo aharbii/movie-finder
```

Implement only what the child issue requires. Use the parent for context only.

---

## Step 4 — Read only the files listed in the Agent Briefing

Do not read any file not listed. If a listed file imports something you need to understand,
that import is the only additional read allowed.

---

## Step 5 — Create the branch

```bash
git checkout main && git pull
git checkout -b [type]/[kebab-case-title]
```

Label → branch type: `enhancement`→`feature/`, `bug`→`fix/`,
`technical-debt`→`chore/`, `docs`→`docs/`, `security`→`fix/`

---

## Step 6 — Implement

Follow the acceptance criteria. No extra features. No refactoring of unrelated code.

Standards already in CLAUDE.md (loaded). Quick reference:
- Python: type annotations, line ≤ 100, no bare `except:`, no `print()`, async all the way
- TypeScript: no `any`, standalone components, signals not BehaviorSubject, strict mode
- Both: no secrets, tests required, descriptive names

---

## Step 7 — Apply cross-cutting updates in this repo

The Agent Briefing lists which of these apply. Work through every relevant item:

- **CLAUDE.md / GEMINI.md / AGENTS.md** — update if: tech stack changed, new pattern introduced,
  new tool added, VSCode config changed, quality check command changed, workflow step changed
- **.claude/commands/implement.md** — update if the quality check command changed
  (e.g., `uv run pre-commit` replaced by `make check` or `docker compose run`)
- **ai-context/prompts/implement.md** — same trigger as above
- **.vscode/settings.json / tasks.json** — update if interpreter path, task, or launch config changed
- **Dockerfile / docker-compose.yml** — update if new deps, env vars, or service config changed
- **.env.example** — update if new environment variables are introduced
- **Jenkinsfile / .github/workflows/** — update if new CI stage, credential, or env var needed
- **Architecture .puml files** — update if component structure or relations changed
  (in docs/ submodule — note it in PR, handled by docs child issue if one exists)
- **CHANGELOG.md** — always update under [Unreleased]

If a cross-cutting update belongs to a DIFFERENT repo (e.g., docs submodule, frontend),
do NOT implement it here. Instead, note it in the PR body and on the relevant child issue.

---

## Step 8 — Run quality checks

```bash
# Detect stack:
if [ -f pyproject.toml ]; then uv run pre-commit run --all-files; fi
if [ -f package.json ]; then npm run lint && npm test; fi
```

Fix every finding before committing.

---

## Step 9 — Commit

Stage only the files you changed. Never `git add -A` or `git add .`.

```bash
git add [specific files]
git commit -m "type(scope): short summary

[body: explain WHY]

[Closes | Part of | Addresses] #$ARGUMENTS
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

Use **Closes** only if every acceptance criterion is met.
Use **Part of** or **Addresses** if this is a partial/iterative implementation.

---

## Step 10 — Open PR

```bash
cat .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null
```

```bash
gh pr create \
  --repo REPO \
  --title "type(scope): short summary" \
  --body "[PR body following template]"
```

The PR body must:
- Use `Closes #N` or `Part of #N` (match what was in the commit)
- Fill every template section
- Note any cross-cutting items left for other repos/issues
- Disclose: `AI-assisted implementation: Claude Code (claude-sonnet-4-6)`

If this is a **partial iteration**, add a section:

> **Next iteration:** brief description of what remains. See #N.

---

## Step 11 — Cross-cutting notifications

For each child issue noted in the Agent Briefing (in other repos), comment:

```bash
gh issue comment [CHILD_ISSUE_NUMBER] --repo [CHILD_REPO] \
  --body "Parent PR opened: [PARENT_PR_URL]

This PR completes the [REPO] portion. Work in this repo is now unblocked.
Remaining cross-cutting items: [list or 'none']"
```

Comment on the original issue:

```bash
gh issue comment $ARGUMENTS --repo REPO \
  --body "Implemented in PR #[PR_NUMBER]: [PR_URL]

[One sentence: what was done and what (if anything) remains]"
```

---

## Step 12 — Report back

Tell the user:
- PR URL and number
- Whether the issue is fully closed or partial (and what remains)
- Cross-cutting items implemented in this PR
- Cross-cutting items deferred to other repos/issues (with links)
- Any blockers or questions found during implementation
