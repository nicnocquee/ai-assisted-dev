#!/usr/bin/env bash
# Pick a conflict-free dev port for a flow task worktree.
# Usage: pick-flow-port.sh <default_port> <task_id>
# Example: pick-flow-port.sh 3000 T-0001  →  3001 (or next free)
set -euo pipefail

DEFAULT_PORT="${1:?usage: pick-flow-port.sh <default_port> <task_id>}"
TASK_ID="${2:?usage: pick-flow-port.sh <default_port> <task_id>}"

if ! [[ "${DEFAULT_PORT}" =~ ^[0-9]+$ ]]; then
  echo "default_port must be an integer" >&2
  exit 1
fi

if ! [[ "${TASK_ID}" =~ ^T-[0-9]+$ ]]; then
  echo "task_id must look like T-NNNN" >&2
  exit 1
fi

NUM=$((10#${TASK_ID#T-}))
CANDIDATE=$((DEFAULT_PORT + NUM))
MAX=$((CANDIDATE + 100))

is_listening() {
  local port="$1"
  if command -v lsof >/dev/null 2>&1; then
    lsof -nP -iTCP:"${port}" -sTCP:LISTEN >/dev/null 2>&1
  elif command -v nc >/dev/null 2>&1; then
    nc -z 127.0.0.1 "${port}" >/dev/null 2>&1
  else
    # Best-effort fallback: try binding briefly with python
    python3 - "${port}" <<'PY' >/dev/null 2>&1
import socket, sys
s = socket.socket()
try:
    s.bind(("127.0.0.1", int(sys.argv[1])))
except OSError:
    sys.exit(0)  # in use / not free
else:
    sys.exit(1)  # free
finally:
    s.close()
PY
  fi
}

port="${CANDIDATE}"
while is_listening "${port}"; do
  port=$((port + 1))
  if (( port > MAX )); then
    echo "No free port in range ${CANDIDATE}-${MAX}" >&2
    exit 1
  fi
done

echo "${port}"
