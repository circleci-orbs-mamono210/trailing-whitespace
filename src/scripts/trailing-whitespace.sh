#!/usr/bin/env bash
set -e

if git grep \
  -nI \
  -E \
  -e '[[:blank:]]+$' \
  -e $'[[:blank:]]+\r$' \
  --; then
  echo
  echo "***** Lines containing trailing whitespace *****"
  echo
  echo "Failed."
  exit 1
else
  status=$?
fi

if [ "$status" -eq 1 ]; then
  exit 0
fi

echo "Failed to execute trailing whitespace check." >&2
exit "$status"
