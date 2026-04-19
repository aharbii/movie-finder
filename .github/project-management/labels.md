# Movie Finder — GitHub Label Taxonomy

Apply these labels across all repos via the PM persona's `/pm apply-labels` workflow.
The cross-repo set goes on every repo. Per-repo additions are additive.

---

## Cross-repo standard (apply to all 8+ repos)

### Type labels
| Label | Color | Description |
|-------|-------|-------------|
| `type:feat` | `#0075ca` | New feature or capability |
| `type:bug` | `#d73a4a` | Something isn't working |
| `type:chore` | `#e4e669` | Maintenance, deps, tooling |
| `type:docs` | `#0075ca` | Documentation only |
| `type:security` | `#b60205` | Security vulnerability or hardening |
| `type:refactor` | `#cfd3d7` | Code change without behaviour change |
| `type:test` | `#0e8a16` | Test-only changes |
| `type:perf` | `#fbca04` | Performance improvement |

### Priority labels
| Label | Color | Description |
|-------|-------|-------------|
| `p0:critical` | `#b60205` | Blocks production or causes data loss |
| `p1:high` | `#d93f0b` | Significant impact, needs this sprint |
| `p2:medium` | `#fbca04` | Important but not urgent |
| `p3:low` | `#e4e669` | Nice to have |

### Status labels
| Label | Color | Description |
|-------|-------|-------------|
| `status:needs-briefing` | `#f9d0c4` | Issue needs Agent Briefing before implementation |
| `status:blocked` | `#e11d48` | Blocked by another issue or decision |
| `status:in-progress` | `#0075ca` | Currently being worked on |
| `status:needs-review` | `#fbca04` | PR open, awaiting review |
| `status:needs-adr` | `#d876e3` | Requires an Architecture Decision Record first |

### Scope labels
| Label | Color | Description |
|-------|-------|-------------|
| `scope:cross-repo` | `#5319e7` | Change spans multiple submodule repos |
| `scope:epic` | `#5319e7` | Parent issue tracking multiple child issues |
| `scope:breaking-change` | `#b60205` | Breaking API or contract change |

---

## Per-repo additions

### aharbii/movie-finder (tracker repo only)
| Label | Description |
|-------|-------------|
| `waiting-on-child` | Parent issue waiting for child issue to complete |

### aharbii/movie-finder-backend
| Label | Description |
|-------|-------------|
| `area:auth` | JWT, session management, token lifecycle |
| `area:database` | PostgreSQL, asyncpg, migrations |
| `area:sse-streaming` | Server-Sent Events, streaming routes |
| `area:api-contract` | OpenAPI, route signatures, response models |
| `area:middleware` | CORS, error handling, request processing |

### aharbii/movie-finder-chain
| Label | Description |
|-------|-------------|
| `area:ai-pipeline` | LangGraph graph structure and flow |
| `area:embedding` | OpenAI embedding calls, vector dimensions |
| `area:rag` | Qdrant retrieval, search quality |
| `area:llm-prompt` | Prompt templates, model parameters |
| `area:langgraph-node` | Individual node implementation |
| `area:state-machine` | State transitions, routing logic |

### aharbii/movie-finder-frontend
| Label | Description |
|-------|-------------|
| `area:angular` | Angular-specific (components, services, modules) |
| `area:sse-client` | EventSource, SSE stream handling |
| `area:ui-ux` | User interface and experience |
| `area:a11y` | Accessibility |
| `area:signals` | Angular Signals reactive state |

### aharbii/movie-finder-infrastructure
| Label | Description |
|-------|-------------|
| `area:azure` | Azure resources, topology |
| `area:ci-cd` | Jenkins, GitHub Actions, pipelines |
| `area:docker` | Dockerfile, docker-compose |
| `area:iac` | Terraform, Bicep |
| `area:secrets` | Key Vault, credentials management |

### aharbii/movie-finder-docs
| Label | Description |
|-------|-------------|
| `area:architecture` | Architecture diagrams, C4 model |
| `area:adr` | Architecture Decision Records |
| `area:diagrams` | PlantUML files |
| `area:onboarding` | CONTRIBUTING.md, ONBOARDING.md |

### aharbii/imdbapi-client
| Label | Description |
|-------|-------------|
| `area:retry-policy` | Retry/backoff strategy |
| `area:http-client` | httpx client configuration |
| `area:domain-model` | Movie domain type mapping |

### aharbii/movie-finder-rag
| Label | Description |
|-------|-------------|
| `area:ingestion` | Data pipeline, Kaggle → Qdrant |
| `area:embedding` | OpenAI embedding calls |
| `area:qdrant` | Qdrant write operations, collection management |
| `area:batch-processing` | Batch size, concurrency, rate limiting |

### MCP repos (all four)
| Label | Description |
|-------|-------------|
| `area:mcp-tool` | New or changed MCP tool definition |
| `area:dx-tooling` | Developer experience improvements |
| `area:planned` | Planned but not yet implemented |

---

## Usage in PM workflow

```bash
# Fetch by priority
gh issue list --repo REPO --state open --label "p0:critical"
gh issue list --repo REPO --state open --label "p1:high"

# Fetch by type
gh issue list --repo REPO --state open --label "type:security"
gh issue list --repo REPO --state open --label "type:bug"

# Fetch by status
gh issue list --repo REPO --state open --label "status:needs-briefing"
gh issue list --repo REPO --state open --label "status:blocked"

# Combined (GitHub supports multiple labels as AND)
gh issue list --repo REPO --state open --label "p0:critical,status:needs-briefing"
```

## Apply labels to all repos

Create a PM issue in `aharbii/movie-finder` (label: `type:chore`, `p2:medium`, `scope:cross-repo`) to apply these labels using:
```bash
gh label create "p0:critical" --color "b60205" --description "Blocks production or causes data loss" --repo REPO
```
