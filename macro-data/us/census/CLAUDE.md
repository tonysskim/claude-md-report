# U.S. Census Bureau Data API

- Read the `US_CENSUS_DATA` service definition from `public_services` in the shared store's `config\providers.json`.
- The Census Data API requires `US_CENSUS_API_KEY` for every data query and permits up to 50 variables per query. The `data.json` dataset-discovery catalogue remains keyless.
- Dot-source `scripts\Invoke-UsCensusDataRequest.ps1` and call `Invoke-UsCensusDataRequest` so requests stay on the official Census Data API host, use GET only, and follow conservative request spacing.
- Do not issue actual data queries until `US_CENSUS_API_KEY` is registered. The helper passes the key internally as required by Census; never display or log the resulting request URL because the key is transmitted in the query string.
- The Census Microdata API is a separate service and requires a key for every data query; do not treat this standard Data API registration as Microdata API authorisation.
- Send requests serially, select only the variables and geographies needed, and avoid broad or bulk queries. Respect HTTP 429 and any service protections.
- If the helper imported an optional key from `.env`, let it remove the process-scoped value when the request finishes.
