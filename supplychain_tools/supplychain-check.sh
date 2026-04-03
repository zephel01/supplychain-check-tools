#!/usr/bin/env bash
set -euo pipefail

RED='\033[31m'; YELLOW='\033[33m'; GREEN='\033[32m'; BLUE='\033[34m'; BOLD='\033[1m'; RESET='\033[0m'
PASS_COUNT=0; WARN_COUNT=0; FAIL_COUNT=0; INFO_COUNT=0
TARGET_DIR="${1:-.}"

usage() {
  cat <<USAGE
Usage:
  $(basename "$0") [target_dir]

Examples:
  $(basename "$0") .
  $(basename "$0") /path/to/project
USAGE
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { usage; exit 0; }
[[ -d "$TARGET_DIR" ]] || { echo "Target directory not found: $TARGET_DIR"; exit 1; }
cd "$TARGET_DIR"

pass() { printf "${GREEN}[PASS]${RESET} %s\n" "$1"; PASS_COUNT=$((PASS_COUNT+1)); }
warn() { printf "${YELLOW}[WARN]${RESET} %s\n" "$1"; WARN_COUNT=$((WARN_COUNT+1)); }
fail() { printf "${RED}[FAIL]${RESET} %s\n" "$1"; FAIL_COUNT=$((FAIL_COUNT+1)); }
info() { printf "${BLUE}[INFO]${RESET} %s\n" "$1"; INFO_COUNT=$((INFO_COUNT+1)); }
section() { printf "\n${BOLD}== %s ==${RESET}\n" "$1"; }

have_file() { [[ -f "$1" ]]; }
have_cmd() { command -v "$1" >/dev/null 2>&1; }
contains() { local f="$1" p="$2"; [[ -f "$f" ]] && grep -Eq "$p" "$f"; }
print_fix() { printf "      -> %s\n" "$1"; }

section "Supply Chain Security Quick Check"
info "Target directory: $(pwd)"

section "Common"
if [[ -d .git ]]; then
  pass ".git detected"
else
  warn "Not a git repository. Change history / rollback may be harder."
  print_fix "git init && git add . && git commit -m 'initial'"
fi

if [[ -d .github/workflows ]]; then
  pass "GitHub Actions workflow directory found"
else
  warn ".github/workflows not found. CI security checks may be missing."
  print_fix "Create .github/workflows/supply-chain-security.yml"
fi

section "Node.js / npm"
if have_file package.json; then
  pass "package.json found"

  if have_file package-lock.json; then
    pass "package-lock.json found"
  else
    fail "package-lock.json missing"
    print_fix "npm install --package-lock-only  # or run npm install once and commit package-lock.json"
  fi

  npmrc_file=""
  if have_file .npmrc; then
    npmrc_file=".npmrc"
    pass ".npmrc found in project"
  elif have_file "$HOME/.npmrc"; then
    npmrc_file="$HOME/.npmrc"
    info "Project .npmrc not found, using $HOME/.npmrc for checks"
  else
    warn ".npmrc not found"
    print_fix "Create .npmrc and set at least: min-release-age=7"
  fi

  if [[ -n "$npmrc_file" ]]; then
    if contains "$npmrc_file" '^[[:space:]]*min-release-age[[:space:]]*=[[:space:]]*[7-9][0-9]*|^[[:space:]]*min-release-age[[:space:]]*=[[:space:]]*7$'; then
      pass "min-release-age is set to 7 days or more in $npmrc_file"
    elif contains "$npmrc_file" '^[[:space:]]*min-release-age[[:space:]]*='; then
      warn "min-release-age is set, but appears to be less than 7 days"
      print_fix "Set min-release-age=7"
    else
      warn "min-release-age not set in $npmrc_file"
      print_fix "Add: min-release-age=7"
    fi

    if contains "$npmrc_file" '^[[:space:]]*registry[[:space:]]*=[[:space:]]*https://npm\.flatt\.tech/?'; then
      pass "Takumi Guard registry configured in $npmrc_file"
    else
      info "Takumi Guard registry not configured in $npmrc_file"
      print_fix "Optional: registry=https://npm.flatt.tech/"
    fi

    if contains "$npmrc_file" '^[[:space:]]*ignore-scripts[[:space:]]*=[[:space:]]*true'; then
      pass "ignore-scripts=true is set"
    elif contains "$npmrc_file" '^[[:space:]]*ignore-scripts[[:space:]]*=[[:space:]]*false'; then
      warn "ignore-scripts=false is set. postinstall / install scripts can run."
      print_fix "For higher safety, consider ignore-scripts=true and only enable when necessary"
    else
      info "ignore-scripts not explicitly set"
      print_fix "Consider adding ignore-scripts=true unless your project needs install scripts"
    fi
  fi

  if [[ -d .github/workflows ]]; then
    if grep -RqsE 'npm ci' .github/workflows; then
      pass "CI uses npm ci"
    elif grep -RqsE 'npm install' .github/workflows; then
      warn "CI appears to use npm install instead of npm ci"
      print_fix "Prefer npm ci in CI for lockfile-based deterministic installs"
    else
      info "No npm install command found in CI workflows"
    fi

    if grep -RqsE 'setup-takumi-guard-npm' .github/workflows; then
      pass "Takumi Guard GitHub Action detected"
    else
      info "Takumi Guard GitHub Action not detected"
      print_fix "Optional: uses: flatt-security/setup-takumi-guard-npm@v1"
    fi
  fi

  if have_cmd npm; then
    info "npm version: $(npm --version 2>/dev/null || true)"
  else
    warn "npm command not found on this system"
  fi
else
  info "package.json not found; skipping npm checks"
fi

section "Python"
py_found=0
if have_file requirements.txt || have_file pyproject.toml || have_file Pipfile; then
  py_found=1
fi
if [[ $py_found -eq 1 ]]; then
  pass "Python project markers found"

  if have_file requirements.txt; then
    if grep -Eq '^(--index-url|-i)[[:space:]]+https://pypi\.flatt\.tech/' requirements.txt; then
      pass "requirements.txt uses pypi.flatt.tech"
    else
      info "requirements.txt does not appear to use pypi.flatt.tech"
      print_fix "Optional: add '-i https://pypi.flatt.tech/' at the top"
    fi
  fi

  if have_file pyproject.toml; then
    if grep -Eq 'https://pypi\.flatt\.tech/' pyproject.toml; then
      pass "pyproject.toml references pypi.flatt.tech"
    else
      info "pyproject.toml does not reference pypi.flatt.tech"
      print_fix "Optional for Poetry: add [[tool.poetry.source]] with https://pypi.flatt.tech/"
    fi
  fi

  if have_file Pipfile; then
    if grep -Eq 'https://pypi\.flatt\.tech/' Pipfile; then
      pass "Pipfile references pypi.flatt.tech"
    else
      info "Pipfile does not reference pypi.flatt.tech"
    fi
  fi

  if [[ -d .github/workflows ]] && grep -RqsE 'guarddog|safety' .github/workflows; then
    pass "Python dependency scan tool referenced in CI"
  else
    info "No GuardDog/Safety usage detected in CI"
    print_fix "Optional: pip install guarddog safety && run scans in CI"
  fi

  if have_cmd python3; then
    info "python3 version: $(python3 --version 2>/dev/null || true)"
  else
    warn "python3 command not found on this system"
  fi
else
  info "Python project markers not found; skipping Python checks"
fi

section "Go"
if have_file go.mod; then
  pass "go.mod found"
  if have_file go.sum; then
    pass "go.sum found"
  else
    fail "go.sum missing"
    print_fix "Run: go mod tidy && commit go.sum"
  fi

  if grep -Eq '^replace ' go.mod; then
    info "go.mod contains replace directives; verify they are intentional"
  fi

  if [[ -d .github/workflows ]] && grep -RqsE 'gosec|govulncheck' .github/workflows; then
    pass "Go security scanning detected in CI"
  else
    info "No Go security scanning detected in CI"
    print_fix "Optional: add gosec or govulncheck to CI"
  fi

  if have_cmd go; then
    info "go version: $(go version 2>/dev/null || true)"
  else
    warn "go command not found on this system"
  fi
else
  info "go.mod not found; skipping Go checks"
fi

section "Rust"
if have_file Cargo.toml; then
  pass "Cargo.toml found"
  if have_file Cargo.lock; then
    pass "Cargo.lock found"
  else
    warn "Cargo.lock missing"
    print_fix "Generate and commit Cargo.lock (especially for binaries/apps)"
  fi

  if [[ -d .github/workflows ]] && grep -RqsE 'cargo audit' .github/workflows; then
    pass "cargo audit detected in CI"
  else
    info "cargo audit not detected in CI"
    print_fix "Optional: cargo install cargo-audit && run cargo audit in CI"
  fi

  if have_cmd cargo; then
    info "cargo version: $(cargo --version 2>/dev/null || true)"
  else
    warn "cargo command not found on this system"
  fi
else
  info "Cargo.toml not found; skipping Rust checks"
fi

section "Result Summary"
printf "PASS=%d WARN=%d FAIL=%d INFO=%d\n" "$PASS_COUNT" "$WARN_COUNT" "$FAIL_COUNT" "$INFO_COUNT"

if [[ $FAIL_COUNT -gt 0 ]]; then
  printf "${RED}${BOLD}Overall: ACTION REQUIRED${RESET}\n"
elif [[ $WARN_COUNT -gt 0 ]]; then
  printf "${YELLOW}${BOLD}Overall: MOSTLY OK, BUT HARDENING IS RECOMMENDED${RESET}\n"
else
  printf "${GREEN}${BOLD}Overall: GOOD BASELINE${RESET}\n"
fi

cat <<'NEXT'

Next recommended commands:
  1) Re-run after changes:
       ./supplychain-check.sh .
  2) For Node.js:
       npm ci
  3) For Python:
       pip install guarddog safety
  4) For Go:
       go mod tidy && go mod verify
  5) For Rust:
       cargo audit
NEXT
