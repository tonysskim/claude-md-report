# U.S. Macroeconomic Data

- Follow `{{CLAUDE_ROOT}}\MD\macro-data\CLAUDE.md`.
- Read the matching provider folder before collecting from FRED, BEA, BLS, Census, Federal Reserve, housing, or demographic sources.
- For a registered keyless download, read its service definition from `public_services` in `{{CLAUDE_ROOT}}\API\config\providers.json`.
- Dot-source `scripts\Invoke-RegisteredKeylessDataRequest.ps1` and call `Invoke-RegisteredKeylessDataRequest -ServiceAlias <ALIAS>` so requests use HTTPS GET, stay on registered official hosts and path prefixes, follow validated redirects only, and apply conservative spacing and response-size limits.
- For dynamic download links, start from the registered official landing page and select the current file that matches the requested metric, geography, frequency, seasonal-adjustment status, and vintage. Do not guess a stale URL.
- When the registry permits browser fallback after direct-access failure, use the Claude Code browser tools only on the same registered official source. Do not bypass access controls, CAPTCHAs, authentication, subscriptions, or paywalls.
- Send requests serially, retrieve only the data needed, respect HTTP 429 and other service protections, and avoid bulk downloads unless the user explicitly needs them.
