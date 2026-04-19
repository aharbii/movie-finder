---
name: create-issue
description: Create a GitHub issue with proper template, child issues, and Agent Briefing section. Use when starting new work that needs to be tracked.
argument-hint: [issue description]
allowed-tools: Bash Read mcp__github__create_issue mcp__github__list_issues mcp__github__get_issue
context: fork
---

Create a GitHub issue for: $ARGUMENTS

## Step 1 — Check for duplicates

```bash
gh issue list --repo aharbii/movie-finder --state open
```

Also check CLAUDE.md "Known open issues" table. Do not create if it already exists.

## Step 2 — Read the issue template

```bash
gh api repos/aharbii/movie-finder/contents/.github/ISSUE_TEMPLATE --jq '.[].name'
```

Read the matching template and one recent issue of the same type for style reference.

## Step 3 — Create parent issue in `aharbii/movie-finder`

Use the exact template structure and section order. Do not improvise.

## Step 4 — Create child issues only in repos that will change

Each child issue must use that repo's `linked_task.yml` template.

Hierarchy: `movie-finder` → `movie-finder-backend` (→ `movie-finder-chain`, `imdbapi-client`) | `movie-finder-frontend` | `movie-finder-docs` | `movie-finder-infrastructure` | `movie-finder-rag`

## Step 5 — Add Agent Briefing to parent issue

Read `ai-context/issue-agent-briefing-template.md` and fill all sections. The Agent Briefing must list: workspace, branch name, files to read (exact paths), files to modify, cross-cutting updates, and definition of done.
