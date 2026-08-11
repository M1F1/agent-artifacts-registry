---
name: author-aart-installer
description: Design, validate, and test a reviewed declarative setup/installer.json for a directory-shaped AART package in a configured native source or federated registry. Use when a source or registry maintainer needs Keychain, managed files, JSON, directories, pinned Docker, verification, restart notices, or an explicitly reviewed custom setup entrypoint, and when the resulting package must pass AART registry compilation and compatibility gates.
---

# Author an AART setup installer

Create setup as a reviewed data contract inside the artifact package that owns it. The `aart`
executable does not bundle this package or a catalog; consumers obtain it from an explicitly
configured `registry-git`, `source-git`, or `source-local` source.

## Workflow

1. Work in an explicit writable source or registry checkout, not AART's managed immutable snapshot
   or object store. Identify the containing artifact as `TYPE/NAME`; only directory-shaped skills,
   hooks, and MCP packages support setup.
2. For a registry-owned package, locate it at `artifacts/TYPE/NAME`. Copy
   `assets/installer.template.json` to `<package>/setup/installer.json` and make its `artifact`
   identity exactly `TYPE/NAME`.
3. Use `assets/installer.schema.json` as the authoring schema. Declare the smallest capability set
   and prefer shared version-1 modules to custom code.
4. Put only documentation links in `SETUP.md`. Use credential-free HTTPS URLs and explain restart,
   platform, environment, and external-tool limitations.
5. Validate the descriptor with this skill's strict parser from the registry root:

   ```sh
   python artifacts/skill/author-aart-installer/payload/scripts/validate_installer.py \
     artifacts/mcp/example/setup/installer.json mcp/example
   ```

6. Regenerate and validate the complete registry through the installed AART executable:

   ```sh
   aart registry format --source .
   aart registry lock --source .
   aart registry build --source .
   aart registry validate --source . --strict --frozen
   aart registry audit --source .
   aart registry test --source . --compatibility all --latest-version 1.1.1
   ```

   Run format/lock/build again with `--check` after regeneration. Never hand-edit
   `aart.lock.json` or `aart.index.json`.
7. Test with temporary homes and fake Keychain, Docker, filesystem, and process adapters. Search
   every captured argv, environment, result, error, state, receipt, backup, stdout, and stderr for
   a synthetic canary secret.
8. Exercise the artifact from a configured test source. For agents, use CLI/JSON and first review
   without `--yes`:

   ```sh
   aart source health --json
   aart marketplace install SOURCE/mcp/example --profile tabnine \
     --scope project --mode copy --json
   aart marketplace setup SOURCE/mcp/example --profile tabnine \
     --scope project --json
   ```

   Re-run an approved plan with `--yes`. A person may instead use the TUI Sources, Marketplace,
   Review, and Setup stages. Test both project/user scope when declared and both Copy/Symlink when
   declared; setup remains a separate post-install operation in either mode.

## Trust and authorization

- Inspect source health and effective trust before setup. Trust is derived locally from configured
  source identity, registry review evidence, and organization policy; it is never self-declared by
  the artifact.
- Treat missing risk evidence as `unknown`, not safe.
- An untrusted source requires an explicit `--authorize-untrusted-source` decision.
- A custom entrypoint requires explicit `--authorize-custom-entrypoint` and remains reviewed code,
  not a sandbox.
- Each declared setup effect requires review and `--approve-setup-effects`; do not add any of these
  flags automatically.
- User-scope policy may require stronger trust or prohibit capabilities accepted at project scope.

## Installer rules

- Secret inputs may be referenced only by `macos-keychain.store@1`. Let the macOS `security`
  program own the hidden prompt; never pass a secret value through argv or environment.
- Docker images require `@sha256:<64 hex>` and the `docker`, `network`, and `process` capabilities.
- Commands are fixed argv arrays. Never use a shell string, `curl | sh`, secret interpolation, or
  a broad inherited environment.
- File targets cannot traverse with `..`; runtime adapters reject symlinks and preserve unrelated
  content.
- A custom entrypoint is a direct child of `setup/`, requires `custom-code` and `process`, and
  implements `plan`, `apply`, `verify`, and `rollback`.
- Non-macOS hosts record `unsupported` before invoking effect adapters.
- The runtime plans non-secret effects, binds the review digest, applies one installer transaction,
  verifies, records a redacted receipt, and rolls back completed reversible effects on failure.
- Payload installation success remains valid when setup is declined or incomplete.

See `references/protocol-v1.md` for the shared modules and lifecycle contract.
