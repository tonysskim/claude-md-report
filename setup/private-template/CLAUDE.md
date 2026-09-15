# Private Context Guidance

- This directory is local-only and must remain excluded from Git, commits, pushes, shared exports, and public artefacts.
- Summarise personal conversations, preferences, health or financial context, and other sensitive personal information that the user has authorised for retention.
- Preserve meaning, relevant dates, the source task identifier or title, and any user-stated uncertainty. Use the minimum detail required for future usefulness and do not copy full transcripts by default.
- Never store API Keys, passwords, access or refresh tokens, private keys, authentication headers, recovery codes, or other security credentials.
- Avoid storing full account numbers, payment-card numbers, government identifiers, or similarly high-risk identifiers. Use a masked or descriptive reference if the context genuinely requires one.
- Keep confirmed personal context in `PERSONAL_CONTEXT.md`. Keep ambiguous candidates in `PENDING_REVIEW.md` until the user decides how they should be handled.
- After the user resolves an item, apply the decision to the appropriate shared or private MD file and remove the resolved pending entry.
- Treat these files as required current state and do not delete them during routine output cleanup.
