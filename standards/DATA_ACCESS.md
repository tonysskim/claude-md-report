# External Data Access and API Key Standard

## Data collection source scope

- For external data collection, first use only the providers, public services, aliases, official API base URLs, and request helpers registered in `{{CLAUDE_ROOT}}\API\config\providers.json`.
- Use the registered API Key flow when a source requires authentication, and the registered keyless public-service flow when the source supports access without an API Key.
- If the required data is unavailable from the registered sources, or a different website or institution is needed, use the official or primary public source without asking first (standing approval given by the user on 2026-09-15). Record the source URL and retrieval date, and tell the user which unregistered source was used. Add the source to the registry when it is likely to be reused.
- Standing approval does not permit bypassing access controls, CAPTCHAs, authentication, subscriptions, or paywalls, or entering credentials on the user's behalf.
- These restrictions apply to external data collection. They do not prevent reading user-provided files or files in the active workspace when needed for the requested task.

## Shared API store

- The shared API store is `{{CLAUDE_ROOT}}\API`. It holds the registry (`config\providers.json`, `config\registration.json`), the request helpers and connection tests (`scripts\`), per-institution collection scripts in their own folders, and the single key file `.env`.
- Every API Key and request identity lives only in `.env`, one `ALIAS=value` line each. The aliases are the `alias` values in `config\providers.json` and the `identity_environment_variable` values of public services. `.env` is excluded from Git and must never be copied into another repository, document, or message.
- When a task needs an API Key, either read the alias line from `.env` inside the consuming script, or dot-source `scripts\Import-ApiKeys.ps1`, call `Import-ApiKeys -RequiredKeys <ALIAS>`, and run the API consumer in that same PowerShell process. The helper loads `.env` values into the process environment and accepts an existing process variable when `.env` has no value.
- Never print, echo, serialise, log, or place an API Key in source code, command-line arguments, URLs shown to the user, JSON, CSV, README files, or error messages.
- Clear keys the helper imported in a `finally` block with `Clear-ImportedApiKeys` when the task finishes.
- When a task needs a key that is not in `.env`, ask the user for it at that moment, naming the provider, the alias, and the registration page (user decision, 2026-09-16). Register the value the user gives with `scripts\Set-ApiKey.ps1 -Alias <ALIAS> -Value <key>` (or the hidden prompt when the user prefers), never repeat it in output, files, or reports, remove keys only with `scripts\Remove-ApiKey.ps1`, and run the provider's read-only connection test after registration or replacement.
- Do not demand a prepared `.env` file when setting up another computer; keys are requested from the user as tasks need them.
- Preserve existing registry entries when adding a provider. A new provider needs an `alias`, `official_api_base`, authentication method, and a connection test before it is used.
- Operating notes for each institution (endpoints, parameters, known quirks) are kept in `{{CLAUDE_ROOT}}\API\CLAUDE.md`; data-handling rules per domain are in the domain `CLAUDE.md` files of this repository.
