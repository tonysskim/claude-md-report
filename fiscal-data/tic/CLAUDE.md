# U.S. Treasury International Capital System

- Read the `US_TREASURY_TIC` definition from `public_services` in the shared store's `config\providers.json`. TIC is separate from the existing `TREASURY_FISCAL_DATA` API.
- TIC public statistics require no API Key. Do not request, invent, or store an API Key or access token for them.
- Dot-source `scripts\Invoke-RegisteredKeylessDataRequest.ps1` and call `Invoke-RegisteredKeylessDataRequest -ServiceAlias US_TREASURY_TIC` so requests remain on the registered Treasury hosts, use HTTPS GET, and apply conservative request spacing and size limits.
- Start from the official TIC landing page and select the table that matches the requested concept. Prefer the smallest suitable HTML, tab-delimited TXT, or CSV file. Download the CSLT ZIP or annual survey packages only when the task explicitly requires their broader coverage.
- Distinguish holdings, transactions, valuation changes, banking claims and liabilities, derivatives, and annual survey data. Do not combine series across the February 2023 expanded-Form-SLT break without checking the table notes and definitions.
- TIC country attribution may reflect the immediate counterparty or custodian rather than the ultimate beneficial owner. Preserve this limitation when interpreting Major Foreign Holders or country-level data.
- Monthly TIC releases can be revised. Record the table name, reference month, retrieval date, units, seasonal-adjustment status when applicable, and whether observations are preliminary or revised.
