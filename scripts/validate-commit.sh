#!/usr/bin/env bash
set -euo pipefail
# validate-commit.sh
# WHY: Provide immediate developer feedback on enterprise commit policy compliance before pushing.
# Reads commit message file passed from husky commit-msg hook, constructs minimal input for OPA, evaluates policy.

MSG_FILE=${1:-}
if [ -z "$MSG_FILE" ] || [ ! -f "$MSG_FILE" ]; then
  echo "[validate-commit] Commit message file missing" >&2
  exit 1
fi

COMMIT_MSG=$(cat "$MSG_FILE")
# Infer changed files for staged commit (NOTE: uses cached index, excluding deletions)
CHANGED_FILES=$(git diff --cached --name-only | tr '\n' ' ')

# Build JSON input for OPA
INPUT_JSON=$(jq -n --arg msg "$COMMIT_MSG" --arg files "$CHANGED_FILES" '{commits:[{sha:"LOCAL", message:$msg, changed_files:($files|split(" ")|map(select(. != "")))}]}')

# Evaluate allow
if ! opa eval -f json -d policies -I 'data.enterprise.git.allow' -i <(echo "$INPUT_JSON") >/dev/null 2>&1; then
  echo "[validate-commit] OPA evaluation error (policy syntax?)" >&2
  exit 1
fi
ALLOWED=$(opa eval -f json -d policies -I 'data.enterprise.git.allow' -i <(echo "$INPUT_JSON") | jq -r '.result[0].expressions[0].value')

if [ "$ALLOWED" != "true" ]; then
  echo "[validate-commit] Commit rejected by policy." >&2
  # Collect deny reasons
  DENY=$(opa eval -f json -d policies -I 'data.enterprise.git.deny' -i <(echo "$INPUT_JSON") | jq -r '.result[0].expressions[0].value[]?')
  if [ -n "$DENY" ]; then
    echo "[validate-commit] Reasons:" >&2
    echo "$DENY" | sed 's/^/  - /' >&2
  fi
  echo "[validate-commit] Add required compliance metadata lines (e.g. HIPAA:, PHI-Impact:, FDA-510k:, SOX-Control:, GDPR-Data-Class:)" >&2
  exit 1
fi

echo "[validate-commit] Policy passed" >&2
exit 0
