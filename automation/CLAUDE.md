# Automation Guidance

- Follow the repository root guidance and all applicable shared standards.
- Read the automation's own `CLAUDE.md` and `RUNBOOK.md` before creating, updating, running, or troubleshooting it.
- Keep the trigger, schedule, time zone, inputs, registered data sources, output location, notification policy, failure behaviour, and owner decision points explicit in the runbook.
- Keep only the newest verified output set and state files required for the next run. Remove superseded previews, exports, temporary files, and tool caches after successful verification.
- Do not change a live schedule, destination, notification policy, or external side effect unless the user requests that change.
- Before registering, changing, or running any scheduled automation, ask the user about that specific automation and wait for the answer. Never treat one approval as covering several automations. This remains in force despite the general standing approval in the root guidance.
- For the daily cross-task guidance review, read `daily-md-update\CLAUDE.md` and `daily-md-update\RUNBOOK.md`.
