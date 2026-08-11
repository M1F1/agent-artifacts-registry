#!/usr/bin/env sh
set -eu

export PYTHONDONTWRITEBYTECODE=1

REGISTRY_ROOT=$(CDPATH= cd "$(dirname "$0")/.." && pwd -P)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/aart-residuality.XXXXXX")
TEST_ROOT=$(CDPATH= cd "$TEST_ROOT" && pwd -P)
trap 'rm -rf "$TEST_ROOT"' EXIT HUP INT TERM

SKILLS="
using-residues
residual-01-flows
residual-02-naive
residual-03-stressors
residual-04-residues
residual-05-architecture
residual-06-matrix
residual-07-review
residual-08-holdout
residual-09-ri
residual-run-parallel
residual-run-loop
residual-run-sequential
"

python3 - "$REGISTRY_ROOT" <<'PY'
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
collection = json.loads((root / "collections/residuality.json").read_text(encoding="utf-8"))
members = {(item["type"], item["name"]) for item in collection["artifacts"]}
expected = {("guideline", "residuality-theory")}
expected.update(
    ("skill", name)
    for name in (
        "using-residues",
        "residual-01-flows",
        "residual-02-naive",
        "residual-03-stressors",
        "residual-04-residues",
        "residual-05-architecture",
        "residual-06-matrix",
        "residual-07-review",
        "residual-08-holdout",
        "residual-09-ri",
        "residual-run-parallel",
        "residual-run-loop",
        "residual-run-sequential",
    )
)
if collection["name"] != "residuality" or members != expected or len(members) != 14:
    raise SystemExit("residuality collection does not contain the declared fourteen artifacts")

for kind, name in members:
    manifest = json.loads(
        (root / "artifacts" / kind / name / "artifact.json").read_text(encoding="utf-8")
    )
    if manifest["version"] != "1.0.0" or manifest["license"] != "MIT":
        raise SystemExit(f"{kind}/{name} must remain at the reviewed MIT 1.0.0 import")
    compatibility = manifest["compatibility"]
    install = manifest["install"]
    if set(compatibility["platforms"]) != {"darwin", "linux"}:
        raise SystemExit(f"{kind}/{name} does not declare the reviewed platform set")
    if set(compatibility["profiles"]) != {"claude", "opencode", "tabnine", "vibe"}:
        raise SystemExit(f"{kind}/{name} does not declare every reviewed profile")
    if set(install["scopes"]) != {"project", "user"}:
        raise SystemExit(f"{kind}/{name} does not declare project and user scope")
    if set(install["modes"]) != {"copy", "symlink"}:
        raise SystemExit(f"{kind}/{name} does not declare Copy and Symlink modes")
    if "requires_aart" in manifest:
        raise SystemExit(f"{kind}/{name} must not gain an incidental requires_aart bound")
    provenance = json.loads(
        (root / "artifacts" / kind / name / "provenance.json").read_text(encoding="utf-8")
    )["origin"]
    if provenance["url"] != "https://github.com/M1F1/residues-architecture-framework.git":
        raise SystemExit(f"{kind}/{name} has unexpected upstream provenance")
    if provenance["resolved_commit"] != "576c6b953f45f9561f12ba6b76b7b6a5da74a96b":
        raise SystemExit(f"{kind}/{name} is not pinned to the reviewed immutable commit")
PY

install_copy_layout() {
  destination=$1
  mkdir -p "$destination/skills" "$destination/guidelines"
  for skill in $SKILLS; do
    cp -R "$REGISTRY_ROOT/artifacts/skill/$skill/payload" "$destination/skills/$skill"
  done
  cp "$REGISTRY_ROOT/artifacts/guideline/residuality-theory/payload/residuality-theory.md" \
    "$destination/guidelines/residuality-theory.md"
}

install_symlink_layout() {
  destination=$1
  mkdir -p "$destination/skills" "$destination/guidelines"
  for skill in $SKILLS; do
    ln -s "$REGISTRY_ROOT/artifacts/skill/$skill/payload" "$destination/skills/$skill"
  done
  ln -s \
    "$REGISTRY_ROOT/artifacts/guideline/residuality-theory/payload/residuality-theory.md" \
    "$destination/guidelines/residuality-theory.md"
}

install_copy_layout "$TEST_ROOT/copy"
install_symlink_layout "$TEST_ROOT/symlink"

for mode in copy symlink; do
  skills_root="$TEST_ROOT/$mode/skills"
  test -x "$skills_root/using-residues/kernel/bin/residual"
  test -x "$skills_root/using-residues/kernel/bin/residual-test"
  test -x "$skills_root/residual-01-flows/scripts/run.py"
  "$skills_root/using-residues/kernel/bin/residual-test"
  "$skills_root/using-residues/kernel/bin/residual" steps | grep -F "09-ri" >/dev/null
done
