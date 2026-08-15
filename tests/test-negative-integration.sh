#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/.." && pwd)
CHECK_SCRIPT="${REPO_ROOT}/src/scripts/trailing-whitespace.sh"

TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT

TEST_REPO="${TEST_ROOT}/repository"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

run_check() {
  local output_file=$1

  set +e
  (
    cd "$TEST_REPO"
    bash "$CHECK_SCRIPT"
  ) >"$output_file" 2>&1
  status=$?
  set -e
}

mkdir -p "$TEST_REPO"
git init -q "$TEST_REPO"

#
# A clean tracked file should pass.
#
printf 'clean tracked line\n' \
  > "${TEST_REPO}/clean.txt"

(
  cd "$TEST_REPO"
  git add -- clean.txt
)

run_check "${TEST_ROOT}/clean.log"

if [ "$status" -ne 0 ]; then
  cat "${TEST_ROOT}/clean.log" >&2
  fail \
    "clean tracked files should exit with status 0, got $status"
fi

echo "PASS: clean tracked file is accepted"

#
# An untracked file containing trailing whitespace should be ignored.
#
printf 'untracked line with trailing whitespace \n' \
  > "${TEST_REPO}/bad.txt"

run_check "${TEST_ROOT}/untracked.log"

if [ "$status" -ne 0 ]; then
  cat "${TEST_ROOT}/untracked.log" >&2
  fail \
    "untracked files should be ignored, got exit status $status"
fi

echo "PASS: untracked file is ignored"

#
# Once the same file becomes tracked, the check must fail.
#
(
  cd "$TEST_REPO"
  git add -- bad.txt
)

run_check "${TEST_ROOT}/tracked.log"

if [ "$status" -ne 1 ]; then
  cat "${TEST_ROOT}/tracked.log" >&2
  fail \
    "tracked trailing whitespace should exit with status 1, got $status"
fi

if ! grep -Fq \
  '***** Lines containing trailing whitespace *****' \
  "${TEST_ROOT}/tracked.log"; then
  cat "${TEST_ROOT}/tracked.log" >&2
  fail "trailing whitespace failure message was not emitted"
fi

if ! grep -Fq \
  'bad.txt:1:' \
  "${TEST_ROOT}/tracked.log"; then
  cat "${TEST_ROOT}/tracked.log" >&2
  fail "the tracked violating file was not reported"
fi

echo "PASS: tracked trailing whitespace is detected"
echo "PASS: negative integration test completed"
