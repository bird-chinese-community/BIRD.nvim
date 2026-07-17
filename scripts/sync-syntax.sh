#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_FILE="${1:-${ROOT_DIR}/../BIRD.vim/syntax/bird2.vim}"
TARGET_FILE="${ROOT_DIR}/syntax/bird2.vim"

if [[ ! -f "${SOURCE_FILE}" ]]; then
  echo "[sync-syntax] Source file not found: ${SOURCE_FILE}" >&2
  echo "[sync-syntax] Provide an explicit source path, for example:" >&2
  echo "[sync-syntax]   scripts/sync-syntax.sh /path/to/BIRD.vim/syntax/bird2.vim" >&2
  exit 1
fi

cp "${SOURCE_FILE}" "${TARGET_FILE}"
echo "[sync-syntax] Updated ${TARGET_FILE} from ${SOURCE_FILE}"
