---
name: review-pr
description: Review a pull request as a senior engineer. Checks for blocking issues (security, broken contracts, missing tests) and non-blocking suggestions. Produces a structured verdict.
argument-hint: [pr-number]
allowed-tools: Read Grep Glob Bash mcp__github__get_pull_request mcp__github__get_pull_request_files mcp__github__get_pull_request_comments
context: fork
---

Review pull request #$ARGUMENTS.

!`REPO=$(git remote get-url origin | sed 's/.*github.com[:/]//' | sed 's/\.git//') && gh pr diff $ARGUMENTS --repo $REPO | head -500`

## Review against these criteria

**Blocking issues (must fix before merge):**
- Security vulnerabilities (injection, auth bypass, secret exposure)
- Breaking changes without ADR or migration path
- Missing tests for new behaviour
- Type safety violations (`type: ignore`, `any`, bare `except:`)
- Design pattern violations (Strategy, State machine, Repository, DI, Smart/Dumb components)
- OpenAPI contract changes without Architect sign-off

**Non-blocking (suggest, do not block):**
- Style improvements within standards
- Performance suggestions
- Documentation improvements
- Test coverage gaps for edge cases

## Verdict

State clearly: **APPROVE** / **REQUEST CHANGES** / **COMMENT ONLY**

For REQUEST CHANGES: list each blocking issue with `file:line` and suggested fix.

Disclose: `AI-assisted review: Claude Code (claude-sonnet-4-6)`
