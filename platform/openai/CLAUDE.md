# OpenAI API

- Follow `{{CLAUDE_ROOT}}\MD\standards\DATA_ACCESS.md`.
- Use the registered `OPENAI_API_KEY` alias for OpenAI API access at `https://api.openai.com/v1`.
- Prefer the existing process environment variable. If it is unavailable, dot-source `scripts\Import-ApiKeys.ps1`, call `Import-ApiKeys -RequiredKeys OPENAI_API_KEY`, and keep the import and the API consumer in the same PowerShell process.
- Send the key only with HTTP Bearer authentication to the official `api.openai.com` host. Never expose it in command-line arguments, URLs, source files, browser or client-side code, output, logs, or error messages.
- For a small read-only credential check, run `scripts\Test-OpenAiApi.ps1`, which calls `GET /v1/models` without requesting billable model generation.
- OpenAI API limits vary by organisation, project, usage tier, model, and endpoint. Respect the returned rate-limit headers and do not bypass throttling. Keep requests scoped to the user's task, and obtain explicit authorisation before unusually costly or bulk API operations.
- When a helper imported the key from `.env`, clear every imported process-scoped key in a `finally` block with `Clear-ImportedApiKeys`.
