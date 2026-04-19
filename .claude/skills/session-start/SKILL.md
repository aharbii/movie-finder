---
name: session-start
description: Start a Movie Finder dev session. Checks open issues, current branch, and recommends next action. Run this at the beginning of every session.
allowed-tools: Bash mcp__github__list_issues
user-invocable: true
---

Check the current work status for Movie Finder.

!`gh issue list --repo aharbii/movie-finder --state open --limit 20`

!`git status && git branch --show-current`

Now:
1. Group the open issues by severity: Critical → High → Medium → Low
2. Show any in-progress branches
3. Recommend the highest-priority next action based on issue list

Do not start implementing anything. Just report status and recommend next action.
