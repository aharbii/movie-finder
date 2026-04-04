# Review PR

Review GitHub PR #$ARGUMENTS.

You are a strict reviewer. Post findings as comments only — do not submit a GitHub review
status (approve/request-changes). The human decides whether to merge or request changes.

---

## Step 1 — Detect the current repo

```bash
git remote get-url origin
```

Use the repo slug as REPO.

---

## Step 2 — Read the PR

```bash
gh pr view $ARGUMENTS --repo REPO
```

Note: which issue it closes or addresses, AI disclosure (required — flag if missing),
whether this is a partial iteration or full close.

---

## Step 3 — Read the linked issue

```bash
gh issue view [ISSUE_NUMBER] --repo [ISSUE_REPO]
```

The acceptance criteria in the issue is the primary review standard.
If the PR is marked "Part of #N", only evaluate what it claims to implement — not everything.

---

## Step 4 — Get the diff

```bash
gh pr diff $ARGUMENTS --repo REPO
```

---

## Step 5 — Review against standards

**Blocking — must be fixed before merge:**

Python:

- Missing type annotations on any public function or method
- Bare `except:` — must catch specific exception types
- `print()` or any debug output left in production code
- `type: ignore` without an inline comment explaining why
- Line length > 100 chars
- Blocking I/O called inside an async function
- Mutable default arguments
- Missing tests for new logic

TypeScript:

- `any` used (must use `unknown` + narrowing)
- NgModule introduced
- BehaviorSubject used for component state (must use Signals)
- `console.log()` in production code
- Strict mode violations

Both:

- Secrets or API keys in any file
- Single-letter variable names (outside loop counters and math)
- Pattern violations (Repository not used for DB, Depends() not used for DI, etc.)
- PR template sections left empty or with placeholder text
- AI disclosure missing from PR body
- Issue not linked (`Closes #N` or `Part of #N` missing)

**Non-blocking — flag but do not block merge:**

- Docstrings missing on public classes/functions (note, don't block)
- CHANGELOG.md not updated
- Minor style issues already caught by linters
- Cross-cutting items left for other repos (acceptable if noted in PR body)

---

## Step 6 — Check cross-cutting completeness

Based on what changed, verify whether the PR author considered:

- New env vars → `.env.example` updated?
- New/changed quality check command → `.claude/commands/implement.md` updated?
- New VSCode config → `CLAUDE.md`/`GEMINI.md`/`AGENTS.md` tables updated?
- New architecture pattern → PlantUML `.puml` noted for docs update?
- New CI stage → Jenkinsfile/workflow + `docs/devops-setup.md` updated?
- Cross-cutting to other repos → noted in PR body with issue links?

---

## Step 7 — Post findings as a comment (not a review status)

```bash
gh pr comment $ARGUMENTS --repo REPO \
  --body "[review body]"
```

Structure the comment body as:

```
## Review — [date]
Reviewed by: [tool and model, e.g., Claude Code (claude-sonnet-4-6)]

### Verdict
PASS — no blocking findings. Human call to merge.
— or —
BLOCKING FINDINGS — must fix before merge.

### Blocking findings
[file:line] — [description of the issue and what the fix should be]
[file:line] — ...
(Leave this section empty if none)

### Non-blocking observations
[file:line] — [observation]
(Leave this section empty if none)

### Cross-cutting gaps
[description of any cross-cutting item not handled and not noted in PR body]
(Leave this section empty if none)
```

Be specific on every finding: file path, line number or range, what the rule is, what the fix is.
Do not soften blocking findings. If it blocks, it blocks.
