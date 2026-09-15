# Bureau of the Fiscal Service Public Data Downloads

- Read the `BUREAU_FISCAL_SERVICE_DOWNLOADS` definition from `public_services` in the shared store's `config\providers.json`. This registration complements, and does not duplicate, the `TREASURY_FISCAL_DATA` REST API.
- Prefer `TREASURY_FISCAL_DATA` whenever an equivalent current machine-readable endpoint exists. Use `BUREAU_FISCAL_SERVICE_DOWNLOADS` for legacy, archival, or programme-specific Excel, CSV, XML, PDF, or ASCII files.
- Dot-source `scripts\Invoke-RegisteredKeylessDataRequest.ps1` and call `Invoke-RegisteredKeylessDataRequest -ServiceAlias BUREAU_FISCAL_SERVICE_DOWNLOADS` so requests stay within the registered Fiscal Service pages and download paths.
- Discover files from the official report page because availability and format vary by programme and year. Record the report name, fiscal year and quarter, preliminary-versus-final status, format, last-updated date, source URL, and retrieval date.
