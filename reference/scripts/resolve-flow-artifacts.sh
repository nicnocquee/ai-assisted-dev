#!/usr/bin/env bash
# Resolve flow artifact directories from PROJECT.md.
# Usage: resolve-flow-artifacts.sh [path-to-PROJECT.md]
# Prints KEY=value lines suitable for: eval "$(resolve-flow-artifacts.sh)"
#
# Keys: TRACK_IN_GIT, ARTIFACT_ROOT, TASKS_DIR, EVIDENCE_DIR, DOCS_DIR
set -euo pipefail

find_project_md() {
  if [[ -n "${1:-}" && -f "$1" ]]; then
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
    return
  fi
  if [[ -f PROJECT.md ]]; then
    echo "$(pwd)/PROJECT.md"
    return
  fi
  local top
  top=$(git rev-parse --show-toplevel 2>/dev/null || true)
  if [[ -n "$top" && -f "$top/PROJECT.md" ]]; then
    echo "$top/PROJECT.md"
    return
  fi
  echo "PROJECT.md not found" >&2
  exit 1
}

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

section_value() {
  local key="$1"
  awk -v key="$key" '
    /^## Flow artifacts[[:space:]]*$/ { on = 1; next }
    /^## / { on = 0 }
    on {
      line = $0
      sub(/^[[:space:]]*[-*][[:space:]]*/, "", line)
      if (line ~ ("^" key ":")) {
        sub("^" key ":[[:space:]]*", "", line)
        print line
        exit
      }
    }
  ' "$PROJECT_MD"
}

main_worktree_root() {
  local common
  common=$(git -C "$PROJECT_DIR" rev-parse --git-common-dir 2>/dev/null || true)
  if [[ -z "$common" ]]; then
    echo "$PROJECT_DIR"
    return
  fi
  if [[ "$common" != /* ]]; then
    common="$PROJECT_DIR/$common"
  fi
  common=$(cd "$common" && pwd)
  if [[ "$common" == */.git ]]; then
    printf '%s\n' "${common%/.git}"
  else
    printf '%s\n' "${common%/*}"
  fi
}

expand_path() {
  local p="$1"
  case "$p" in
    "~") printf '%s\n' "$HOME" ;;
    "~/"*) printf '%s/%s\n' "$HOME" "${p#"~/"}" ;;
    *) printf '%s\n' "$p" ;;
  esac
}

PROJECT_MD=$(find_project_md "${1:-}")
PROJECT_DIR=$(cd "$(dirname "$PROJECT_MD")" && pwd)

TRACK=$(trim "$(section_value track_in_git)")
ROOT=$(trim "$(section_value root)")

if [[ -z "$TRACK" ]]; then
  TRACK="yes"
fi
if [[ -z "$ROOT" ]]; then
  ROOT="repo"
fi

case "$TRACK" in
  yes|true|1) TRACK="yes" ;;
  no|false|0) TRACK="no" ;;
  *) TRACK="yes" ;;
esac

if [[ "$ROOT" == "repo" || "$ROOT" == "." ]]; then
  if [[ "$TRACK" == "yes" ]]; then
    ARTIFACT_ROOT="$PROJECT_DIR"
  else
    ARTIFACT_ROOT=$(main_worktree_root)
  fi
else
  ARTIFACT_ROOT=$(expand_path "$ROOT")
  if [[ "$ARTIFACT_ROOT" != /* ]]; then
    ARTIFACT_ROOT="$PROJECT_DIR/$ARTIFACT_ROOT"
  fi
  if [[ -d "$ARTIFACT_ROOT" ]]; then
    ARTIFACT_ROOT=$(cd "$ARTIFACT_ROOT" && pwd)
  fi
fi

printf 'TRACK_IN_GIT=%s\n' "$TRACK"
printf 'ARTIFACT_ROOT=%s\n' "$ARTIFACT_ROOT"
printf 'TASKS_DIR=%s/tasks\n' "$ARTIFACT_ROOT"
printf 'EVIDENCE_DIR=%s/evidence\n' "$ARTIFACT_ROOT"
printf 'DOCS_DIR=%s/docs\n' "$ARTIFACT_ROOT"
