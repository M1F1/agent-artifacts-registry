---
name: agent-artifacts
description: Guide people, agents, and registry maintainers through agent-artifacts (aart) 1.1 configured sources and federated marketplaces. Use when choosing or managing registry-git, source-git, or source-local sources; inspecting source health and trust; browsing or installing artifacts through the human TUI or agent-safe CLI/JSON; selecting Copy or Symlink and project or user scope; running lifecycle/setup operations; or compiling and auditing an AART registry.
---

# Use Agent-Artifacts 1.1

Treat `aart` as the executable for consuming configured artifact sources and maintaining registry
checkouts. The executable does not carry a catalog. Marketplace content comes from explicit
`registry-git`, `source-git`, or `source-local` entries in the effective user configuration.

## Choose the interface

- For a person at an interactive terminal, recommend the guided TUI by running `aart`. The Sources
  stage reviews configured origins and health before marketplace selection, installation, and
  optional setup.
- For an agent or automation, never drive the TUI. Use explicit `source`, `marketplace`,
  `registry`, or `security` subcommands with `--json` when supported.
- Prefer canonical `source` and `marketplace` commands. Treat `list`, `install`, `status`, `check`,
  `update`, `uninstall`, and `setup` as legacy compatibility commands unless the user explicitly
  needs that surface.
- Parse JSON and check the process exit code. Do not scrape the human renderer.

## Safety contract

- Inspect before changing state. Use a mutating marketplace command without `--yes` to review its
  plan, then add `--yes` only after the user authorizes the shown effects.
- Do not invent `--dry-run` for canonical marketplace commands; absence of `--yes` is their review
  mode.
- `source add` has no separate finalize flag. Confirm the exact alias, kind, credential-free
  origin/path, ref, and default choice before running it.
- Never use `--force`, `--prune`, setup authorization flags, or source migration `--apply` without
  explicit approval for that exact review.
- Treat organization policy as final. Do not work around required sources, allowed origins,
  minimum trust, scope restrictions, or setup capability limits.
- Treat `.agent-artifacts/manifest.json` as installed-state evidence. Do not infer ownership,
  mode, source, or drift from destination files alone.
- Never place credentials in a source URL, command example, generated file, log, or diagnostic.

## Inspect and configure sources

Start with local, non-mutating inspection:

```sh
aart source list --json
aart source health --json
aart source doctor --json
```

Use one of these source kinds:

- `registry-git`: a federated registry with committed lock and compiled index;
- `source-git`: a direct native source in a Git repository;
- `source-local`: a mutable local native source at an absolute path.

After the user approves the exact origin, configure and validate one fresh snapshot:

```sh
aart source add \
  --alias team \
  --kind registry-git \
  --location https://github.example/team/agent-artifacts-registry.git \
  --ref main \
  --default \
  --json
```

Use `--no-default` when the new source should not become the presentation default. A default
registry changes ranking only; it never resolves a collision or shadows another source.

Synchronize existing aliases instead of re-adding them:

```sh
aart source sync --alias team --json
aart source health --alias team --json
```

Synchronization publishes a validated source snapshot. It never changes already installed bytes
or retargets installed symlinks. If `source doctor` reports a pre-1.1 source-store layout, review
its proposed rebinds before authorizing:

```sh
aart source doctor --apply --json
```

No configured source is a valid state for non-content operations. Marketplace and installation
operations fail closed until required sources are configured and healthy. Never substitute the
`aart` executable checkout or its installation directory as an implicit source.

## Interpret health and trust

Keep source health separate from artifact trust:

- Health reports current, stale, offline, invalid, incompatible, or missing source state, plus
  revision and snapshot age.
- `--offline` may use an already validated last-known-good snapshot and verified cached object. It
  must not hide an offline source or fetch missing content.
- Trust is derived locally from configured origin, immutable evidence, registry review, and
  organization policy. Never accept a trust label claimed by an artifact.
- A mutable local source is `local`; a direct Git source is `direct-source`; an approved registry
  entry may be `registry-reviewed`; exact policy-designated registry identity may become
  `company-reviewed`; missing or rejected review is `unverified`.
- User-scope installation may require a higher trust class than project scope.

Use the qualified coordinate and evidence returned by the marketplace:

```text
SOURCE/TYPE/NAME@VERSION
```

An unqualified `TYPE/NAME` is valid only when exactly one configured source provides it.

## Browse and install as an agent

Browse the federated marketplace:

```sh
aart marketplace list --json
```

Summarize source alias and health, qualified coordinate, compatibility, effective trust,
installation risk, installed state, version, and relevant provenance. Keep `unknown` or
`not-scanned` risk visible; do not turn missing evidence into a safety claim.

Review a project-scoped Copy install, then finalize only after approval:

```sh
aart marketplace install \
  team/skill/agent-artifacts@2.0.0 \
  --profile tabnine \
  --project /path/to/project \
  --scope project \
  --mode copy \
  --json

aart marketplace install \
  team/skill/agent-artifacts@2.0.0 \
  --profile tabnine \
  --project /path/to/project \
  --scope project \
  --mode copy \
  --yes \
  --json
```

Choose scope deliberately:

- `project` targets one project directory and is the default;
- `user` targets the selected harness's user configuration and may face stricter trust policy.

Choose mode deliberately:

- `copy` is the default and installs a snapshot whose bytes do not change after source sync;
- `symlink` links eligible tree/file effects to the exact immutable object in AART's managed
  content-addressed store;
- merge and managed-configuration effects remain copies, so a Symlink request may produce mixed
  actual modes;
- source sync never retargets a managed link; only an explicit reviewed update can do that.

Do not describe Symlink as a link into `site-packages`, the executable checkout, a moving Git
branch, or the source's `current` pointer.

## Lifecycle operations

Use the installed record and its exact source subscription:

```sh
aart marketplace status --profile tabnine --scope project --project /path/to/project --json
aart marketplace update --profile tabnine --scope project --project /path/to/project --json
aart marketplace uninstall team/skill/agent-artifacts --profile tabnine \
  --scope project --project /path/to/project --json
```

`marketplace status` executes immediately because it is read-only. Update and uninstall first
produce a review; re-run the approved request with `--yes` to finalize it. Important outcomes
include `current`, `update-available`, `source-unavailable`, `removed-upstream`, `drifted`,
`broken`, `retargeted`, `conflict`, `changed`, and `removed`.

- Status is local and does not fetch.
- Update uses only the source subscription recorded at installation. It never falls through to a
  same-named artifact from another source.
- A missing upstream artifact is preserved unless the user explicitly reviews `--prune`.
- Drift or foreign/retargeted links conflict. Explain the exact ownership evidence before asking
  about `--force`.
- Uninstall removes only proven owned effects and preserves unrelated shared configuration.

## Setup after installation

Setup is a separate reviewed operation after payload installation:

```sh
aart marketplace setup team/mcp/example \
  --profile tabnine \
  --scope project \
  --project /path/to/project \
  --json
```

Review the declared capabilities, trust, custom entrypoint, and every effect. Use
`--approve-setup-effects`, `--authorize-untrusted-source`, or `--authorize-custom-entrypoint` only
when the user explicitly accepts that exact risk, then finalize with `--yes`. Declined or failed
setup does not roll back a successful payload installation.

## Maintain a registry checkout

Run maintainer commands against an explicit writable Git checkout. They never commit or push:

```sh
aart registry format --source .
aart registry lock --source .
aart registry build --source .
aart registry validate --source . --strict --frozen
aart registry audit --source .
aart registry test --source . --compatibility all --latest-version 1.1.1
```

After generating lock/index, use read-only gates to prove the checkout is current:

```sh
aart registry format --source . --check
aart registry validate --source . --strict --frozen
aart registry lock --source . --check
aart registry build --source . --check
aart registry audit --source .
aart registry test --source . --compatibility all --latest-version 1.1.1
```

Edit registry-owned packages under `artifacts/TYPE/NAME`. Keep honest license and provenance:
omit provenance for content owned by this registry, and retain normalized provenance for content
actually imported from elsewhere. Regenerate `aart.lock.json` and `aart.index.json`; never hand-edit
them. Review the Git diff before committing.

CI should install a reviewed AART executable and run the same format, strict/frozen validation,
lock, build, audit, and minimum/latest compatibility gates with read-only repository permissions.

## Handle failures

- `0`: operation completed as described by its structured outcome.
- `1`: generic validation, IO, planning, drift, or health failure. Inspect diagnostics before any
  retry.
- `2`: invalid invocation or selection. Correct the request; do not guess.
- `3`: network/source acquisition failure. Preserve configured and installed state.
- `4`: conflict requiring a newly reviewed force decision.
- `5`: corrupt installed manifest. Stop and ask whether to inspect, back up, restore, or remove it.

If JSON is unavailable on an error path, report the exit code plus sanitized stdout/stderr. Never
retry a mutating command blindly.
