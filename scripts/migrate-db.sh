#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/db-common.sh"

MIGRATIONS_DIR="${DB_DIR}/migrations"

if [ ! -d "${MIGRATIONS_DIR}" ]; then
    echo "Missing migrations directory: ${MIGRATIONS_DIR}" >&2
    exit 1
fi

ensure_migration_tracking

while IFS= read -r migration_file; do
    migration_name="$(basename "${migration_file}")"

    if migration_applied "${migration_name}"; then
        echo "Skipping ${migration_name}"
        continue
    fi

    echo "Applying ${migration_name}"
    run_sql_file "${migration_file}"
    record_migration "${migration_name}"
done < <(sql_files_in_dir "${MIGRATIONS_DIR}")
