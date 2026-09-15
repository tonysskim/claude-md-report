# U.S. Bureau of Economic Analysis API

- Use the registered `BEA_API_KEY` alias for BEA Data API access.
- Dot-source `scripts\Invoke-BeaApiRequest.ps1` and call `Invoke-BeaApiRequest` so the key is added only inside the request process and is not exposed in displayed URLs, logs, or error messages.
- Keep BEA calls serial and below the official limits of 100 requests per minute, 100 MB per minute, and 30 errors per minute.
- Respect HTTP 429 and its `Retry-After` value. Avoid broad `ALL` or `X` requests unless the task requires them, and request only the necessary dataset, periods, and dimensions.
- If the helper imported keys from `.env`, let it clear every imported process-scoped key when the request finishes.
