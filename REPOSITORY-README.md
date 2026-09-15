# Claude Code Markdown Guidance Repository

This repository is the canonical home for shared Claude Code guidance, domain-specific instructions, design standards, automation runbooks, and reusable artifact templates.

## Structure

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Compact shared rules and routing to the relevant domain guidance |
| `standards/` | Language, design, data-access, and file-retention standards |
| `macro-data/` | Macroeconomic data guidance grouped by geography and provider |
| `fiscal-data/` | Fiscal, budget, Treasury, CBO, OMB, and TIC guidance |
| `fixed-income/` | KTB, UST, reference-rate, and historical market-data guidance |
| `regulatory/` | Regulatory and filing-data guidance, including SEC EDGAR |
| `platform/` | Platform-specific guidance such as OpenAI API access |
| `automation/` | Automation-specific instructions and runbooks, including the daily cross-task MD update |
| `templates/` | Current reusable templates for generated artifacts |
| `setup/` | Installer, global-guidance generator, migration-package builder, install guide, and the seed memory and private-folder templates for another computer |
| `private/` | Local-only personal context and pending-review queue; excluded from Git |

## Operating model

- Keep universal rules in the root `CLAUDE.md` and the detailed shared standards under `standards/`.
- Before a domain task, read the routed domain `CLAUDE.md`; then read a provider-specific file only when that provider is used.
- Do not copy API Keys or credentials into this repository. The provider registry, request helpers, and registration tools live in `{{CLAUDE_ROOT}}\API`; keys live only in its Git-ignored `.env` file.
- Write the workspace root as `{{CLAUDE_ROOT}}` in every guidance file so the same repository works on any computer; scripts derive paths from their own location. The generated global copy is the only file that holds the real path.
- Keep only current files in the working tree. Use Git history instead of duplicate versioned or archive files.
- Keep authorised personal and sensitive context under the Git-ignored `private/` directory. Never store security credentials or full high-risk identifiers.
- Create a new provider or automation folder only when it has actionable instructions, a runbook, a template, or another file that must be maintained.

## Active global copy

The effective global guidance at `~\.claude\CLAUDE.md` is generated from the root `CLAUDE.md` by `setup\Sync-GlobalGuidance.ps1`, which expands `{{CLAUDE_ROOT}}` to this computer's workspace root. Rerun the script after every root change instead of editing the global copy.

## 다른 컴퓨터로 옮기기

방법과 순서는 [setup/INSTALL.md](setup/INSTALL.md)에, 새 컴퓨터의 Claude Code에 붙여넣을 첫 메시지는 [setup/BOOTSTRAP-PROMPT.md](setup/BOOTSTRAP-PROMPT.md)에 있습니다. 두 가지 길이 있고 결과는 같습니다.

- 이식패키지 폴더(`{{CLAUDE_ROOT}}\이식패키지`, `setup\Build-MigrationPackage.ps1`로 생성)를 직접 복사해 `Install-ClaudeWorkspace.ps1`을 실행
- GitHub에서 `tonysskim/MD`를 내려받은 뒤 `MD\setup\Install-ClaudeWorkspace.ps1 -Source GitHub`를 실행

비공개 저장소 `tonysskim/MD`(이 폴더)와 `tonysskim/API`(`{{CLAUDE_ROOT}}\API`)는 2026-09-14에 만들었습니다. 데이터 폴더(`{{CLAUDE_ROOT}}\데이터`)는 2026-09-14에 비공개 저장소 `tonysskim/data`로 올렸습니다. GitHub가 한글 저장소 이름을 허용하지 않아 `데이터` 대신 `data`를 씁니다.

설치 스크립트는 세 저장소를 놓고(이미 있으면 pull로 갱신), Git LFS와 Python 패키지를 준비하고, 전역 지침을 새 경로로 생성하며, `API\.env`가 없으면 빈 파일을 만들고 등록이 필요한 키를 알려 줍니다. API 키, `private\` 내용, 세션 기록, 텔레그램 설정, 예약 자동화 등록은 옮기지 않습니다.
