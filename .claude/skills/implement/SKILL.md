---
name: implement
description: Implement a GitHub issue. Fetches the issue, reads Agent Briefing, creates branch, implements, runs quality checks, opens PR.
argument-hint: [issue-number]
allowed-tools: Read Grep Glob Bash Edit Write
context: fork
---

Implement GitHub issue #$ARGUMENTS.

!`git remote get-url origin`

## Step 1 — Read the issue

```bash
gh issue view $ARGUMENTS --repo $(git remote get-url origin | sed 's/.*github.com[:/]//' | sed 's/\.git//')
```

Find the **Agent Briefing** section. It tells you: workspace to open, branch to create, files to read first, files to modify, cross-cutting updates required, and definition of done.

**If there is no Agent Briefing: stop and ask the user to add one. Do not explore speculatively.**

## Step 2 — Read only the files listed in the Agent Briefing

Do not read any file not listed. If a listed file imports something critical, that import is the only additional read allowed.

## Step 3 — Create the branch

```bash
git checkout main && git pull
git checkout -b [type]/[kebab-case-title]
```

Branch prefix from label: `enhancement`→`feature/`, `bug`→`fix/`, `technical-debt`→`chore/`, `docs`→`docs/`, `security`→`fix/`

## Step 4 — Implement

Follow acceptance criteria exactly. No extra features. No refactoring of unrelated code.

Standards:
- Python: type annotations, line ≤ 100, no bare `except:`, no `print()`, async all the way, Google docstrings on public APIs
- TypeScript: no `any`, standalone components, signals not BehaviorSubject, strict mode
- Both: no secrets in code, tests required, descriptive names

## Step 5 — Quality checks

```bash
make check
```

Fix every finding before committing.

## Step 6 — Commit and PR

```bash
git add [specific files — never git add -A]
git commit -m "type(scope): summary

Closes #$ARGUMENTS
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

```bash
gh pr create --repo REPO --title "..." --body "..."
```

PR body must: use `Closes #N` or `Part of #N`, fill every template section, disclose `AI-assisted implementation: Claude Code (claude-sonnet-4-6)`.

## Step 7 — Notify child issues

For each child issue noted in the Agent Briefing, comment that parent PR is open and work is unblocked.
