# 다른 컴퓨터 Claude Code에 붙여넣을 첫 메시지

아래 두 메시지 중 하나를 새 컴퓨터의 Claude Code 새 세션(폴더 없음)에 붙여넣습니다. `<...>` 자리는 실제 값으로 바꿉니다.

## 방법 A. 이식패키지 폴더로

```text
이 컴퓨터에 내 Claude Code 작업 환경을 설치해 주세요. 이식패키지 폴더 위치: <패키지 폴더 경로>

진행 순서:
1. 패키지 폴더의 README.md와 manifest.json을 읽으세요.
2. 나에게 작업 루트 경로를 물어보세요 — 예: D:\Claude (기본 제안: 내 사용자 폴더 아래 Claude).
3. 답을 받으면 PowerShell로 실행하세요:
   powershell -NoProfile -ExecutionPolicy Bypass -File "<패키지 폴더 경로>\Install-ClaudeWorkspace.ps1" -Root "<작업 루트>"
   필요한 프로그램(Git, Git LFS, GitHub CLI, Python)이 없으면 스크립트가 winget으로 설치합니다. 관리자 승인 창이 뜨면 알려 주세요.
4. API 키는 미리 묻지 마세요. 나중에 작업 중 키가 필요해지면 그때 나에게 물어보면 됩니다. (원래 컴퓨터의 .env 파일을 가져왔다면 내가 먼저 말하겠습니다.)
5. 결과를 한국어로 짧게 보고하세요: 설치 위치, 저장소 3개의 커밋, 주의사항.
6. 예약 자동화(daily-md-update)는 등록하지 마세요. 이 컴퓨터에도 등록할지 나에게 따로 물어보세요.
7. 마지막으로 Claude Code에서 열어야 할 폴더 3개(<작업 루트>\MD, API, 데이터)를 알려 주세요.
```

## 방법 B. GitHub에서

```text
이 컴퓨터에 내 Claude Code 작업 환경을 GitHub에서 내려받아 설치해 주세요. 저장소: tonysskim/MD, tonysskim/API, tonysskim/data (모두 비공개).

진행 순서:
1. gh auth status로 GitHub 로그인 상태를 확인하세요. 로그인이 안 되어 있으면 gh auth login을 실행하고, 브라우저에서 코드를 입력하도록 안내하세요. GitHub CLI나 Git이 없으면 winget으로 먼저 설치하세요.
2. 나에게 작업 루트 경로를 물어보세요 — 예: D:\Claude (기본 제안: 내 사용자 폴더 아래 Claude).
3. 답을 받으면 실행하세요:
   gh repo clone tonysskim/MD "<작업 루트>\MD"
   powershell -NoProfile -ExecutionPolicy Bypass -File "<작업 루트>\MD\setup\Install-ClaudeWorkspace.ps1" -Root "<작업 루트>" -Source GitHub
4. API 키는 미리 묻지 마세요. 나중에 작업 중 키가 필요해지면 그때 나에게 물어보면 됩니다. (원래 컴퓨터의 .env 파일을 가져왔다면 내가 먼저 말하겠습니다.)
5. 결과를 한국어로 짧게 보고하세요: 설치 위치, 저장소 3개의 커밋, 주의사항.
6. 예약 자동화(daily-md-update)는 등록하지 마세요. 이 컴퓨터에도 등록할지 나에게 따로 물어보세요.
7. 마지막으로 Claude Code에서 열어야 할 폴더 3개(<작업 루트>\MD, API, 데이터)를 알려 주세요.
```

## 설치 뒤 자주 쓰는 말

- "저장소 최신으로 받아 줘" — 세 저장소를 GitHub에서 pull 합니다.
- "저장소에 올려 줘" — 이 컴퓨터에서 고친 내용을 GitHub에 push 합니다.
- "전역 지침 다시 만들어 줘" — `MD\setup\Sync-GlobalGuidance.ps1`을 실행합니다.
- "이식패키지 다시 만들어 줘" — `MD\setup\Build-MigrationPackage.ps1`을 실행합니다.
