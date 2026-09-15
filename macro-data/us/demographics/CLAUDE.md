# Registered U.S. Demographic Data

- Use `US_STATE_DEPARTMENT_VISA_STATISTICS` through its registered service definition and the approved keyless download helper.
- Direct HTTP requests to the State Department page return HTTP 403 (confirmed 2026-09-13 and 2026-09-14), and the registry permits browser fallback for this service. Open the registered official landing page with the Claude Code browser tools, download the monthly file from there, and record that the browser route was used. Do not bypass access controls or CAPTCHAs.
- State Department monthly immigrant-visa files are preliminary. Do not sum post-2020 monthly issuance files into final fiscal-year totals; use the annual Report of the Visa Office for final totals.
- Preserve visa category, post or country, reference month or fiscal year, preliminary-versus-final status, units, source URL, and retrieval date.
