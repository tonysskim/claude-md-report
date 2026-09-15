# 다른 컴퓨터에 Claude Code 작업 환경 옮기기

이 문서는 Claude Code 작업 환경(지침 `MD`, API 도구 `API`, 데이터 워크북 `데이터`)을 같은 Claude 계정을 쓰는 다른 Windows 컴퓨터에 똑같이 만드는 방법입니다. 폴더 구조는 같고, 저장 위치(작업 루트)만 컴퓨터마다 다를 수 있습니다. 저장소 안의 지침은 작업 루트를 `{{CLAUDE_ROOT}}`로 적고, 설치 스크립트가 각 컴퓨터의 실제 경로를 전역 지침에 적어 넣습니다.

## 옮겨지는 것과 옮겨지지 않는 것

| 옮겨짐 | 설명 |
| --- | --- |
| `MD\` | 지침 저장소 전체 (Git 이력 포함, GitHub `tonysskim/MD`) |
| `API\` | 제공기관 레지스트리, 요청 도우미, 기관별 조회 스크립트 (GitHub `tonysskim/API`) |
| `데이터\` | 워크북 프로젝트, 승인 워크북, 스냅샷 (Git LFS 파일 포함, GitHub `tonysskim/data`) |
| 전역 지침 `~\.claude\CLAUDE.md` | 설치 스크립트가 새 컴퓨터의 경로로 생성 |
| Claude 기억 파일 | `MD`·`데이터` 폴더의 시작 기억(사용자 선호, 프로젝트 상태). 이미 있는 파일은 덮어쓰지 않음 |
| `MD\private\` 템플릿 | 빈 개인 맥락·검토 대기 파일 |

| 옮겨지지 않음 | 이유와 대신 할 일 |
| --- | --- |
| `API\.env` (API 키) | 키는 어떤 패키지나 저장소에도 넣지 않습니다. 미리 채울 필요도 없습니다. 작업 중 키가 필요하면 Claude가 그때 물어보고 등록합니다(2026-09-16 결정). 원래 컴퓨터의 `API\.env`를 가져가 새 컴퓨터의 `API\.env`에 두면 묻지 않습니다. |
| `MD\private\` 내용 | 개인 맥락은 컴퓨터마다 따로 둡니다. 필요하면 파일을 직접 복사합니다. |
| 조회 결과 파일 (`output\`, 로그, 캐시) | 다시 실행하면 생깁니다. |
| Claude 세션(채팅) 기록 | 대화 기록에는 채팅에 입력했던 키 등이 그대로 들어 있어 옮기지 않습니다. |
| 텔레그램 자동화 | 사용자 결정으로 제외. claude.ai 커넥터가 계정에 묶여 있어 어느 환경에서든 같은 방식으로 동작합니다. |
| 예약 자동화(daily-md-update) 등록 | 정의 파일(`MD\setup\claude-home\scheduled-tasks\`)만 담겨 있습니다. 새 컴퓨터에도 둘지는 따로 결정합니다. |

## 준비물

- Windows 11과 같은 계정으로 로그인한 Claude 데스크톱 앱(Claude Code)
- 인터넷: 프로그램 설치와 GitHub 방식에 필요합니다. 패키지 방식은 프로그램이 이미 있으면 인터넷 없이도 됩니다.
- 프로그램: Git, Git LFS, GitHub CLI, Python 3. 없으면 설치 스크립트가 winget으로 설치를 시도합니다(관리자 승인 창이 뜰 수 있습니다).
- Excel(선택): 워크북 Excel 재계산·PDF 도구에 필요합니다.
- API 키는 준비하지 않아도 됩니다. 작업 중 필요할 때 Claude가 물어봅니다. (원래 컴퓨터의 `API\.env`를 가져가면 묻지 않습니다.)

## 방법 A. 이식패키지 폴더로 옮기기 (권장, 오프라인 가능)

1. `이식패키지` 폴더 전체를 새 컴퓨터로 복사합니다(USB, 클라우드 등). 위치는 아무 곳이나 됩니다.
2. 새 컴퓨터에서 Claude 데스크톱 앱을 열고, 폴더를 고르지 않은 새 세션을 시작합니다.
3. `BOOTSTRAP-PROMPT.md`의 "방법 A" 메시지를 복사해 붙여넣고, `<패키지 폴더 경로>` 자리를 실제 경로로 바꿔 보냅니다.
4. Claude가 묻는 작업 루트 경로(예: `D:\Claude`)에 답합니다.
5. Claude가 설치 스크립트를 실행하고 결과를 보고합니다.

## 방법 B. GitHub에서 내려받기

1. 새 컴퓨터에서 Claude 데스크톱 앱을 열고 새 세션을 시작합니다.
2. `BOOTSTRAP-PROMPT.md`의 "방법 B" 메시지를 붙여넣어 보냅니다.
3. GitHub 로그인이 되어 있지 않으면 Claude가 `gh auth login`을 안내합니다. 브라우저에서 코드를 입력해 승인합니다(비밀번호는 Claude가 입력하지 않습니다).
4. 나머지는 방법 A와 같습니다.

두 방법은 같은 커밋을 설치하므로 결과가 같습니다. 패키지의 `manifest.json`에 어느 커밋이 담겼는지 적혀 있습니다.

## 설치 후 확인

- Claude Code에서 `<루트>\MD`, `<루트>\API`, `<루트>\데이터`를 각각 작업 폴더로 열어 봅니다. 처음 열 때 폴더 신뢰 확인 창이 한 번 뜹니다.
- `API\scripts\Get-ApiAccessStatus.ps1`로 키 등록 상태를 볼 수 있습니다. 비어 있어도 괜찮습니다. 작업 중 키가 필요하면 Claude가 물어보고 `API\scripts\Set-ApiKey.ps1`로 등록합니다.
- 아무 폴더에서 "작업 루트가 어디야?"라고 물어 전역 지침이 새 경로로 읽히는지 확인합니다.

## 두 컴퓨터를 함께 쓸 때

- 한쪽에서 고친 뒤 Claude에게 "저장소에 올려 줘"(push), 다른 쪽에서 "저장소 최신으로 받아 줘"(pull)라고 합니다. 설치 스크립트를 다시 실행해도 세 저장소를 pull로 갱신합니다.
- 루트 `MD\CLAUDE.md`가 바뀌면 각 컴퓨터에서 `MD\setup\Sync-GlobalGuidance.ps1`을 실행해 전역 지침을 다시 만듭니다. 매일 지침 검토 자동화가 등록된 컴퓨터에서는 그 자동화가 이 일을 합니다.
- 이식패키지를 다시 만들려면 `MD\setup\Build-MigrationPackage.ps1`을 실행합니다. 세 저장소가 커밋·푸시된 상태여야 하며, 패키지는 `<루트>\이식패키지`에 만들어집니다.

## 직접 실행할 때 (PowerShell)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".\Install-ClaudeWorkspace.ps1" -Root "D:\Claude" -EnvFile "E:\.env"
```

옵션: `-Source Package|GitHub`(기본 Auto: `payload` 폴더가 있으면 Package), `-SkipTools`, `-SkipPython`. `-Root`를 빼면 PowerShell 창에서 경로를 물어봅니다.
