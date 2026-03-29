# Research Prompt — for Gemini CLI / Ollama / claude.ai web

Use this for Phase 1 exploration and technology research.
This phase has ZERO codebase access — it's pure knowledge retrieval.

---

## When to use this

- Exploring a technology before deciding to adopt it
- Understanding how an open issue is typically solved in the ecosystem
- Comparing library options
- Learning about a pattern before implementing it
- Getting up to speed on a topic before a planning session

**Do NOT open Claude Code for research.** Use:
- `gemini` — web search + long-context reading (Google AI Pro)
- `ollama run qwen2.5-coder:14b` — local, zero quota, good for code discussion
- `claude.ai` web — separate quota pool from Claude Code CLI/extension

---

## Project context to paste at the start of a research session

Paste this when starting a new research conversation so the agent understands the stack:

```
I'm working on Movie Finder — a full-stack AI app where users describe a half-remembered film
and the system finds it via semantic search, enriches it with IMDb metadata, and answers
follow-up questions via streamed chat.

Stack:
- Frontend: Angular 21, TypeScript 5.9, SSE (EventSource)
- Backend: Python 3.13, FastAPI 0.115+, asyncpg
- AI pipeline: LangGraph 0.2+, LangChain 0.3+, Claude Haiku (classify), Claude Sonnet (reason/Q&A)
- Embeddings: OpenAI text-embedding-3-large (3072-dim)
- Vector store: Qdrant Cloud (always external)
- Database: PostgreSQL 16 (raw DDL, no Alembic yet)
- Hosting: Azure Container Apps + ACR, Jenkins CI/CD

I want to explore: [YOUR TOPIC HERE]

Please search for current best practices, relevant libraries, and any notable tradeoffs.
I'm not implementing anything yet — just building understanding.
```

---

## How to use with Gemini CLI

```bash
gemini "$(cat ai-context/prompts/research.md)"
# Or just start a session and paste the context block above
```

## How to use with Ollama

```bash
ollama run qwen2.5-coder:14b
# Then paste the context block above
```
