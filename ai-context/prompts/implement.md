# Implement Prompt — for Codex CLI / Gemini CLI

Use this when asking Codex or Gemini to implement an issue.
Replace `[ISSUE_NUMBER]` and `[REPO]` before running.

---

## How to use with Codex CLI

```bash
# Open the correct submodule directory first, then:
codex "$(cat ai-context/prompts/implement.md | sed 's/\[ISSUE_NUMBER\]/42/g' | sed 's/\[REPO\]/aharbii\/movie-finder-chain/g')"
```

Or copy-paste the prompt below after filling in the values.

---

## Prompt

You are implementing GitHub issue #[ISSUE_NUMBER] in the repo `[REPO]`.

**Step 1:** Fetch the issue.
```
gh issue view [ISSUE_NUMBER] --repo [REPO]
```

**Step 2:** Find the **Agent Briefing** section in the issue body.
- Read ONLY the files listed under "Files to read first"
- Note the "Files to create or modify"
- Note the "Do NOT touch" list
- Your exit condition is the "Definition of done"
- If there is NO Agent Briefing section, stop and say so — do not explore the codebase

**Step 3:** If this is a child issue, also read the parent issue:
```
gh issue view [PARENT_NUMBER] --repo aharbii/movie-finder
```
Implement only what the child issue requires.

**Step 4:** Read only the files listed in the Agent Briefing.

**Step 5:** Create the branch.
```
git checkout main && git pull
git checkout -b [type]/[kebab-case-title]
```

**Step 6:** Implement the acceptance criteria. No more, no less.

Standards:
- Python: type annotations required, line length ≤ 100, no bare `except:`, no `print()`, async all the way, mypy --strict
- TypeScript: no `any`, standalone components, signals not BehaviorSubject, strict mode
- Both: no secrets, tests required, descriptive names

**Step 7:** Run quality checks.
```
# Python: uv run pre-commit run --all-files
# TypeScript: npm run lint && npm test
```

**Step 8:** Commit.
```
git add [only the files you changed]
git commit -m "type(scope): short summary

[why]

Closes #[ISSUE_NUMBER]"
```
Never `git add -A` or `git add .`.

**Step 9:** Open PR.
- Read `.github/PULL_REQUEST_TEMPLATE.md` if it exists
- Link to the issue: `Closes #[ISSUE_NUMBER]`
- Include: "AI-assisted implementation: Codex CLI (gpt-4o)" in the PR body

**Step 10:** For each issue listed in "Related issues to comment on" in the Agent Briefing, post:
```
gh issue comment [RELATED] --repo [RELATED_REPO] \
  --body "PR [REPO]#[PR_NUMBER] may affect this issue: [PR_URL]"
```
