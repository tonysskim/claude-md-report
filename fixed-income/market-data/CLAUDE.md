# Fixed-Income Market Data

## Federal Reserve Bank of New York Markets Data APIs

- Read the `NEW_YORK_FED_MARKETS` service definition from `public_services` in the shared store's `config\providers.json`.
- New York Fed Markets Data APIs are public and keyless. Do not request, invent, or store an API Key or access token for them.
- For Markets Data API requests, dot-source `scripts\Invoke-NewYorkFedMarketsRequest.ps1` and call `Invoke-NewYorkFedMarketsRequest` so only the official production host, GET requests, and conservative request spacing are used.
- Send requests serially, request only the rows and fields needed, avoid beta endpoints for production work, and avoid bulk downloads unless the user explicitly needs them.
- The official API documentation does not publish a numeric rate limit. Respect HTTP 429 and other service protections; do not bypass throttling.
- Use of New York Fed reference rates, including SOFR, is subject to the New York Fed Terms of Use. Preserve source attribution and review the current terms before publishing or redistributing reference-rate data.

## Databento Historical API

- Use the registered `DATABENTO_API_KEY` alias for Databento Historical API access.
- Dot-source `scripts\Invoke-DatabentoRequest.ps1` and call `Invoke-DatabentoRequest`; it restricts requests to the official historical API host, keeps credentials out of URLs and output, and clears any key it imported from `.env`.
- Metadata, symbology, and account-management requests are free. Time-series data and batch submissions can incur usage charges; estimate cost with `metadata.get_cost` first and do not issue billable or duplicate data requests without the user's explicit authorisation.
- Keep calls serial and within the official per-IP limits: 100 concurrent connections, 100 time-series requests per second, 100 symbology requests per second, 20 metadata requests per second, 20 batch-list requests per second, and 20 batch submissions per minute.
- Respect HTTP 429 and `Retry-After`. Request only the necessary symbols, schemas, date ranges, and rows, and avoid bulk downloads unless the user explicitly needs them.
- Never expose the HTTP Basic Authorization header or the API Key used as its username. If the helper imported the key from `.env`, let it remove the process-scoped value when the request finishes.

## Federal Reserve Bank of New York Research and Operations Pages

- Use `NEW_YORK_FED_RESERVE_DEMAND_ELASTICITY` (registered 2026-09-15) for the Reserve Demand Elasticity Chart Data workbook: read `downloads.json` first and follow the `Href` it gives rather than guessing the file path. The series is a weekly model estimate with percentile bands, not an observed rate; label it as an estimate and keep the observation date and percentile.
- Use `NEW_YORK_FED_TREASURY_OPERATIONS` (registered 2026-09-15) for the Treasury Securities Operational Details page (monthly reinvestment and reserve management purchase limits). Carry a period's limit across every date in the period; "no reserve management purchases" means zero, not missing.
- SOMA holdings and release logs come from `NEW_YORK_FED_MARKETS` (`/api/soma/...`), not from these pages. When a SOMA as-of date has no release-log entry, an inferred release date must be marked as inferred.
