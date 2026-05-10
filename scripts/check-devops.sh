#!/usr/bin/env sh
set -u

GH_GURU="${GH_GURU:-/data/workspace/bin/gh-guru}"
fail=0

run_check() {
  name="$1"
  shift
  echo "=== $name ==="
  if "$@"; then
    echo "OK $name"
  else
    echo "FAIL $name"
    fail=1
  fi
}

run_check "gh version" gh --version
run_check "railway version" railway --version
run_check "gh-guru auth" "$GH_GURU" auth status
run_check "gh-guru PR #2" "$GH_GURU" pr view 2 --json number,state,files,url
run_check "railway status" railway status

exit "$fail"
