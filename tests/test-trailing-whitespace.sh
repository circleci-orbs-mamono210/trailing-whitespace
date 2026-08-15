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

run_check() {
  local repo_dir=$1
  local output_file=$2

  set +e
  (
    cd "$repo_dir"
    bash "$CHECK_SCRIPT"
  ) >"$output_file" 2>&1
  local status=$?
  set -e

  return "$status"
}

#
# Clean LF tracked files should pass.
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
  fail "clean LF tracked files should pass"
fi

echo "PASS: clean LF tracked files"

#
# LF trailing whitespace should exit with status 1.
#
lf_violation_repo="${TEST_ROOT}/lf-violation"
create_repo "$lf_violation_repo"

printf 'line with trailing whitespace \n' \
  > "${lf_violation_repo}/bad.txt"

(
  cd "$lf_violation_repo"
  git add -- bad.txt
)

set +e
(
  cd "$lf_violation_repo"
  bash "$CHECK_SCRIPT"
) >"${TEST_ROOT}/lf-violation.log" 2>&1
status=$?
set -e

if [ "$status" -ne 1 ]; then
  cat "${TEST_ROOT}/lf-violation.log" >&2
  fail \
    "LF trailing whitespace should exit with status 1, got $status"
fi

if ! grep -Fq \
  '***** Lines containing trailing whitespace *****' \
  "${TEST_ROOT}/lf-violation.log"; then
  cat "${TEST_ROOT}/lf-violation.log" >&2
  fail "LF trailing whitespace failure message was not emitted"
fi

echo "PASS: LF trailing whitespace is detected"

#
# Clean CRLF tracked files should pass.
#
crlf_clean_repo="${TEST_ROOT}/crlf-clean"
create_repo "$crlf_clean_repo"

printf 'first clean line\r\nsecond clean line\r\n' \
  > "${crlf_clean_repo}/clean-crlf.txt"

(
  cd "$crlf_clean_repo"
  git add -- clean-crlf.txt
)

if ! (
  cd "$crlf_clean_repo"
  bash "$CHECK_SCRIPT"
); then
  fail "clean CRLF tracked files should pass"
fi

echo "PASS: clean CRLF tracked files"

#
# CRLF trailing space should exit with status 1.
#
crlf_space_repo="${TEST_ROOT}/crlf-space"
create_repo "$crlf_space_repo"

printf 'line with trailing space \r\n' \
  > "${crlf_space_repo}/bad-space.txt"

(
  cd "$crlf_space_repo"
  git add -- bad-space.txt
)

set +e
(
  cd "$crlf_space_repo"
  bash "$CHECK_SCRIPT"
) >"${TEST_ROOT}/crlf-space.log" 2>&1
status=$?
set -e

if [ "$status" -ne 1 ]; then
  cat "${TEST_ROOT}/crlf-space.log" >&2
  fail \
    "CRLF trailing space should exit with status 1, got $status"
fi

echo "PASS: CRLF trailing space is detected"

#
# CRLF trailing tab should exit with status 1.
#
crlf_tab_repo="${TEST_ROOT}/crlf-tab"
create_repo "$crlf_tab_repo"

printf 'line with trailing tab\t\r\n' \
  > "${crlf_tab_repo}/bad-tab.txt"

(
  cd "$crlf_tab_repo"
  git add -- bad-tab.txt
)

set +e
(
  cd "$crlf_tab_repo"
  bash "$CHECK_SCRIPT"
) >"${TEST_ROOT}/crlf-tab.log" 2>&1
status=$?
set -e

if [ "$status" -ne 1 ]; then
  cat "${TEST_ROOT}/crlf-tab.log" >&2
  fail \
    "CRLF trailing tab should exit with status 1, got $status"
fi

echo "PASS: CRLF trailing tab is detected"

#
# A violation in one line of a multiline CRLF file should be detected.
#
crlf_multiline_repo="${TEST_ROOT}/crlf-multiline"
create_repo "$crlf_multiline_repo"

printf \
  'first clean line\r\nsecond line with trailing space \r\nthird clean line\r\n' \
  > "${crlf_multiline_repo}/multiline.txt"

(
  cd "$crlf_multiline_repo"
  git add -- multiline.txt
)

set +e
(
  cd "$crlf_multiline_repo"
  bash "$CHECK_SCRIPT"
) >"${TEST_ROOT}/crlf-multiline.log" 2>&1
status=$?
set -e

if [ "$status" -ne 1 ]; then
  cat "${TEST_ROOT}/crlf-multiline.log" >&2
  fail \
    "multiline CRLF violation should exit with status 1, got $status"
fi

echo "PASS: multiline CRLF trailing whitespace is detected"

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
