# Bump Submodule Pointer

Bump the submodule pointer for: $ARGUMENTS

---

## Step 1 — Verify the submodule has merged to main

```bash
cd $ARGUMENTS
git log --oneline -3
git branch -r | grep main
cd ..
```

The latest commit on `origin/main` in the submodule must be the merged work you expect.
If it's not, stop and tell the user.

---

## Step 2 — Check the current pointer

```bash
git submodule status $ARGUMENTS
```

Note the current SHA.

---

## Step 3 — Update to latest

```bash
git submodule update --remote $ARGUMENTS
git submodule status $ARGUMENTS
```

Confirm the SHA changed.

---

## Step 4 — Stage and commit

```bash
git add $ARGUMENTS
git commit -m "$(cat <<'EOF'
chore($ARGUMENTS): bump to latest main

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

Never `git add -A`.

---

## Step 5 — Open PR (if on a feature branch)

If not already on a `chore/` branch, create one:
```bash
git checkout -b chore/bump-$ARGUMENTS-pointer
```

```bash
gh pr create \
  --repo aharbii/movie-finder \
  --title "chore($ARGUMENTS): bump submodule pointer to latest main" \
  --body "$(cat <<'EOF'
## What
Bumps the `$ARGUMENTS` submodule pointer to the latest `main` commit.

## Why
Picks up changes merged in [SUBMODULE_PR_URL].

## Closes
[PARENT_ISSUE_URL if applicable]

---
> AI-assisted: Claude Code (claude-sonnet-4-6)
EOF
)"
```

---

## Step 6 — Comment on related issues

If this bump completes a tracked issue, comment:
```bash
gh issue comment [ISSUE_NUMBER] --repo aharbii/movie-finder \
  --body "Submodule pointer bumped in PR #[PR_NUMBER]. [PR_URL]"
```
