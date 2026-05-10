#!/usr/bin/env sh
set -eu

WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-/data/workspace}"
BIN_DIR="$WORKSPACE_DIR/bin"
mkdir -p "$BIN_DIR"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh missing; install GitHub CLI in runtime image or startup before using gh-guru" >&2
fi

if ! command -v railway >/dev/null 2>&1; then
  echo "railway missing; install Railway CLI in runtime image or startup before Railway checks" >&2
fi

python3 - <<'PY_DEVOPS_WRAPPERS'
from pathlib import Path
bin_dir = Path('/data/workspace/bin')
bin_dir.mkdir(parents=True, exist_ok=True)

(bin_dir / 'gh-guru').write_text("""#!/usr/bin/env sh
set -eu
TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
if [ -z "$TOKEN" ] && [ -r /proc/1/environ ]; then
  TOKEN="$(tr '\\0' '\\n' < /proc/1/environ | sed -n 's/^GH_TOKEN=//p' | head -1)"
  if [ -z "$TOKEN" ]; then
    TOKEN="$(tr '\\0' '\\n' < /proc/1/environ | sed -n 's/^GITHUB_TOKEN=//p' | head -1)"
  fi
fi
if [ -z "$TOKEN" ]; then
  echo "GH_TOKEN/GITHUB_TOKEN missing" >&2
  exit 1
fi
GH_TOKEN="$TOKEN" exec gh "$@"
""")
(bin_dir / 'gh-guru').chmod(0o700)

(bin_dir / 'git-guru').write_text("""#!/usr/bin/env sh
set -eu
ASKPASS="$(mktemp /tmp/git-guru-askpass.XXXXXX)"
trap 'rm -f "$ASKPASS"' EXIT INT TERM
cat > "$ASKPASS" <<'ASKPASS_SCRIPT'
#!/usr/bin/env sh
set -eu
case "${1:-}" in
  *Username*) printf '%s\\n' 'x-access-token' ;;
  *Password*)
    TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
    if [ -z "$TOKEN" ] && [ -r /proc/1/environ ]; then
      TOKEN="$(tr '\\0' '\\n' < /proc/1/environ | sed -n 's/^GH_TOKEN=//p' | head -1)"
      if [ -z "$TOKEN" ]; then
        TOKEN="$(tr '\\0' '\\n' < /proc/1/environ | sed -n 's/^GITHUB_TOKEN=//p' | head -1)"
      fi
    fi
    if [ -z "$TOKEN" ]; then
      echo 'GH_TOKEN/GITHUB_TOKEN missing' >&2
      exit 1
    fi
    printf '%s\\n' "$TOKEN"
    ;;
  *) printf '\\n' ;;
esac
ASKPASS_SCRIPT
chmod 700 "$ASKPASS"
GIT_ASKPASS="$ASKPASS" GIT_TERMINAL_PROMPT=0 exec git -c credential.helper= "$@"
""")
(bin_dir / 'git-guru').chmod(0o700)
PY_DEVOPS_WRAPPERS

echo "DevOps wrappers restored in $BIN_DIR"
