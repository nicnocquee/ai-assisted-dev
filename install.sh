#!/usr/bin/env bash
# Install or uninstall flow skills and agents into ~/.cursor
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="${ROOT}/skills"
AGENTS_SRC="${ROOT}/agents"
SKILLS_DST="${HOME}/.cursor/skills"
AGENTS_DST="${HOME}/.cursor/agents"

usage() {
  echo "Usage: $0 [--uninstall]"
  exit 1
}

uninstall() {
  mkdir -p "${SKILLS_DST}" "${AGENTS_DST}"
  for skill_dir in "${SKILLS_SRC}"/*/; do
    name="$(basename "${skill_dir}")"
    target="${SKILLS_DST}/${name}"
    if [[ -L "${target}" ]]; then
      rm "${target}"
      echo "Removed skill: ${name}"
    fi
  done
  for agent_file in "${AGENTS_SRC}"/*.md; do
    name="$(basename "${agent_file}")"
    target="${AGENTS_DST}/${name}"
    if [[ -L "${target}" ]]; then
      rm "${target}"
      echo "Removed agent: ${name}"
    fi
  done
  echo "Uninstall complete."
}

install() {
  mkdir -p "${SKILLS_DST}" "${AGENTS_DST}"
  for skill_dir in "${SKILLS_SRC}"/*/; do
    name="$(basename "${skill_dir}")"
    target="${SKILLS_DST}/${name}"
    # Remove existing symlink or empty dir conflict gently
    if [[ -L "${target}" ]]; then
      rm "${target}"
    elif [[ -e "${target}" ]]; then
      echo "WARNING: ${target} exists and is not a symlink; skipping."
      continue
    fi
    ln -s "${skill_dir%/}" "${target}"
    echo "Linked skill: ${name} -> ${skill_dir%/}"
  done
  for agent_file in "${AGENTS_SRC}"/*.md; do
    name="$(basename "${agent_file}")"
    target="${AGENTS_DST}/${name}"
    if [[ -L "${target}" ]]; then
      rm "${target}"
    elif [[ -e "${target}" ]]; then
      echo "WARNING: ${target} exists and is not a symlink; skipping."
      continue
    fi
    ln -s "${agent_file}" "${target}"
    echo "Linked agent: ${name} -> ${agent_file}"
  done
  echo "Install complete."
  echo "Skills: ${SKILLS_DST}"
  echo "Agents: ${AGENTS_DST}"
}

if [[ "${1:-}" == "--uninstall" ]]; then
  uninstall
elif [[ -n "${1:-}" ]]; then
  usage
else
  install
fi
