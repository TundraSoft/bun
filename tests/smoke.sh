#!/usr/bin/env bash
#
# Smoke test for the tundrasoft/bun image.
#
# The image ENTRYPOINT is /init (s6-overlay), which boots s6 AND starts the
# 'bun' longrun service. Checks that must NOT start the app service bypass the
# entrypoint (--entrypoint=""); the boot checks run the image normally so they
# double as proof that s6 brought the bun service up healthy.
#
# Usage: tests/smoke.sh <image> [expected-bun-version]
set -euo pipefail

IMG="${1:?usage: smoke.sh <image> [expected-bun-version]}"
EXPECTED_BUN="${2:-}"
CID=""

fail() {
  printf '\033[31mFAIL\033[0m %s\n' "$*" >&2
  [ -n "$CID" ] && docker rm -f "$CID" >/dev/null 2>&1 || true
  exit 1
}
pass() { printf '\033[32mPASS\033[0m %s\n' "$*"; }
contains() { printf '%s' "$1" | grep -qF "$2"; }

# Run `bun -e <js>` with the s6 entrypoint bypassed (JS passed as one argv, no shell quoting).
bun_eval() { docker run --rm --entrypoint="" "$IMG" bun -e "$1"; }
# Run a shell one-liner with the s6 entrypoint bypassed.
bun_sh() { docker run --rm --entrypoint="" "$IMG" /bin/sh -c "$1"; }

# Wait until the in-container healthcheck reports the bun service up.
wait_healthy() {
  n=0
  until docker exec "$1" /usr/bin/healthcheck.sh >/dev/null 2>&1; do
    n=$((n + 1))
    [ "$n" -ge 30 ] && return 1
    sleep 1
  done
}

# Wait until the app actually serves HTTP. s6 reports the service "up" as soon
# as it execs the run script, which is before Bun.serve binds the port, so poll
# the endpoint rather than trusting the healthcheck alone.
wait_http() {
  n=0
  until docker exec "$1" curl -sf http://localhost:8080/ >/dev/null 2>&1; do
    n=$((n + 1))
    [ "$n" -ge 30 ] && return 1
    sleep 1
  done
}

# Bun runtime checks (entrypoint bypassed — no app service started)

# 1. Bun version
if [ -n "$EXPECTED_BUN" ]; then
  contains "$(bun_sh 'bun --version')" "$EXPECTED_BUN" || fail "bun --version does not contain '$EXPECTED_BUN'"
  pass "bun --version reports $EXPECTED_BUN"
else
  bun_sh 'bun --version' >/dev/null || fail "bun --version failed"
  pass "bun --version runs"
fi

# 2. Basic JavaScript execution
contains "$(bun_eval 'console.log("Hello Bun")')" "Hello Bun" || fail "bun eval failed"
pass "bun eval executes JavaScript"

# 3. TypeScript executed directly (no build step)
contains "$(bun_eval 'const x: number = 42; console.log("Number:", x)')" "Number: 42" || fail "TypeScript exec failed"
pass "bun executes TypeScript directly"

# 4. Web fetch API present
contains "$(bun_eval 'console.log(typeof fetch)')" "function" || fail "web fetch API missing"
pass "web fetch API available"

# 5. Node.js compatibility (require + built-in modules)
contains "$(bun_eval 'const p = require("path"); console.log(p.join("a", "b"))')" "a/b" || fail "node compat failed"
pass "Node.js require compatibility"

# 6. package.json script execution
script_out="$(bun_sh 'cd /tmp && echo "{\"scripts\":{\"hello\":\"echo hi-from-script\"}}" > package.json && bun run hello')"
contains "$script_out" "hi-from-script" || fail "package.json script failed"
pass "runs package.json scripts"

# 7. bunx is available (symlinked to bun)
bun_sh 'bunx --version' >/dev/null || fail "bunx not available"
pass "bunx available"

# 8. Non-root tundra user at the default uid/gid
ids="$(bun_sh 'id -u tundra; id -g tundra')"
[ "$(printf '%s\n' "$ids" | sed -n 1p)" = "1000" ] || fail "tundra uid != 1000"
[ "$(printf '%s\n' "$ids" | sed -n 2p)" = "1000" ] || fail "tundra gid != 1000"
pass "tundra user at uid/gid 1000/1000"

# s6 boot / service checks (full entrypoint)

# 9. Default demo service boots healthy and serves HTTP
CID="$(docker run -d "$IMG")"
wait_healthy "$CID" || fail "bun service did not become healthy"
wait_http "$CID" || fail "demo server did not respond"
demo="$(docker exec "$CID" curl -sf http://localhost:8080/)"
contains "$demo" "Welcome to Bun" || fail "demo server response unexpected: $demo"
docker rm -f "$CID" >/dev/null
CID=""
pass "default demo service boots healthy and serves HTTP"

# 10. FILE mode runs a mounted file
APPDIR="$(cd "$(dirname "$0")/fixtures/app" && pwd)"
CID="$(docker run -d -e FILE=/app/server.ts -v "$APPDIR":/app:ro "$IMG")"
wait_healthy "$CID" || fail "FILE-mode service did not become healthy"
wait_http "$CID" || fail "FILE-mode server did not respond"
filed="$(docker exec "$CID" curl -sf http://localhost:8080/)"
contains "$filed" "smoke-fixture-marker" || fail "FILE-mode server did not serve fixture: $filed"
docker rm -f "$CID" >/dev/null
CID=""
pass "FILE mode runs a mounted application"

# 11. SCRIPT mode runs a package.json script
CID="$(docker run -d -e SCRIPT=serve -v "$APPDIR":/app:ro "$IMG")"
wait_healthy "$CID" || fail "SCRIPT-mode service did not become healthy"
wait_http "$CID" || fail "SCRIPT-mode server did not respond"
scriptd="$(docker exec "$CID" curl -sf http://localhost:8080/)"
contains "$scriptd" "smoke-fixture-marker" || fail "SCRIPT-mode server did not serve fixture: $scriptd"
docker rm -f "$CID" >/dev/null
CID=""
pass "SCRIPT mode runs a package.json script"

echo
pass "all smoke tests passed for $IMG"
