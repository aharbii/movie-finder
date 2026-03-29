# Create GitHub Issue

Task: $ARGUMENTS

Follow every step in order. Do not skip steps.

---

## Step 1 — Duplicate check

```bash
gh issue list --repo aharbii/movie-finder --state all --limit 50 \
  --json number,title,labels
```

If a matching issue already exists, say so and stop.

---

## Step 2 — Classify the issue type

Pick the best match:

- `bug_report` → bug, regression, unexpected behaviour
- `enhancement` → new feature, improvement
- `technical_debt` → refactor, missing tooling, cleanup, dependency upgrade
- `security` → auth, injection, secrets, OWASP

If none of these fit the task well, note it — a new template may be needed.
New templates can be proposed as part of this PR (file under `.github/ISSUE_TEMPLATE/`).

---

## Step 3 — Read the template and a live example

```bash
cat .github/ISSUE_TEMPLATE/[CHOSEN_TYPE].yml
```

```bash
gh issue list --repo aharbii/movie-finder --label [MATCHING_LABEL] \
  --state all --limit 3 --json number,title,body
gh issue view [MOST_RECENT_NUMBER] --repo aharbii/movie-finder
```

Match the live convention, not the template file. If they diverge, follow the live convention.

---

## Step 4 — Identify which DIRECT children need issues

**movie-finder only creates child issues for its direct submodules:**

| Affected area | Child repo |
|---|---|
| Any backend work (app, chain, imdbapi, rag) | `aharbii/movie-finder-backend` |
| Frontend | `aharbii/movie-finder-frontend` |
| Documentation | `aharbii/movie-finder-docs` |
| Infrastructure / Azure / IaC | `aharbii/movie-finder-infrastructure` |

**Do NOT create issues directly in `movie-finder-chain`, `imdbapi-client`, or `movie-finder-rag`
from this repo.** Those are sub-submodules owned by `movie-finder-backend`. The backend child
issue will manage them internally.

---

## Step 5 — Build the full Agent Briefing for the parent issue

The parent issue tracks the full cross-cutting scope. Its Agent Briefing covers root-level
files only (CLAUDE.md updates, submodule pointer bumps, ci/cd, etc.).

Agent Briefing fields for the parent issue:

- **Workspace to open:** `movie-finder/` (root)
- **Branch to create:** `[type]/[kebab-case-title]`
- **Files to read first:** root-level files relevant to this change
- **Files to create or modify:** list root-level files that change (CI, docker-compose, CLAUDE.md, etc.)
- **Cross-cutting updates:** which agent context files need updating (CLAUDE.md, GEMINI.md, AGENTS.md, .claude/commands/, ai-context/prompts/)
- **Child issues:** one per direct submodule that changes (see Step 4)
- **Do NOT touch:** everything not listed
- **Definition of done:** acceptance criteria

---

## Step 6 — Create the parent issue

```bash
gh issue create \
  --repo aharbii/movie-finder \
  --title "[TYPE]: [concise title]" \
  --label "[label]" \
  --body "[full body following template — include Agent Briefing]"
```

Note the returned issue number as PARENT_NUMBER.

---

## Step 7 — Create child issues for each affected direct submodule

For each child, read `linked_task.yml` in the target repo first:

```bash
gh api repos/[SUBMODULE_REPO]/contents/.github/ISSUE_TEMPLATE/linked_task.yml \
  --jq '.content' | base64 -d
```

Create the child issue:

```bash
gh issue create \
  --repo [SUBMODULE_REPO] \
  --title "[TASK]: [specific title scoped to this repo]" \
  --label "task" \
  --body "[child body: parent URL, repo-specific scope, Agent Briefing for this submodule]"
```

The child Agent Briefing must be scoped to that submodule only. For the backend child:
if the real work is in chain/imdbapi/rag, note it as "further sub-issues will be created in
the backend workspace" — do not list chain/imdbapi/rag files here.

Note the returned issue number as CHILD_NUMBER.

---

## Step 8 — Link child issues to parent using the GitHub Sub-Issues API

```bash
gh api --method POST \
  /repos/aharbii/movie-finder/issues/PARENT_NUMBER/sub_issues \
  -f sub_issue_id=CHILD_NUMBER
```

Repeat for each child. If the API returns an error (feature not available on this plan),
fall back to a comment:

```bash
gh issue comment PARENT_NUMBER --repo aharbii/movie-finder \
  --body "Child issue: [CHILD_URL]"
```

---

## Step 9 — Add all issues to GitHub Project

```bash
gh project list --owner aharbii
```

```bash
gh project item-add [PROJECT_NUMBER] --owner aharbii --url [PARENT_ISSUE_URL]
gh project item-add [PROJECT_NUMBER] --owner aharbii --url [CHILD_ISSUE_URL]
```

---

## Step 10 — Summary

Report:
- Parent issue number and URL
- Child issue(s) number and URL
- Sub-issue links created (API or fallback comment)
- Project item added
- Any cross-cutting concerns that could not be scoped into existing issue templates
  (flag if a new template is warranted)
