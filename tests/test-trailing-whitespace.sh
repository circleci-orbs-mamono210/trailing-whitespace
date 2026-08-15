#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/.." && pwd)
CHECK_SCRIPT="${REPO_ROOT}/src/scripts/trailing-whitespace.sh"

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

create_repo() {
  local repo_dir=$1

  mkdir -p "$repo_dir"
  git init -q "$repo_dir"
}

#
# Clean tracked files should pass.
#
clean_repo="${TEST_ROOT}/clean"
create_repo "$clean_repo"

printf 'clean line\n' \
  > "${clean_repo}/clean.txt"

printf 'another clean line\n' \
  > "${clean_repo}/file with spaces.txt"

printf 'dash-prefixed file\n' \
  > "${clean_repo}/-clean.txt"

(
  cd "$clean_repo"

  git add -- \
    clean.txt \
    'file with spaces.txt' \
    '-clean.txt'
)

if ! (
  cd "$clean_repo"
  bash "$CHECK_SCRIPT"
); then
  fail "clean tracked files should pass"
fi

echo "PASS: clean tracked files"

#
# Trailing whitespace should exit with status 1.
#
violation_repo="${TEST_ROOT}/violation"
create_repo "$violation_repo"

printf 'line with trailing whitespace \n' \
  > "${violation_repo}/bad.txt"

(
  cd "$violation_repo"
  git add -- bad.txt
)

set +e
(
  cd "$violation_repo"
  bash "$CHECK_SCRIPT"
) >"${TEST_ROOT}/violation.log" 2>&1
status=$?
set -e

if [ "$status" -ne 1 ]; then
  cat "${TEST_ROOT}/violation.log" >&2
  fail \
    "trailing whitespace should exit with status 1, got $status"
fi

if ! grep -Fq \
  '***** Lines containing trailing whitespace *****' \
  "${TEST_ROOT}/violation.log"; then
  cat "${TEST_ROOT}/violation.log" >&2
  fail "trailing whitespace failure message was not emitted"
fi

echo "PASS: trailing whitespace is detected"

#
# Command execution errors must not be treated as success.
#
error_dir="${TEST_ROOT}/not-a-repository"
mkdir -p "$error_dir"

set +e
(
  cd "$error_dir"
  bash "$CHECK_SCRIPT"
) >"${TEST_ROOT}/error.log" 2>&1
status=$?
set -e

if [ "$status" -le 1 ]; then
  cat "${TEST_ROOT}/error.log" >&2
  fail \
    "check execution errors must exit with status greater than 1, got $status"
fi

if ! grep -Fq \
  'Failed to execute trailing whitespace check.' \
  "${TEST_ROOT}/error.log"; then
  cat "${TEST_ROOT}/error.log" >&2
  fail "check execution error message was not emitted"
fi

echo "PASS: check execution errors are propagated"
