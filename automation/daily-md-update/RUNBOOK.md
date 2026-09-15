# Daily Cross-Task MD Update Runbook

## Schedule

- Automation name: `MD 매일 업데이트`
- Scheduler: Claude Code desktop scheduled task `daily-md-update`, registered on 2026-09-14 at the user's request. It runs while the Claude desktop app is open; a run missed because the app or the PC was off starts at the next app launch. The former Codex automation (ID `md`) was not carried over.
- Project: `{{CLAUDE_ROOT}}\MD`
- Recurrence: daily at 09:00
- Time zone: Asia/Seoul

## Purpose

Review newly created or updated Claude Code sessions, identify durable user instructions and verified reusable lessons, maintain authorised personal and sensitive context in local-only MD files, and keep the organised guidance current.

## Incremental state

- State file: `automation\daily-md-update\state.json`
- On the first run, inventory every accessible session returned by the current-session listing and every archived session returned through all available archive pages.
- Page through each accessible task's available history and build a complete baseline. Use deterministic batches when the inventory cannot be completed in one execution, and carry the remaining queue and cursors forward.
- Mark `baselineComplete` only after the full accessible inventory has been reviewed. On later runs, compare task identifiers and update timestamps with the previous successful state and process every new or changed task.
- Update the state only after repository changes and validation succeed.
- Retain only the current state file; do not create dated state copies.

## Classification and routing

| Candidate | Destination |
|---|---|
| Explicit cross-task instruction | Root `CLAUDE.md` or the relevant file under `standards\` |
| Durable domain instruction | Matching domain or provider `CLAUDE.md` |
| Automation-specific behaviour | Matching automation `CLAUDE.md` or `RUNBOOK.md` |
| Verified reusable fact or method | Narrowly scoped `NOTES.md` or provider source guide |
| Personal conversation, preference, or sensitive personal context | Local-only `private\PERSONAL_CONTEXT.md` or a narrower private MD file |
| Security credential or complete high-risk identifier | Never store; retain only a masked or descriptive reference when necessary |
| One-off non-personal requirement or assistant speculation | Do not promote to shared guidance |
| Ambiguous candidate | Add to `private\PENDING_REVIEW.md`, continue other updates, and report for user decision |

For example, a new instruction or verified source-handling lesson from the task titled `미국 물가` belongs under `macro-data\us\` in the narrowest applicable provider folder. The task title itself is not an instruction and must not be used as evidence without reading the relevant user-authored turn.

## Daily procedure

1. Read the root guidance, this automation's `CLAUDE.md`, and applicable standards.
2. If the baseline is incomplete, list all accessible current sessions and page through all archived sessions; otherwise identify every task created or updated since the last successful scan.
3. During baseline review, page through the available history for each queued task. During incremental review, read the changed turns and only the surrounding context needed for safe classification.
4. Apply the trust, privacy, durability, verification, and credential-exclusion rules before editing any MD file.
5. Update the narrowest applicable guidance or notes file and refresh routing or `README.md` only when the structure changed.
6. Only when the root `CLAUDE.md` changed, regenerate `~\.claude\CLAUDE.md` by running `{{CLAUDE_ROOT}}\MD\setup\Sync-GlobalGuidance.ps1`; never copy the root file by hand, because the script expands `{{CLAUDE_ROOT}}` to this computer's path.
7. Validate internal paths, Markdown formatting, British English, design references, duplicate rules, and `git diff --check`.
8. Remove only superseded files and temporary artefacts created by this automation after the newest output is verified.
9. Write the new incremental state only after successful validation.
10. Report meaningful changes, failures, and every item awaiting user review. Continue unambiguous updates even when review items exist.
11. After the user resolves a pending item, apply that decision, remove the resolved queue entry, revalidate all affected files, and report the result.

## Boundaries

- Do not access an external provider that is not registered in the shared API Key store without prior user approval.
- Store authorised personal and sensitive context only under the Git-ignored `private\` directory. Never copy API Keys, passwords, tokens, private keys, authentication headers, recovery codes, or full conversation transcripts into the repository.
- Treat the current private context and pending-review files as required state; do not remove them during routine output cleanup.
- Do not commit or push changes unless the user explicitly requests it.
- Preserve unrelated user changes and stop for review when edits would overlap or overwrite them.
- Do not claim that every conversation was screened when the app reports an unavailable host or source, a conversation is deleted or inaccessible, or a listing surface does not expose it. Report the limitation and continue with the accessible inventory.
