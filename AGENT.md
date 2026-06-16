# AGENT.md

> ⚠️ 설정 전 상태입니다. `/setup` 을 실행하여 프로젝트 컨벤션을 정의해주세요.
> `/setup` 완료 후 이 파일은 프로젝트 맞춤 내용으로 자동 덮어써집니다.

---

## 사용 가능한 스킬

| 스킬 | 설명 | 설정 필요 |
|---|---|---|
| `/setup` | 프로젝트 초기 인터뷰 (14개 카테고리 컨벤션 생성) | ❌ 지금 실행 가능 |
| `/capture` | 회의·결정·개발 기록 → raw/ 저장 | ❌ 지금 실행 가능 |
| `/ingest` | raw/ 파일을 wiki/ 에 반영 | ❌ 지금 실행 가능 |
| `/query` | wiki/ 기반 질의응답 | ⚠️ wiki/가 없으면 제한적 |
| `/code-lint` | 컨벤션 기반 코드 검증 | ✅ /setup 후 권장 |
| `/wiki-lint` | wiki 품질 점검 | ✅ /setup 후 권장 |
| `/dashboard` | 프로젝트 현황 대시보드 | ✅ /setup 후 권장 |
| `/curate` | 스킬 진화 큐레이터 — 통합·아카이브·신규 제안 | ❌ 지금 실행 가능 |
| `/report` | 진행 상황 리포트 생성 | ✅ /setup 후 권장 |
| `/help` | 하네스 사용 가이드 — 전체 스킬 목록·역할 분류·시작 흐름 | ❌ 지금 실행 가능 |
| `/handoff` | 세션 종료/시작 시 작업 컨텍스트 저장·복원 | ❌ 지금 실행 가능 |

---

## 스킬 파일 위치

모든 스킬 파일은 `skills/` 하위에 있다.
작업 전 관련 SKILL.md 를 읽고 절차를 따른다:

- `/setup` → `skills/setup/SKILL.md`
- `/capture` → `skills/capture/SKILL.md`
- `/ingest` → `skills/ingest/SKILL.md`
- `/query` → `skills/query/SKILL.md`
- `/code-lint` → `skills/code-lint/SKILL.md`
- `/wiki-lint` → `skills/wiki-lint/SKILL.md`
- `/dashboard` → `skills/dashboard/SKILL.md`
- `/curate` → `skills/curate/SKILL.md`
- `/report` → `skills/report/SKILL.md`
- `/help` → `skills/help/SKILL.md`
- `/handoff` → `skills/handoff/SKILL.md`

---

## 에이전트 제안 (조건 충족 시 한 줄로 안내)

아래 표의 조건을 해당 시점에 확인하고, 충족하면 작업 진행 전 한 줄로 제안한다. 강요하지 않는다 — 사용자가 무시하면 바로 본 작업으로 넘어간다.

| 스킬 | 확인 시점 | 조건 | 확인 방법 |
|---|---|---|---|
| (스킬 진화 권고) | 세션 시작 시 | 아래 `스킬 진화 권고` 섹션에 항목 존재 | 섹션 직접 읽기 (`post-commit` 훅이 `prompt_builder.py`로 자동 갱신) |
| `/code-lint` | push/PR 의도 감지 시 | 브랜치가 origin보다 앞서 있고, 이번 변경에서 미실행 | `skills/.usage.json`의 `code-lint.last_used`가 오늘이 아님 |

**규칙:**
- 조건을 못 읽거나 해당 항목이 없으면 조용히 건너뛴다
- 같은 세션·같은 브랜치에서 같은 제안을 두 번 하지 않는다

---

## 스킬 진화 권고

<!-- prompt_builder_start -->
_마지막 갱신: 2026-06-14_

- `/ingest` 실행 권장: `/capture`(3회) 대비 `/ingest`(1회) 사용 불균형
- 최다 사용: `/capture` (3회)
<!-- prompt_builder_end -->

---

## 비서 페르소나

@SOUL.md

---

## 에이전트 무관 설계

이 하네스는 특정 AI 에이전트에 종속되지 않는다.
AGENT.md 하나가 모든 에이전트의 단일 진실 소스(source of truth)다.
다른 에이전트로 전환 시: 해당 에이전트의 컨텍스트 파일에서 `@AGENT.md` 를 임포트하면 된다.

예시:
- Claude Code: `CLAUDE.md` → `@AGENT.md`
- Cursor: `.cursorrules` → `@AGENT.md`
- Continue: `.continuerc.json` → `@AGENT.md`
