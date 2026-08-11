#!/usr/bin/env sh
set -eu

export PYTHONDONTWRITEBYTECODE=1

REGISTRY_ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd -P)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/aart-runtime-health.XXXXXX")
TEST_ROOT=$(CDPATH= cd "$TEST_ROOT" && pwd -P)
cleanup() {
  chmod -R u+w "$TEST_ROOT" 2>/dev/null || true
  rm -rf "$TEST_ROOT"
}
trap cleanup EXIT HUP INT TERM

export XDG_CONFIG_HOME="$TEST_ROOT/config"
export XDG_DATA_HOME="$TEST_ROOT/data"
export XDG_CACHE_HOME="$TEST_ROOT/cache"
mkdir -p \
  "$XDG_CONFIG_HOME" \
  "$XDG_DATA_HOME" \
  "$XDG_CACHE_HOME" \
  "$TEST_ROOT/home" \
  "$TEST_ROOT/project"

python - "$REGISTRY_ROOT" "$TEST_ROOT" <<'PY'
import contextlib
import io
import json
import sys
from pathlib import Path

from agent_artifacts.commands import marketplace, source
from agent_artifacts.model import Request

registry = Path(sys.argv[1])
test_root = Path(sys.argv[2])


def run(command, request):
    stdout = io.StringIO()
    with contextlib.redirect_stdout(stdout):
        code = command(request)
    if code != 0:
        raise SystemExit(stdout.getvalue() or "AART command failed without output")
    return json.loads(stdout.getvalue())


run(
    source.run,
    Request(
        command="source",
        source_action="add",
        source_alias="registry-under-test",
        source_kind="source-local",
        source_location=str(registry),
        source_make_default=False,
        user_home=str(test_root / "home"),
        json=True,
    ),
)
report = run(
    marketplace.run,
    Request(
        command="marketplace",
        marketplace_action="health",
        names=("registry-under-test/collection/residuality",),
        runtime_environment=str(registry / ".agent-artifacts/runtime-environment.json"),
        project=str(test_root / "project"),
        user_home=str(test_root / "home"),
        json=True,
    ),
)
if report.get("ok") is not True or report.get("advisory") is not True:
    raise SystemExit("runtime health did not produce a valid advisory report")
if report.get("installation_blocking") is not False:
    raise SystemExit("runtime requirements must never become an installation gate")
summary = report.get("summary", {})
if summary.get("satisfied") != 13 or summary.get("not-declared") != 1:
    raise SystemExit(f"unexpected Residuality runtime health summary: {summary!r}")
if any(
    summary.get(status) != 0
    for status in ("unsatisfied", "unknown", "unavailable", "invalid")
):
    raise SystemExit(f"Residuality Python 3.11 inventory is not healthy: {summary!r}")
items = report.get("items", [])
if len(items) != 14:
    raise SystemExit("runtime health did not expand all fourteen collection members")
PY
