# Codex 지침 이식 기록

이식일: 2026-09-14 · Asia/Seoul
원본: `C:\Users\<사용자>\Documents\ChatGPT\MD` (GitHub `tonysskim/codex-guidance`)
대상: `{{CLAUDE_ROOT}}\MD`
근거 문서: `C:\Users\<사용자>\Documents\ChatGPT\MD\codex_inventory.md`

원본 파일과 Codex 설정은 변경하지 않았다. 이 폴더와 `~\.claude\CLAUDE.md`만 새로 만들었다. 비밀값은 어디에도 복사하지 않았다.

## 변환 규칙

| 원본 | 대상 |
| --- | --- |
| 각 폴더의 `AGENTS.md` | 같은 폴더의 `CLAUDE.md` (Claude Code는 작업 폴더와 상위·하위 폴더의 `CLAUDE.md`를 읽는다) |
| `C:\Users\<사용자>\Documents\ChatGPT\MD\...` 경로 | `{{CLAUDE_ROOT}}\MD\...` |
| 전역 `C:\Users\<사용자>\.codex\AGENTS.md` | 전역 `~\.claude\CLAUDE.md` (루트 `CLAUDE.md`와 동일 내용) |
| "Codex" 표기 | "Claude Code" (단, `codex-api`·`codex-data` GitHub 저장소 이름은 그대로) |
| `setup\Install-CodexWorkspace.ps1` | `setup\Install-ClaudeWorkspace.ps1` (전역 `CLAUDE.md` 복사 단계 추가) |
| 설치 스크립트 인코딩 | UTF-8 BOM 추가. 원본은 BOM이 없어 Windows PowerShell 5.1 파서에서 한글 문자열 줄(19행·61행)이 구문 오류로 잡혔다. 이식본은 파서 검사를 통과했다. |
| `macro-data\us`의 "Codex browser" | "Claude Code browser tools" |
| `automation\daily-md-update`의 Codex 작업 목록·ChatGPT 대화 | Claude Code 세션 목록 |

그대로 둔 외부 참조: 공용 인증 저장소 `C:\Users\<사용자>\Documents\ChatGPT\API_Keys`와 그 안의 `config\providers.json`·`scripts\*.ps1` 헬퍼, 디자인 참조 `C:\Users\<사용자>\Documents\네이트온 받은 파일\보고서 색상 팔레트.dc.html`. 같은 PC·같은 Windows 사용자이므로 DPAPI 암호화 키 저장소를 Claude Code에서도 그대로 쓸 수 있다.

## 이식한 것

- 루트 `CLAUDE.md`, `README.md`, `.gitignore`
- `standards\` 4개 (LANGUAGE, DESIGN_SYSTEM, DATA_ACCESS, FILE_RETENTION)
- `macro-data\` 14개, `fiscal-data\` 6개, `fixed-income\` 4개, `regulatory\` 2개, `platform\` 2개, `templates\` 5개의 `CLAUDE.md`·`README.md`
- `automation\CLAUDE.md`, `automation\daily-md-update\` (CLAUDE, RUNBOOK, 새 `state.json`), `automation\eern\` (CLAUDE, RUNBOOK)
- `private\CLAUDE.md`와 `private\PERSONAL_CONTEXT.md`·`private\PENDING_REVIEW.md` (원본 그대로 복사, Git 제외 유지)
- `setup\Install-ClaudeWorkspace.ps1`

## 이식하지 않은 것

- `automation\telegram\` 전체 — 사용자 지시로 제외. 루트 `CLAUDE.md`의 자동화 라우팅 문장에서도 Telegram을 뺐다. Claude 쪽 Telegram 게시는 별도 프로젝트 `{{CLAUDE_ROOT}}\Telegram`과 스킬 `telegram-publish`가 이미 담당한다.
- `codex_inventory.md` 원본 — Codex 경로·Telegram 세부가 많아 복사하지 않았다. 필요하면 원본 위치에서 읽는다.
- `output\pdf\codex-md-structure-guide.pdf` — Codex가 만든 구조 안내 PDF. 이식 후 내용이 맞지 않아 제외.
- `.firecrawl\` — 빈 작업 폴더.
- `automation\daily-md-update\state.json`의 Codex 검토 큐 53건 — Codex 스레드 ID라 Claude에서 의미가 없어 빈 큐로 새로 만들었다. 기준선(`baselineComplete`)은 미완료 상태 그대로다.
- Codex 전용 설정 — `config.toml`, 플러그인·스킬 캐시, MCP 서버(node_repl, yield_spread_publisher), `~\.codex\automations`의 예약 실행. Cloudflare·Notion MCP는 Claude에 이미 연결돼 있다.
- 다른 프로젝트 — `C:\Users\<사용자>\Documents\ChatGPT\API`, `...\데이터`, `...\텔레그램 자동화`, `C:\Users\<사용자>\Documents\Codex\2026-*`, `C:\Users\<사용자>\Documents\New project`. 인벤토리 1.2절·4.5절·6절의 프로젝트별 문서는 해당 프로젝트를 옮길 때 따로 다룬다.

## 2026-09-14 후속 결정과 반영

1. **Git·GitHub** — `{{CLAUDE_ROOT}}\MD`와 `{{CLAUDE_ROOT}}\API`를 각각 Git 저장소로 초기화하고 커밋했다 (작성자 tonysskim, Codex 저장소와 동일). 사용자 승인 후 비공개 저장소 `tonysskim/MD`와 `tonysskim/API`를 만들어 올렸다. 올리기 전 gitleaks로 두 저장소 이력을 검사했고 유출은 없었다. 저장소 이름은 처음에 내 판단으로 `claude-guidance`·`claude-api`로 만들었다가, 사용자 지적에 따라 폴더 이름과 같은 `MD`·`API`로 바꿨다.
2. **자동화** — 사용자 지시("자동화 건별로 물어볼 것")를 `automation\CLAUDE.md` 규칙으로 추가했다. 일일 MD 업데이트는 사용자 승인 후 Claude Code 데스크톱 예약 작업 `daily-md-update`(매일 09:00, 로컬 시간)로 등록했다. 앱이 열려 있을 때 실행되며, 앱이나 PC가 꺼져 있어 놓친 실행은 다음 앱 시작 때 실행된다.
3. **인증 저장소 통합** — Claude 방식(`.env`)으로 합쳤다.
   - 단일 저장소: `{{CLAUDE_ROOT}}\API`. 레지스트리 `config\providers.json`(키 제공자 12, 공개 서비스 32)과 `config\registration.json`, 헬퍼 36개 `scripts\`, 키 파일 `.env`(Git 제외).
   - Codex의 DPAPI 저장소(`Documents\ChatGPT\API_Keys`)에만 있던 KOSIS 키와 사용자 환경변수에만 있던 BLS·Databento·Census·OpenAI 키를 `.env`로 옮겼다. 옮기기 전 세 저장소의 값을 같은지만 비교했고 겹치는 항목은 모두 일치했다. 값은 어디에도 표시하지 않았다.
   - `.env` 별칭을 레지스트리 이름으로 통일: `BOK_API_KEY`→`ECOS_API_KEY`, `SEC_USER_AGENT`→`SEC_EDGAR_USER_AGENT`. BOK·SEC 조회 스크립트와 `Claude\API\CLAUDE.md`도 같이 고쳤다.
   - 공공데이터포털(`DATA_GO_KR_API_KEY`, 채권발행정보·채권기본정보)을 레지스트리에 새로 등록하고 `scripts\Test-DataGoKrApi.ps1`을 추가했다.
   - 키 관리 스크립트(Import/Set/Remove-ApiKey, Get-ApiAccessStatus, Initialize-ApiAccess, Set-SecEdgarIdentity)를 DPAPI 대신 `.env`를 읽고 쓰도록 다시 썼다. `Test-ApiKeys.ps1`은 CPI 파이썬 프로젝트에 기대지 않고 PowerShell만으로 ECOS·KOSIS를 시험한다.
   - Codex 헬퍼는 PowerShell 7 전제였다. Claude Code의 실행환경인 Windows PowerShell 5.1에서 실패하던 부분을 고쳤다: System.Net.Http 어셈블리 명시 로드(OpenAI·SEC·키리스·Yahoo 헬퍼), `ReadAsStream()`→`ReadAsStreamAsync()`, `ConvertFrom-Json -Depth` 제거, JSON 최상위 배열 처리(Census 시험), `String.Contains(값, StringComparison)`→`IndexOf`(키리스 일괄 시험). 모든 `.ps1`은 UTF-8 BOM+CRLF로 저장했다.
   - 연결 시험 결과: 키 제공자 12개 모두 성공(ECOS·KOSIS·FRED·BEA·BLS·Census·Databento·OpenAI·KRX·Firecrawl·Alpha Vantage·공공데이터포털). 공개 서비스 검사 34건 중 33건 성공, 미 국무부 비자 통계 1건은 HTTP 403으로 브라우저 대체 필요(Codex 때와 동일). KRX는 Codex 보고서의 401이 해소돼 정상 응답. Firecrawl은 인증은 되나 이번 결제 주기의 검색 크레딧이 소진 상태.
   - 지침 반영: `standards\DATA_ACCESS.md` 전면 개정, 루트·README·거시/채권/플랫폼 지침의 저장소 경로와 DPAPI 문구 수정, `fixed-income\ktb\CLAUDE.md`에 공공데이터포털 라우팅 추가, 전역 `~\.claude\CLAUDE.md` 재동기화.
   - Codex 쪽 `Documents\ChatGPT\API_Keys`, `Documents\ChatGPT\API`, 사용자 환경변수 `CHATGPT_API_KEYS_ROOT`는 건드리지 않았다. Codex를 더 쓰지 않게 되면 나중에 정리할 수 있다.
4. **전역 지침 설명** — 전역 파일은 모든 작업 폴더에서 읽히는 공통 규칙이고, 각 폴더의 `CLAUDE.md`는 그 폴더 작업에만 더해지는 규칙이다. 인증 저장소를 합쳤으므로 API 폴더와 충돌하던 문장은 없어졌다.

## 데이터 프로젝트 이식 (2026-09-14, 완료)

Codex 이식 패키지 `C:\Users\<사용자>\Documents\ChatGPT\데이터\이식 패키지\*.zip` 5개를 `{{CLAUDE_ROOT}}\데이터`로 옮기고 있다. 사용자 결정: 제대로 이식(Codex 전용 `@oai/artifact-tool` 빌더를 Python/openpyxl로 재작성), 순서는 미국 물가 → 미국 국채 → 미국 재정 → 미국 고용 → 한국 소비자물가, 자동화·예약 작업은 만들지 않음. 진행 상태와 프로젝트별 규칙은 `{{CLAUDE_ROOT}}\데이터\CLAUDE.md`와 각 프로젝트의 `CLAUDE.md`·`context\known-gaps.md`에 있다.

| 프로젝트 | 상태 | 검증 |
| --- | --- | --- |
| 미국 물가 | 완료 | 워크북·참조·명세 이관 (생성기 없음, 수동 갱신) |
| 미국 국채 | 완료 | Python 생성기가 승인본과 셀 단위 일치 (문서화된 차이 1건: PD 포지션 6열은 Claude 빌더가 채움) |
| 미국 재정 | 완료 | Python 생성기가 승인본과 셀 167,684개·표 14개·차트 10개 일치, 매핑 검사 PASS(124→128) |
| 미국 고용 | 완료 | Python 생성기가 승인본과 셀 639,066개·차트 14개 일치, 페이로드 통계 일치(269 / 125,569 / Bloomberg 보완 36). 수집기 4개·NAHB 변환기·실행 절차 이식. 패키지 BEA 스냅샷에 남아 있던 API UserID는 지움 |
| 한국 소비자물가 | 완료 (수동 실행 도구; 라이브 예약 작업은 옮기지 않음) | `cpi_updater.py`는 경로·Excel 생성기 호출만 변경, `workbook_builder.mjs`는 Python 생성기로 재작성. 이 폴더에서 파이프라인을 강제 재실행해 Codex 라이브 산출물과 비교(결과는 프로젝트 `context\known-gaps.md`) |

`Claude\데이터`는 Git 저장소(LFS로 워크북과 한국 소비자물가 CSV 추적)이며 2026-09-14 사용자 승인으로 비공개 저장소 `tonysskim/data`에 올렸다. GitHub가 한글 저장소 이름을 허용하지 않아 `데이터` 대신 `data`를 쓴다. 이 문서·`README.md`·`setup\Install-ClaudeWorkspace.ps1`의 `codex-data` 참조는 `data`로 바꿨다. 한국 소비자물가의 매일 예약 작업은 사용자 결정으로 옮기지 않았고(필요하면 사용자가 지시한다), Codex 쪽 원본 폴더는 당분간 유지한다.

## 2026-09-15 다른 컴퓨터 이식 준비

사용자 지시로 이 컴퓨터의 작업 환경(텔레그램 자동화 제외)을 다른 컴퓨터에서 같은 구조·같은 산출물로 쓸 수 있게 만들었다.

- **경로 규칙**: 세 저장소(`MD`, `API`, `데이터`)의 지침·설정 문서에서 이 컴퓨터 고유 경로를 `{{CLAUDE_ROOT}}`(작업 루트)와 `~\.claude`로 바꿨다. `데이터` 프로젝트 도구 15개의 `-ApiRoot` 기본값은 스크립트 위치에서 계산하도록 고쳤다(`연준 SEP\config\required-providers.json`의 잘못된 JSON 이스케이프도 함께 수정). Codex 시절 경로(`Documents\ChatGPT\...`)는 이력이므로 그대로 뒀다.
- **전역 지침**: `~\.claude\CLAUDE.md`는 이제 `setup\Sync-GlobalGuidance.ps1`이 루트 `CLAUDE.md`에서 토큰을 실제 경로로 바꿔 생성한다. 손으로 복사하지 않는다.
- **디자인 참조 파일**: `Documents\네이트온 받은 파일\보고서 색상 팔레트.dc.html`을 `standards\reference\`로 옮겨 저장소에 넣었다.
- **설치 도구**: `setup\Install-ClaudeWorkspace.ps1`(패키지 또는 GitHub에서 설치·갱신, 작업 루트를 인수로 받음), `setup\Build-MigrationPackage.ps1`(커밋된 상태로 `{{CLAUDE_ROOT}}\이식패키지` 생성), `setup\INSTALL.md`, `setup\BOOTSTRAP-PROMPT.md`, `setup\private-template\`, `setup\claude-home\`(시작 기억 파일, 예약 자동화 정의). `데이터\requirements.txt`를 추가했다.
- **옮기지 않는 것**: `API\.env`, `private\` 내용, 결과 파일, 세션 기록(채팅에 입력한 키가 들어 있음), 텔레그램 자동화, 예약 자동화 등록.

## 남은 확인 사항

1. **일일 MD 업데이트 첫 실행** — 기준선 검토는 접근 가능한 모든 Claude Code 세션을 훑으므로 첫 며칠은 실행이 길 수 있다. 결과 보고와 `private\PENDING_REVIEW.md`를 확인한다.
2. **번호 선택지 선호** — 인벤토리 3절의 후보는 반복 확인이 안 돼 반영하지 않았다.
3. **외부 접속 상태** — 미 국무부 비자 통계는 사용자 결정에 따라 브라우저 대체 경로로 받는다(`macro-data\us\demographics\CLAUDE.md`에 명시). Firecrawl 검색 크레딧은 2026-09-23 결제 주기 갱신 뒤 다시 확인한다.
