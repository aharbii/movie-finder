#!/bin/sh
# =============================================================================
# db-backup.sh — Dump the full-stack PostgreSQL database to a plain-SQL file.
#
# Targets the ROOT compose stack (project: movie-finder).
# For backend standalone stack backups use: cd backend/ && make db-backup
#
# Usage (via Makefile):
#   make db-backup
#
# Usage (direct):
#   sh scripts/db-backup.sh
#
# Output: backups/db_YYYY-MM-DD_HH-MM-SS.sql (created automatically)
#
# The dump uses --inserts --on-conflict-do-nothing so the file can be safely
# restored into an existing database: new rows are inserted, duplicate primary
# keys are silently skipped, and schema errors do not abort the restore.
# =============================================================================

set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}/.."
BACKUP_DIR="${PROJECT_DIR}/backups"
TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
BACKUP_FILE="${BACKUP_DIR}/db_${TIMESTAMP}.sql"

DB_NAME="${DB_NAME:-movie_finder}"
DB_USER="${DB_USER:-movie_finder}"

mkdir -p "${BACKUP_DIR}"

echo ">>> Backing up '${DB_NAME}' → ${BACKUP_FILE}"

docker compose --project-directory "${PROJECT_DIR}" exec -T postgres \
    pg_dump \
    --username "${DB_USER}" \
    --dbname "${DB_NAME}" \
    --format=plain \
    --no-owner \
    --no-acl \
    --inserts \
    --on-conflict-do-nothing \
    > "${BACKUP_FILE}"

SIZE="$(du -sh "${BACKUP_FILE}" | cut -f1)"
echo ">>> Backup complete: ${BACKUP_FILE} (${SIZE})"
