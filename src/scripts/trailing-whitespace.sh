#!/usr/bin/env bash
set -e

if git ls-files -z | xargs -0 grep -nIH -E '[[:blank:]]+$'; then
  echo
  echo "***** Lines containing trailing whitespace *****"
  echo
  echo "Failed."
  exit 1
fi
