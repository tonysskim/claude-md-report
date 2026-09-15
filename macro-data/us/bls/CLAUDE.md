# U.S. Bureau of Labor Statistics Public Data API

- Read the `BLS_PUBLIC_DATA` service definition from `public_services` in the shared store's `config\providers.json`.
- Use the registered `BLS_API_KEY` for expanded BLS limits. The API also remains compatible with keyless public requests when no registered key is available.
- Dot-source `scripts\Invoke-BlsPublicDataRequest.ps1` and call `Invoke-BlsPublicDataRequest` so the key is added only inside the request process and is not exposed in output, logs, or error messages.
- With the registered key, stay within 500 queries per day, 50 series per query, 20 years per query, and 50 requests per 10 seconds. Send requests serially and retrieve only the series and periods needed.
- If the helper imported keys from `.env`, let it clear every imported process-scoped key when the request finishes.

## CPI Relative Importance Tables

- Use `BLS_CPI_RELATIVE_IMPORTANCE` (registered 2026-09-15) for the CPI relative importance and expenditure weight tables. It is a separate keyless registration from the `BLS_PUBLIC_DATA` API; do not request or store an API Key for it.
- Direct HTTPS requests from scripts return HTTP 403 because `www.bls.gov` applies bot protection. Use the Claude Code browser tools on the same registered official pages, where the archive zip can also be read in-page. A 403 is never a reason to fall back to an unofficial mirror or a cached third-party copy.
- Download links change each year. Start from the official landing page `https://www.bls.gov/cpi/tables/relative-importance/home.htm` and select the current file for the requested year rather than reusing a stale URL.
- Preserve the weight reference period, the population base (CPI-U or CPI-W), the item structure level, whether the figures are relative importance or expenditure weights, the source URL, and the retrieval date. Weights are revised on the published schedule, so never carry an older vintage forward without labelling it.
- Keep requests serial with at least one second of spacing, and retrieve only the years and item levels needed.
- The workbook project that uses this source is `{{CLAUDE_ROOT}}\데이터\미국 물가`.
