# Generated Artifact Retention and Cleanup

- After an automation, update, or artifact-generation task succeeds, keep only the newest verified final output and any files that are required by that output or by the active task.
- Delete superseded generated versions, obsolete exports, previews, temporary files, intermediate artifacts, and tool caches created for the task after confirming that the replacement output exists and is usable.
- When a task legitimately produces multiple current deliverables or formats, treat that required set as the newest final output and retain all of them.
- Restrict cleanup to Claude Code-generated files inside the task's explicitly designated output directory. Never delete user-provided inputs, reference files, source repositories, configuration, credentials, the shared API Key store, or files belonging to unrelated tasks.
- Before any recursive cleanup, resolve and verify the exact absolute target. Never use a workspace root, user directory, unresolved variable, or broad wildcard as a deletion target.
- If generated files cannot be distinguished reliably from user-owned files, or if the newest output has not been verified, do not delete them; ask the user before proceeding.
- After deleting material files, report what was removed and whether recovery is available.
- Do not create parallel `old`, `archive`, `v1`, or `v2` copies merely to preserve superseded content. Keep one current working file and use Git history when revision history is required.
