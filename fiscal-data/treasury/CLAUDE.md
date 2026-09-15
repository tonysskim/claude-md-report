# U.S. Treasury Fiscal Data API

- Read the `TREASURY_FISCAL_DATA` service definition from `public_services` in the shared store's `config\providers.json`.
- Fiscal Data is the Bureau of the Fiscal Service's open, keyless API. Do not request, invent, or store an API Key or access token for it.
- For Fiscal Data requests, dot-source `scripts\Invoke-TreasuryFiscalDataRequest.ps1` and call `Invoke-TreasuryFiscalDataRequest` so the official base URL, GET-only access, and conservative request spacing are applied consistently.
- Send requests serially by default, request only the necessary fields and rows, and avoid bulk downloads unless the user explicitly needs them.
- The official documentation does not publish a numeric rate limit. Respect HTTP throttling responses and do not bypass service protections.
- When the required historical or programme-specific report is not available through the API, use the related `BUREAU_FISCAL_SERVICE_DOWNLOADS` registration rather than inventing an API endpoint.
- For auction awards by investor class (SOMA add-on, depository institutions, individuals, dealers and brokers, pension and insurance, investment funds, foreign and international, other), use the `US_TREASURY_INVESTOR_CLASS` public service with `Invoke-RegisteredKeylessDataRequest`. Discover the current coupon and bill XLS links from the official landing page (file names carry the release date), keep the release-date vintage, and remember that these are auction allotments rather than holdings.
