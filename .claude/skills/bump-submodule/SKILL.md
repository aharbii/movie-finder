---
name: bump-submodule
description: Bump a submodule pointer after its PR merges. Verifies the PR is merged, pulls latest main, stages the pointer, commits, and opens a PR in the parent repo.
argument-hint: [submodule-path]
allowed-tools: Bash mcp__github__list_pull_requests mcp__github__create_pull_request
---

Bump the submodule pointer for: $ARGUMENTS

!`git remote get-url origin`

## Steps

```bash
# 1. Pull latest in the submodule
cd $ARGUMENTS && git checkout main && git pull && cd ..

# 2. Stage only the submodule pointer — never git add -A
git add $ARGUMENTS

# 3. Commit
git commit -m "chore($ARGUMENTS): bump to latest main"
```

## Then open a PR

```bash
gh pr create \
  --repo aharbii/movie-finder \
  --title "chore($ARGUMENTS): bump to latest main" \
  --body "Bumps $ARGUMENTS submodule pointer after [PR URL] merged.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

**Note:** If the parent branch has other open work, check whether to stack or open a separate PR first.
