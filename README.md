# 리서치센터 AI 활용 현황 — Claude Code 지침(CLAUDE.md) 공개본

센터장님 요청("Claude 사용자는 어떤 CLAUDE.md를 만들어 사용하는지 그 리스트와 MD 내용을 보내주십시오", 제출 기한 2026-09-17)에 대한 제출 자료입니다.

## 먼저 보실 문서

📄 **[보고서.md](보고서.md)** — 활용 현황 보고서 전문
목록·내용 요약·운영 구조·추가 활용 현황(코덱스 호환, 매일 지침 갱신, 텔레그램)이 모두 들어 있습니다. 부록에 전역 지침 전문과 전체 파일 목록이 있습니다.

## 이 저장소는 무엇인가요

Claude Code는 대화창에 매번 같은 설명을 반복하는 대신, **작업 폴더에 놓인 `CLAUDE.md` 파일을 자동으로 읽고 그 규칙대로 일합니다.** 이 저장소는 실제 업무에 쓰고 있는 그 지침 체계의 공개본입니다.

지침은 3계층으로 구성했습니다.

```
[1] 전역   CLAUDE.md                        모든 작업에 적용되는 공통 규칙
       ↓
[2] 도메인 macro-data/CLAUDE.md 등           거시·재정·채권·공시·자동화 등 분야별 규칙
       ↓
[3] 기관   macro-data/us/fred/CLAUDE.md 등   FRED·BEA·BLS 등 개별 제공기관 규칙
```

## 폴더 안내

| 경로 | 내용 |
| --- | --- |
| [CLAUDE.md](CLAUDE.md) | **전역 지침.** 언어 표준, 산출물 정리, 데이터 출처 제한, 자율 작업 범위, 도메인 라우팅 |
| [standards/](standards/) | 공통 표준 4종 — 언어, 데이터·인증키 접근, 산출물 보존, 디자인 시스템 |
| [macro-data/](macro-data/) | 거시경제 지침 14개 — 미국(FRED·BEA·BLS·센서스·지역 연은·주택·인구), 한국(ECOS·KOSIS), 국제(IMF) |
| [fiscal-data/](fiscal-data/) | 재정 지침 6개 — 재무부 Fiscal Data, 재정서비스국, OMB·CBO, TIC, TBAC |
| [fixed-income/](fixed-income/) | 채권 지침 4개 — 국고채, 미 국채, 뉴욕 연은 Markets Data·Databento |
| [regulatory/](regulatory/) | 공시 지침 2개 — SEC EDGAR |
| [platform/](platform/) | 플랫폼 지침 2개 — OpenAI API |
| [automation/](automation/) | 자동화 지침 3개와 런북 2개 — 매일 지침 갱신, EERN |
| [templates/](templates/) | 산출물 템플릿 규칙 |
| [setup/](setup/) | 다른 컴퓨터 설치 도구와 안내 — 코덱스↔클로드 호환 및 환경 이식 |
| [MIGRATION_FROM_CODEX.md](MIGRATION_FROM_CODEX.md) | GPT 코덱스 `AGENTS.md` → Claude `CLAUDE.md` 이식 기록과 셀 단위 검증 결과 |
| [REPOSITORY-README.md](REPOSITORY-README.md) | 원본 저장소의 운영 안내 문서 |

## 읽으실 때 참고사항

- `{{CLAUDE_ROOT}}`는 각 컴퓨터의 실제 작업 폴더 경로로 자동 치환되는 **토큰**입니다. 지침을 어느 컴퓨터에서나 그대로 쓰기 위한 장치이며, 실제 경로는 설치할 때 생성되는 전역 사본에만 들어갑니다.
- 영문 지침이 많은 것은 Claude가 읽는 규칙 문서이기 때문입니다. 한국어 요약은 [보고서.md](보고서.md)에 정리했습니다.
- **이 공개본에서 제외한 것**: 개인 맥락 폴더(`private/`), 인증키 파일(`.env`), 개인 작업 기억 파일(`setup/claude-home/memory/`), 데이터 워크북 저장소. 문서에 남아 있던 개인 실명과 홈 폴더 경로는 `<사용자>`로 가렸습니다.
- 운영 중인 저장소는 `MD`(지침), `API`(제공기관 레지스트리·조회 도구), `데이터`(워크북 프로젝트) 세 개이며, 이 공개본은 그중 `MD`의 사본입니다.

---

기준 시점: 2026-09-16
