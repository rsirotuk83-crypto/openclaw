#!/usr/bin/env sh
set -u

GH_GURU="${GH_GURU:-/data/workspace/bin/gh-guru}"
REPO="${GITHUB_REPOSITORY:-rsirotuk83-crypto/openclaw}"
DEVOPS_CHECK_PR="${DEVOPS_CHECK_PR:-3}"
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
run_check "gh-guru PR" "$GH_GURU" pr view "$DEVOPS_CHECK_PR" --repo "$REPO" --json number,title,state,files,url
run_check "railway status" railway status

exit "$fail"
