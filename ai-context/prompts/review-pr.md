# Review PR Prompt — for Codex CLI / Gemini CLI / Ollama

Post findings as a comment only. Do not submit a GitHub review status (approve/request-changes).
The human decides whether to merge.

---

## Usage

**Codex CLI (most efficient — pipe the diff):**

```bash
gh pr view [PR_NUMBER] --repo [REPO] > /tmp/pr.txt
gh pr diff [PR_NUMBER] --repo [REPO] >> /tmp/pr.txt
cat /tmp/pr.txt | codex "$(cat ai-context/prompts/review-pr.md)"
```

**Gemini CLI:**

```bash
gh pr view [PR_NUMBER] --repo [REPO] > /tmp/pr.txt
gh pr diff [PR_NUMBER] --repo [REPO] >> /tmp/pr.txt
cat /tmp/pr.txt | gemini "$(cat ai-context/prompts/review-pr.md)"
```

**Ollama (local, zero quota):**

```bash
gh pr view [PR_NUMBER] --repo [REPO] > /tmp/pr.txt
gh pr diff [PR_NUMBER] --repo [REPO] >> /tmp/pr.txt
cat /tmp/pr.txt | ollama run qwen2.5-coder:14b "$(cat ai-context/prompts/review-pr.md)"
```

---

## Prompt

You are reviewing the PR shown above.

**Step 1:** Note which issue the PR closes or addresses. If it is marked "Part of #N",
evaluate only what the PR claims to implement, not everything the issue requires.

**Step 2:** Review the diff against these standards.

Blocking findings (must be fixed before merge):

- Python: missing type annotations on public functions, bare `except:`, `print()` left in,
  `type: ignore` without comment, line > 100 chars, blocking I/O in async function, no tests
- TypeScript: `any` used, NgModule introduced, BehaviorSubject for component state,
  `console.log()` in production, strict mode violations
- Both: secrets/API keys in any file, single-letter variable names (outside loops/math),
  no tests for new logic
- Pattern violations: check the CLAUDE.md standards described in the project context
- PR hygiene: AI disclosure missing, issue not linked, Conventional Commits not followed,
  PR template sections left empty

Non-blocking findings (flag but do not block):

- Missing docstrings on public classes/functions
- CHANGELOG.md not updated
- Cross-cutting items for other repos (acceptable if noted in PR body)

**Step 3:** Check cross-cutting completeness.
Based on what changed, flag if any of these were missed and not noted in the PR body:

- New env vars without `.env.example` update
- Changed quality check command without updating `.claude/commands/implement.md`
- New VSCode config without updating CLAUDE.md/GEMINI.md/AGENTS.md tables
- Architecture change without PlantUML `.puml` update noted
- New CI stage without Jenkinsfile/workflow update

**Step 4:** Post the review as a comment.

```bash
gh pr comment [PR_NUMBER] --repo [REPO] \
  --body "[your review]"
```

Structure the comment as:

```
## Review — [date]
Reviewed by: [your tool and model]

### Verdict
PASS — no blocking findings. Human call to merge.
— or —
BLOCKING FINDINGS — must fix before merge.

### Blocking findings
[file:line] — [description and fix]
(empty if none)

### Non-blocking observations
[file:line] — [observation]
(empty if none)

### Cross-cutting gaps
[item not handled and not noted in PR body]
(empty if none)
```

Be specific on every finding. Include file:line, what the rule is, and what the fix is.
Do not soften blocking findings.
