# Session Start — Movie Finder

Run these checks in parallel, then give a prioritised summary. Do not read any source files.

```bash
gh issue list --repo aharbii/movie-finder --state open --limit 30 \
  --json number,title,labels,assignees,milestone
```

```bash
gh pr list --repo aharbii/movie-finder --state open \
  --json number,title,state,labels
```

```bash
git status && git log --oneline -5
```

Then summarise:
- **Critical/High open issues** — number, title, one-line description of the problem
- **Open PRs** — awaiting review, awaiting merge, or blocked
- **Current branch** and any uncommitted changes
- **Recommended next action** — one specific thing to work on

Keep the summary under 20 lines. Do not propose solutions yet.
