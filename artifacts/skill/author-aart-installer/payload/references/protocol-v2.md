# aart setup protocol version 2

Version 2 is the only revision AART accepts. `schema_version` and `protocol_version` must both
be `2`; a recipe declaring the superseded `1`/`1` pair is refused when the catalog is read, at
publication and at consumption alike. There is no compatibility branch and no automatic upgrade.

Top-level fields are closed-world: `schema_version`, `protocol_version`, `artifact`, `purpose`,
`platforms`, `help_urls`, `required_tools`, `capabilities`, `inputs`, `steps`, and optional
`custom_entrypoint`.

## The manual route

A version-2 recipe lives at `<package>/setup/installer.json`, and its package must carry a regular,
contained, non-empty UTF-8 `SETUP.md` at the **package root** — a sibling of `artifact.json`, not a
file inside `setup/`. AART derives that path from the recipe path; it is not declared in the
descriptor. The document is what a person follows when they decline the automation, so declining is
a supported way to finish rather than a dead end.

`SETUP.md` is an allowed canonical package-root file from AART `2.0.0` onward. Earlier releases
required the document for a version-2 recipe while their package validation refused any file at
that path, so a package could not be valid and publishable at once; a registry publishing this
layout therefore requires `>= 2.0.0`.

Shared modules:

- `macos-keychain.store@1` — `keychain`
- `shell.env-from-keychain@1`, `file.managed-block@1`, `json.managed-merge@1`,
  `directory.create@1` — `filesystem`
- `docker.pull@1` — `docker`, `network`, `process`
- `command.verify@1` — `process`
- `restart.notice@1` — no capability

The runtime plans exact non-secret effects, hashes the canonical plan, asks for granular consent,
applies one installer transaction, verifies, records a redacted receipt, and rolls back completed
reversible effects in reverse order on failure. An item always ends in a terminal status. Queue
failures continue by default; explicit Stop marks unstarted items `skipped`.

A custom entrypoint must begin, after an optional shebang, with the exact line

```text
# AART manual setup: see ../SETUP.md
```

so the manual route is visible when reading the script itself.

Custom entrypoints receive only allowlisted non-secret `AART_SETUP_*` metadata and fixed argv:

```text
install.sh plan --json --result RESULT
install.sh apply --plan-hash HASH --result RESULT
install.sh verify --json --result RESULT
install.sh rollback --receipt RECEIPT --result RESULT
```
