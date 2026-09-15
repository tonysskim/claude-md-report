# Federal Reserve Economic Data

- Use the registered `FRED_API_KEY` alias and the provider definition in the shared store's `config\providers.json`.
- Follow the shared import and credential-handling flow in `{{CLAUDE_ROOT}}\MD\standards\DATA_ACCESS.md`.
- Request only the series, observation periods, and output fields required for the task.
- Preserve the FRED series identifier, title, frequency, unit, seasonal-adjustment status, observation period, release or vintage information when applicable, and retrieval date.
