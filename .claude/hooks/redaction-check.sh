#!/usr/bin/env bash
# PreToolUse hook (Bash matcher). In scope ONLY for git write actions
# (add/commit/push); everything else passes through untouched. Read-only:
# never edits, stages, or deletes anything itself. No network calls — pure
# local git/grep. Fails CLOSED: any error while performing the check blocks
# the git action rather than allowing it through.

set -u

INPUT="$(cat)"

COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)"
if [[ $? -ne 0 ]]; then
  echo "redaction-check.sh: could not parse hook input JSON — blocking (fail closed)." >&2
  exit 2
fi

# Out of scope: not a git add/commit/push invocation. Allow immediately.
if ! printf '%s' "$COMMAND" | grep -qE '(^|[;&|[:space:]])git[[:space:]]+(add|commit|push)([[:space:]]|$)'; then
  exit 0
fi

fail_closed() {
  echo "redaction-check.sh: BLOCKED (fail closed) — $1" >&2
  exit 2
}

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || fail_closed "not inside a git repo, or 'git rev-parse' failed"
cd "$REPO_ROOT" 2>/dev/null || fail_closed "could not cd to repo root: $REPO_ROOT"

# The value class excludes backtick and </> so that markdown docs which
# discuss these patterns as inline-code examples (e.g. `password=`) don't
# trip the hook on their own documentation.
PATTERN='-----BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY|AKIA[0-9A-Z]{16}|(password|passwd|api[_-]?key|secret)[[:space:]]*[:=][[:space:]]*[^[:space:]`<>]{4,}|\b10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b|\b192\.168\.[0-9]{1,3}\.[0-9]{1,3}\b|\b172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3}\b'

STAGED="$(git diff --cached -U0 2>&1)" || fail_closed "'git diff --cached' failed"
UNSTAGED="$(git diff -U0 2>&1)" || fail_closed "'git diff' failed"
# --ignored so gitignored-but-present files (e.g. a stray .pem/.key) are
# still scanned — `git add` normally refuses ignored files, but `git add -f`
# doesn't, and this hook should not rely on that refusal to stay safe.
UNTRACKED="$(git status --porcelain=v1 --untracked-files=all --ignored 2>&1)" || fail_closed "'git status' failed"

# NOTE: grep -e is required — PATTERN starts with "-----BEGIN", which grep
# would otherwise parse as an option string and error out. grep exit codes:
# 0 = match found, 1 = no match (fine), 2+ = real error (fail closed).

UNTRACKED_MATCHES=""
while IFS= read -r line; do
  case "$line" in
    \?\?*) f="${line#\?\? }" ;;
    \!\!*) f="${line#\!\! }" ;;
    *) continue ;;
  esac
  [[ -f "$f" ]] || continue
  m="$(grep -aE -e "$PATTERN" -- "$f")"
  rc=$?
  if [[ $rc -gt 1 ]]; then
    fail_closed "grep failed while scanning untracked file '$f' (exit $rc)"
  fi
  [[ $rc -eq 0 ]] && UNTRACKED_MATCHES+=$'\n'"$f: $m"
done <<< "$UNTRACKED"

DIFF_MATCHES="$(printf '%s\n%s' "$STAGED" "$UNSTAGED" | grep -aE -e "$PATTERN")"
rc=$?
if [[ $rc -gt 1 ]]; then
  fail_closed "grep failed while scanning tracked diff (exit $rc)"
fi
[[ $rc -ne 0 ]] && DIFF_MATCHES=""

if [[ -n "$DIFF_MATCHES" || -n "$UNTRACKED_MATCHES" ]]; then
  {
    echo "redaction-check.sh: BLOCKED — possible secret/credential/internal-hostname content detected before a git write action."
    [[ -n "$DIFF_MATCHES" ]] && { echo "In tracked changes:"; printf '%s\n' "$DIFF_MATCHES"; }
    [[ -n "$UNTRACKED_MATCHES" ]] && { echo "In untracked files about to be added:"; printf '%s\n' "$UNTRACKED_MATCHES"; }
    echo "Review REDACTION.md, replace with placeholder tokens, then retry. If this is a false positive, adjust the matched text and retry."
  } >&2
  exit 2
fi

exit 0
