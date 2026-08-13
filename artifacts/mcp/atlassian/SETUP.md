# Atlassian Rovo MCP setup

Prefer Atlassian's OAuth 2.1 flow for interactive use. The official current endpoint is:

```text
https://mcp.atlassian.com/v1/mcp/authv2
```

The declarative setup v2 recipe is an optional non-interactive service-account route. It asks
macOS Keychain to prompt for the service-account API key, stores no credential in AART state or
arguments, and adds a managed `.zshrc` lookup for `ATLASSIAN_API_KEY`. Start a new shell and
restart the harness afterwards. Your organization administrator must enable API-token
authentication.

References:

- https://support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/
- https://support.atlassian.com/atlassian-rovo-mcp-server/docs/configuring-authentication-via-api-token/
- https://id.atlassian.com/manage-profile/security/api-tokens

The recipe is reviewed before it can run. The secret is entered only by the human at the
Keychain-owned prompt; it is never part of this package, installation state, or AART output.
