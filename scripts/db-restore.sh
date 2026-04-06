#!/bin/sh
# =============================================================================
# db-restore.sh — Restore a plain-SQL backup into the full-stack database.
#
# Targets the ROOT compose stack (project: movie-finder).
# For backend standalone stack restores use: cd backend/ && make db-restore FILE=...
#
# Usage (via Makefile):
#   make db-restore FILE=backups/db_2026-04-04_12-00-00.sql
#
# Usage (direct):
#   sh scripts/db-restore.sh backups/db_2026-04-04_12-00-00.sql
#
# Safety guarantees:
#   - Never drops or truncates existing tables — data is only ADDED, not replaced.
#   - Schema creation errors ("relation already exists") are ignored so restoring
#     into a database that is already partially migrated always succeeds.
#   - Duplicate rows are skipped silently (INSERT ... ON CONFLICT DO NOTHING in
#     the backup file — requires a backup produced by db-backup.sh).
#   - If the postgres container is not running the script exits with an error
#     before touching the database.
# =============================================================================

set -eu

BACKUP_FILE="${1:-}"

if [ -z "${BACKUP_FILE}" ]; then
    echo "Usage: $0 <backup-file.sql>"
    echo "       make db-restore FILE=backups/db_<timestamp>.sql"
    exit 1
fi

if [ ! -f "${BACKUP_FILE}" ]; then
    echo "Error: backup file not found: ${BACKUP_FILE}"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}/.."

DB_NAME="${DB_NAME:-movie_finder}"
DB_USER="${DB_USER:-movie_finder}"

echo ">>> Restoring '${DB_NAME}' from ${BACKUP_FILE}"
echo ">>> Existing rows will be kept. Duplicate keys will be skipped."
echo ">>> Schema errors (table already exists, etc.) will be ignored."

# ON_ERROR_STOP=0 (psql default) — SQL errors are printed but do not abort
# the restore. This handles "relation already exists" during schema creation
# and lets the data inserts continue even if some schema objects pre-exist.
docker compose --project-directory "${PROJECT_DIR}" exec -T postgres \
    psql \
    --username "${DB_USER}" \
    --dbname "${DB_NAME}" \
    --variable ON_ERROR_STOP=0 \
    --quiet \
    < "${BACKUP_FILE}"

echo ">>> Restore complete."
