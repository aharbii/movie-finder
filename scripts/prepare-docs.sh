#!/usr/bin/env bash
# =============================================================================
# prepare-docs.sh — populate generated documentation pages from submodules
#
# Run this before `mkdocs serve` or `mkdocs build` to copy submodule README
# files into the docs/ directory structure expected by mkdocs.yml, then
# rewrite repo-relative links so they resolve correctly within MkDocs.
#
# The copied files are listed in docs/.gitignore and are NOT committed.
#
# Usage:
#   ./scripts/prepare-docs.sh           # from repo root
#
# Prerequisites:
#   - git submodule update --init --recursive   (submodules must be present)
#   - pip install -r requirements-docs.txt      (for mkdocs serve/build)
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="$REPO_ROOT/docs"

echo "→ Repo root: $REPO_ROOT"
echo "→ Docs dir:  $DOCS_DIR"
echo ""

# ── Verify submodules are initialised ────────────────────────────────────────
required_files=(
  "$REPO_ROOT/backend/README.md"
  "$REPO_ROOT/frontend/README.md"
  "$REPO_ROOT/backend/chain/README.md"
  "$REPO_ROOT/backend/imdbapi/README.md"
  "$REPO_ROOT/backend/rag_ingestion/README.md"
  "$REPO_ROOT/backend/CONTRIBUTING.md"
  "$REPO_ROOT/frontend/CONTRIBUTING.md"
)

for f in "${required_files[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: Required file not found: $f"
    echo "Run: git submodule update --init --recursive"
    exit 1
  fi
done

# ── Create target directories ─────────────────────────────────────────────────
mkdir -p \
  "$DOCS_DIR/services" \
  "$DOCS_DIR/contributing"

# ── Helper: rewrite repo-relative links ──────────────────────────────────────
# Usage: rewrite_links <file> <sed-expression> [<sed-expression> ...]
#
# Each expression is passed as a separate -e argument so callers don't have
# to worry about quoting rules around semicolons.
rewrite_links() {
  local file="$1"; shift
  local args=()
  for expr in "$@"; do
    args+=(-e "$expr")
  done
  sed -i "${args[@]}" "$file"
}

# ── Copy and fix: onboarding.md ───────────────────────────────────────────────
echo "Copying ONBOARDING.md..."
cp "$REPO_ROOT/ONBOARDING.md" "$DOCS_DIR/onboarding.md"
rewrite_links "$DOCS_DIR/onboarding.md" \
  's|](backend/README\.md)|](services/backend.md)|g' \
  's|](frontend/README\.md)|](services/frontend.md)|g' \
  's|](backend/chain/README\.md)|](services/chain.md)|g' \
  's|](backend/imdbapi/README\.md)|](services/imdbapi.md)|g' \
  's|](backend/rag_ingestion/README\.md)|](services/rag-ingestion.md)|g' \
  's|](CONTRIBUTING\.md)|](contributing/index.md)|g' \
  's|](\.github/PULL_REQUEST_TEMPLATE\.md)|](https://github.com/aharbii/movie-finder/blob/main/.github/PULL_REQUEST_TEMPLATE.md)|g' \
  's|](docs/devops-setup\.md\b|](devops/setup.md|g' \
  's|](docs/devops/setup\.md)|](devops/setup.md)|g' \
  's|](docs/architecture/|](architecture/|g' \
  's|](docs/api/|](api/|g'

# ── Copy and fix: contributing/index.md ──────────────────────────────────────
echo "Copying CONTRIBUTING.md..."
cp "$REPO_ROOT/CONTRIBUTING.md" "$DOCS_DIR/contributing/index.md"
rewrite_links "$DOCS_DIR/contributing/index.md" \
  's|](ONBOARDING\.md)|](../onboarding.md)|g' \
  's|](backend/CONTRIBUTING\.md)|](backend.md)|g' \
  's|](frontend/CONTRIBUTING\.md)|](frontend.md)|g' \
  's|](backend/README\.md)|](../services/backend.md)|g' \
  's|](frontend/README\.md)|](../services/frontend.md)|g' \
  's|](backend/chain/README\.md)|](../services/chain.md)|g' \
  's|](backend/imdbapi/README\.md)|](../services/imdbapi.md)|g' \
  's|](backend/rag_ingestion/README\.md)|](../services/rag-ingestion.md)|g' \
  's|](docs/devops-setup\.md\b|](../devops/setup.md|g' \
  's|](docs/devops/setup\.md)|](../devops/setup.md)|g' \
  's|](docs/architecture/|](../architecture/|g' \
  's|](docs/api/|](../api/|g' \
  's|](\.github/PULL_REQUEST_TEMPLATE\.md)|](https://github.com/aharbii/movie-finder/blob/main/.github/PULL_REQUEST_TEMPLATE.md)|g'

# ── Copy and fix: services/backend.md ────────────────────────────────────────
echo "Copying backend/README.md..."
cp "$REPO_ROOT/backend/README.md" "$DOCS_DIR/services/backend.md"
rewrite_links "$DOCS_DIR/services/backend.md" \
  's|](chain/README\.md)|](chain.md)|g' \
  's|](imdbapi/README\.md)|](imdbapi.md)|g' \
  's|](rag_ingestion/README\.md)|](rag-ingestion.md)|g' \
  's|](CONTRIBUTING\.md)|](../contributing/backend.md)|g' \
  's|](\.\.\/docs\/devops-setup\.md|](../devops/setup.md|g' \
  's|](\.\.\/docs\/devops\/setup\.md)|](../devops/setup.md)|g' \
  's|](docs/devops-setup\.md|](../devops/setup.md|g' \
  's|](docs/devops\/setup\.md)|](../devops/setup.md)|g' \
  's|](\.\.\/docs\/architecture/|](../architecture/|g' \
  's|](docs/architecture/|](../architecture/|g'

# ── Copy and fix: services/frontend.md ───────────────────────────────────────
echo "Copying frontend/README.md..."
cp "$REPO_ROOT/frontend/README.md" "$DOCS_DIR/services/frontend.md"
rewrite_links "$DOCS_DIR/services/frontend.md" \
  's|](\.\.\/CONTRIBUTING\.md)|](../contributing/frontend.md)|g' \
  's|](CONTRIBUTING\.md)|](../contributing/frontend.md)|g' \
  's|](\.\.\/docs\/devops-setup\.md|](../devops/setup.md|g' \
  's|](\.\.\/docs\/devops\/setup\.md)|](../devops/setup.md)|g' \
  's|](\.\.\/docs\/architecture/|](../architecture/|g' \
  's|](\.\.\/README\.md)|](../index.md)|g'

# ── Copy and fix: services/chain.md ──────────────────────────────────────────
echo "Copying backend/chain/README.md..."
cp "$REPO_ROOT/backend/chain/README.md" "$DOCS_DIR/services/chain.md"
rewrite_links "$DOCS_DIR/services/chain.md" \
  's|](CONTRIBUTING\.md)|](../contributing/backend.md)|g' \
  's|](\.\.\/CONTRIBUTING\.md)|](../contributing/backend.md)|g' \
  's|](\.\.\/README\.md)|](backend.md)|g' \
  's|](\.\.\/imdbapi/README\.md)|](imdbapi.md)|g' \
  's|](\.\.\/rag_ingestion/README\.md)|](rag-ingestion.md)|g'

# ── Copy and fix: services/imdbapi.md ────────────────────────────────────────
echo "Copying backend/imdbapi/README.md..."
cp "$REPO_ROOT/backend/imdbapi/README.md" "$DOCS_DIR/services/imdbapi.md"
rewrite_links "$DOCS_DIR/services/imdbapi.md" \
  's|](CONTRIBUTING\.md)|](../contributing/backend.md)|g' \
  's|](\.\.\/CONTRIBUTING\.md)|](../contributing/backend.md)|g' \
  's|](\.\.\/README\.md)|](backend.md)|g' \
  's|](\.\.\/chain/README\.md)|](chain.md)|g' \
  's|](\.\.\/rag_ingestion/README\.md)|](rag-ingestion.md)|g'

# ── Copy and fix: services/rag-ingestion.md ──────────────────────────────────
echo "Copying backend/rag_ingestion/README.md..."
cp "$REPO_ROOT/backend/rag_ingestion/README.md" "$DOCS_DIR/services/rag-ingestion.md"
rewrite_links "$DOCS_DIR/services/rag-ingestion.md" \
  's|](CONTRIBUTING\.md)|](../contributing/backend.md)|g' \
  's|](\.\.\/CONTRIBUTING\.md)|](../contributing/backend.md)|g' \
  's|](\.\.\/README\.md)|](backend.md)|g' \
  's|](\.\.\/chain/README\.md)|](chain.md)|g' \
  's|](\.\.\/imdbapi/README\.md)|](imdbapi.md)|g'

# ── Copy and fix: contributing/backend.md ────────────────────────────────────
echo "Copying backend/CONTRIBUTING.md..."
cp "$REPO_ROOT/backend/CONTRIBUTING.md" "$DOCS_DIR/contributing/backend.md"
rewrite_links "$DOCS_DIR/contributing/backend.md" \
  's|](\.\.\/docs\/devops-setup\.md|](../devops/setup.md|g' \
  's|](\.\.\/docs\/devops\/setup\.md)|](../devops/setup.md)|g' \
  's|](docs\/devops-setup\.md|](../devops/setup.md|g' \
  's|](docs\/devops\/setup\.md)|](../devops/setup.md)|g' \
  's|](\.\.\/README\.md)|](../services/backend.md)|g' \
  's|](chain/README\.md)|](../services/chain.md)|g' \
  's|](imdbapi/README\.md)|](../services/imdbapi.md)|g' \
  's|](rag_ingestion/README\.md)|](../services/rag-ingestion.md)|g'

# ── Copy and fix: contributing/frontend.md ───────────────────────────────────
echo "Copying frontend/CONTRIBUTING.md..."
cp "$REPO_ROOT/frontend/CONTRIBUTING.md" "$DOCS_DIR/contributing/frontend.md"
rewrite_links "$DOCS_DIR/contributing/frontend.md" \
  's|](\.\.\/CONTRIBUTING\.md)|](index.md)|g' \
  's|](CONTRIBUTING\.md)|](index.md)|g' \
  's|](\.\.\/docs\/devops-setup\.md|](../devops/setup.md|g' \
  's|](\.\.\/docs\/devops\/setup\.md)|](../devops/setup.md)|g' \
  's|](docs\/devops-setup\.md|](../devops/setup.md|g' \
  's|](docs\/devops\/setup\.md)|](../devops/setup.md)|g' \
  's|](\.\.\/README\.md)|](../services/frontend.md)|g'

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "Done. Generated pages:"
find "$DOCS_DIR" -name "*.md" \
  \( -path "*/services/*" -o -path "*/contributing/*" -o -name "onboarding.md" \) \
  | sort | sed 's|'"$REPO_ROOT"'/||'

echo ""
echo "Next steps:"
echo "  mkdocs serve    # local preview at http://127.0.0.1:8001"
echo "  mkdocs build    # build static site to site/"
