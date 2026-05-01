#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="${LEAF_DB_ROOT:-${DEFAULT_REPO_ROOT}}"
DB_DIR="${REPO_ROOT}/db"
COMPOSE_ARGS=(-f "${REPO_ROOT}/docker-compose.yml")

if [ -f "${REPO_ROOT}/.env" ]; then
    set -a
    # shellcheck disable=SC1090
    . "${REPO_ROOT}/.env"
    set +a
    COMPOSE_ARGS+=(--env-file "${REPO_ROOT}/.env")
fi

DB_NAME="${POSTGRES_DB:-postgres}"
DB_USER="${POSTGRES_USER:-postgres}"

run_psql() {
    if [ -f "/.dockerenv" ] && command -v psql >/dev/null 2>&1; then
        psql -v ON_ERROR_STOP=1 --username "${DB_USER}" --dbname "${DB_NAME}" "$@"
        return
    fi

    if command -v docker >/dev/null 2>&1; then
        docker compose "${COMPOSE_ARGS[@]}" exec -T db \
            psql -v ON_ERROR_STOP=1 --username "${DB_USER}" --dbname "${DB_NAME}" "$@"
        return
    fi

    if command -v psql >/dev/null 2>&1; then
        psql -v ON_ERROR_STOP=1 --username "${DB_USER}" --dbname "${DB_NAME}" "$@"
        return
    fi

    echo "psql or docker compose is required." >&2
    exit 1
}

run_sql_file() {
    local file_path="$1"

    if [ -f "/.dockerenv" ]; then
        run_psql -f "${file_path}"
        return
    fi

    if command -v docker >/dev/null 2>&1; then
        docker compose "${COMPOSE_ARGS[@]}" exec -T db \
            psql -v ON_ERROR_STOP=1 --username "${DB_USER}" --dbname "${DB_NAME}" \
            < "${file_path}"
        return
    fi

    run_psql -f "${file_path}"
}

ensure_migration_tracking() {
    run_psql <<'SQL'
CREATE TABLE IF NOT EXISTS schema_migrations (
    filename   TEXT PRIMARY KEY,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
SQL
}

migration_applied() {
    local file_name="$1"
    local count

    count="$(run_psql -Atqc "SELECT COUNT(*) FROM schema_migrations WHERE filename = '${file_name}';")"
    [ "${count}" = "1" ]
}

record_migration() {
    local file_name="$1"
    run_psql -c "INSERT INTO schema_migrations (filename) VALUES ('${file_name}') ON CONFLICT (filename) DO NOTHING;"
}

sql_files_in_dir() {
    local directory="$1"
    find "${directory}" -maxdepth 1 -type f -name '*.sql' | sort
}
