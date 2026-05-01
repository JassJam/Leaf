#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/db-common.sh"

SEEDS_DIR="${DB_DIR}/seeds"

if [ ! -d "${SEEDS_DIR}" ]; then
    echo "Missing seeds directory: ${SEEDS_DIR}" >&2
    exit 1
fi

while IFS= read -r seed_file; do
    seed_name="$(basename "${seed_file}")"
    echo "Applying ${seed_name}"
    run_sql_file "${seed_file}"
done < <(sql_files_in_dir "${SEEDS_DIR}")
