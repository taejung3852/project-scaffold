# AGENT.md

> ⚠️ 설정 전 상태입니다. `/setup` 을 실행하여 프로젝트 컨벤션을 정의해주세요.
> `/setup` 완료 후 이 파일은 프로젝트 맞춤 내용으로 자동 덮어써집니다.

---

## 사용 가능한 스킬

| 스킬 | 설명 | 설정 필요 |
|---|---|---|
| `/setup` | 프로젝트 초기 인터뷰 (13개 카테고리 컨벤션 생성) | ❌ 지금 실행 가능 |
| `/capture` | 회의·결정·개발 기록 → raw/ 저장 | ❌ 지금 실행 가능 |
| `/ingest` | raw/ 파일을 wiki/ 에 반영 | ❌ 지금 실행 가능 |
| `/query` | wiki/ 기반 질의응답 | ⚠️ wiki/가 없으면 제한적 |
| `/code-lint` | 컨벤션 기반 코드 검증 | ✅ /setup 후 권장 |
| `/wiki-lint` | wiki 품질 점검 | ✅ /setup 후 권장 |
| `/dashboard` | 프로젝트 현황 대시보드 | ✅ /setup 후 권장 |

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

---

## 에이전트 무관 설계

이 하네스는 특정 AI 에이전트에 종속되지 않는다.
AGENT.md 하나가 모든 에이전트의 단일 진실 소스(source of truth)다.
다른 에이전트로 전환 시: 해당 에이전트의 컨텍스트 파일에서 `@AGENT.md` 를 임포트하면 된다.

예시:
- Claude Code: `CLAUDE.md` → `@AGENT.md`
- Cursor: `.cursorrules` → `@AGENT.md`
- Continue: `.continuerc` → `@AGENT.md`
