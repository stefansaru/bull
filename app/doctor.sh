#!/usr/bin/env bash
# doctor.sh — macOS / Linux / Git Bash wrapper. Windows twin: .\doctor.ps1.
# Both call doctor.py, the single implementation (PROC-REPO-004).
set -uo pipefail
cd "$(dirname "$0")"
if command -v py >/dev/null 2>&1; then PY="py -3"; elif command -v python3 >/dev/null 2>&1; then PY=python3; else
  echo "Python 3 not found. Install Python 3.13 (https://www.python.org/downloads/) and re-run." >&2; exit 1
fi
exec $PY doctor.py "$@"
