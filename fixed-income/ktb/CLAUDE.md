# Korean Treasury Bonds

- Follow `{{CLAUDE_ROOT}}\MD\fixed-income\CLAUDE.md`.
- Use only registered sources in the shared API store, such as the relevant ECOS, KRX, Databento, or data.go.kr registration, unless the user approves another source.
- For Korean bond issuance and bond master data published by the Financial Services Commission on the 공공데이터포털 (data.go.kr), use the registered `DATA_GO_KR_API_KEY` provider and the collection scripts under `{{CLAUDE_ROOT}}\API\채권발행정보`; operating notes are in `{{CLAUDE_ROOT}}\API\CLAUDE.md`.
- Read the matching provider guidance before collection: `{{CLAUDE_ROOT}}\MD\macro-data\korea\ecos\CLAUDE.md` for ECOS or `{{CLAUDE_ROOT}}\MD\fixed-income\market-data\CLAUDE.md` for Databento.
- Preserve the bond or series identifier, tenor or maturity date, price-versus-yield definition, frequency, unit, market date, and source.
