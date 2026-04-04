# AI Context — Movie Finder

Shared reference files used by all AI agents (Claude Code, Codex CLI, Gemini CLI, Copilot).

## What this directory is for

The agent-specific context files (`CLAUDE.md`, `GEMINI.md`, `AGENTS.md`, `copilot-instructions.md`)
contain the full conventions for each tool. This directory contains **supplementary reference material**
that is too large or too phase-specific to include in the main context files:

| File                               | Purpose                                                 | When to read                       |
| ---------------------------------- | ------------------------------------------------------- | ---------------------------------- |
| `issue-agent-briefing-template.md` | Template for the Agent Briefing section in issues       | When creating issues (Phase 2)     |
| `prompts/implement.md`             | Copy-paste prompt for Codex CLI / Gemini implementation | When handing off to Codex/Gemini   |
| `prompts/review-pr.md`             | Copy-paste prompt for Codex CLI / Gemini review         | When asking Codex/Gemini to review |
| `prompts/research.md`              | Copy-paste prompt for Gemini CLI / Ollama research      | When starting Phase 1 exploration  |

## Claude Code users: use slash commands instead

If you're in Claude Code (VSCode extension or CLI), use the `.claude/commands/` slash commands —
they are already pre-loaded and more powerful than copy-pasting from `prompts/`:

| Command                            | Phase        | Usage                              |
| ---------------------------------- | ------------ | ---------------------------------- |
| `/session-start`                   | Status check | Any time — quick project status    |
| `/create-issue [description]`      | Phase 2      | After discussing a task            |
| `/implement [issue-number]`        | Phase 3      | Open submodule workspace, then run |
| `/review-pr [pr-number]`           | Phase 4      | Open submodule workspace, then run |
| `/bump-submodule [submodule-path]` | After merge  | Bump pointer in parent repo        |

## The Agent Briefing pattern

Every GitHub issue should have an **Agent Briefing** section. This is the key optimization:

- It tells the implementing agent _exactly which files to read_ — eliminating codebase exploration
- It is agent-agnostic — Claude Code, Codex, and Gemini all benefit
- Issues without an Agent Briefing should NOT be handed to an agent cold

See `issue-agent-briefing-template.md` for the format.

## Agent assignment by phase

| Phase                  | Primary                        | Secondary     | Avoid           |
| ---------------------- | ------------------------------ | ------------- | --------------- |
| Research / Exploration | Gemini CLI, Ollama             | claude.ai web | Claude Code CLI |
| Issue creation         | Claude Code                    | —             | Codex, Gemini   |
| Implementation         | Claude Code                    | Codex CLI     | Gemini          |
| PR review              | Claude Code (separate session) | Codex CLI     | Gemini          |

**Key rule:** never use Claude Code for research or exploration — it burns quota on tasks that
don't need codebase access. Open the `claude.ai` web interface or use `gemini` / `ollama` instead.
