# White House OMB and Congressional Budget Office Data

## White House Office of Management and Budget

- Read the `WHITE_HOUSE_OMB_BUDGET_DATA` definition from `public_services` in the shared store's `config\providers.json`. OMB budget files are public and keyless; no verified official public API is registered for them.
- Dot-source `scripts\Invoke-RegisteredKeylessDataRequest.ps1` and call `Invoke-RegisteredKeylessDataRequest -ServiceAlias WHITE_HOUSE_OMB_BUDGET_DATA` so requests remain on the registered White House hosts and OMB budget paths.
- Discover the current fiscal-year links from the Historical Tables, Analytical Perspectives, or Supplemental Materials page. File names and year suffixes change by release, so do not guess a URL from an older vintage.
- Prefer one table workbook for a narrow request. Download the full Historical Tables ZIP only for broad multi-table work. For the Public Budget Database, read the current user's guide before interpreting account-level codes.
- Preserve the budget fiscal year, publication or revision date, table number, units, actual-versus-estimate status, source URL, and retrieval date.

## Congressional Budget Office

- Read the `CBO_OPEN_DATA` service definition from `public_services` in the shared store's `config\providers.json`.
- CBO's Open Data Repository on the official `US-CBO` GitHub organisation is public and keyless. Do not request, invent, or store an API Key or access token for it.
- Dot-source `scripts\Invoke-CboOpenDataRequest.ps1` and call `Invoke-CboOpenDataRequest` so requests stay on the official raw repository host, use GET only, and follow conservative request spacing.
- Use `catalog.json` to discover available datasets and file paths instead of guessing paths. Read each dataset's `schema.json` before interpreting variables, units, frequencies, or actual-versus-projected values.
- Prefer a specific published vintage for reproducible work. Use the newest vintage only when the task calls for current data, and report the selected vintage or file path with the result.
- The canonical source remains CBO's Budget and Economic Data page. Preserve CBO attribution when using or publishing data from the GitHub repository.
- Send requests serially and retrieve only the CSV or JSON files needed. No numeric rate limit is published for this distribution channel; respect HTTP 429 and GitHub service protections and avoid cloning or bulk downloading unless the task requires it.
