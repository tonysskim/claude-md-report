# U.S. Bureau of Labor Statistics Public Data API

- Read the `BLS_PUBLIC_DATA` service definition from `public_services` in the shared store's `config\providers.json`.
- Use the registered `BLS_API_KEY` for expanded BLS limits. The API also remains compatible with keyless public requests when no registered key is available.
- Dot-source `scripts\Invoke-BlsPublicDataRequest.ps1` and call `Invoke-BlsPublicDataRequest` so the key is added only inside the request process and is not exposed in output, logs, or error messages.
- With the registered key, stay within 500 queries per day, 50 series per query, 20 years per query, and 50 requests per 10 seconds. Send requests serially and retrieve only the series and periods needed.
- If the helper imported keys from `.env`, let it clear every imported process-scoped key when the request finishes.
