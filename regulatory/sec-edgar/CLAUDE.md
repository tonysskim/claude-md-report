# SEC EDGAR Public Data

- Read keyless public services from `public_services` in the shared store's `config\providers.json`.
- SEC EDGAR public data requires no API Key. Set the declared request identity in `SEC_EDGAR_USER_AGENT`, and never substitute EDGAR Next filer or user tokens for public-data access.
- For `data.sec.gov` requests, dot-source `scripts\Invoke-SecEdgarRequest.ps1` and call `Invoke-SecEdgarRequest` so the declared User-Agent and conservative request spacing are applied consistently.
- Keep SEC EDGAR traffic below the official maximum of 10 requests per second, send requests serially by default, and download only the data needed for the task.
- Do not print or log the contact identity unless the user explicitly asks to inspect it.
