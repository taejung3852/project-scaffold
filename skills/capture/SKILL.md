# /capture — 회의·결정·개발 기록 스킬

작업 중 발생하는 회의·결정·개발 과정을 `raw/`에 저장한다.
저장된 파일은 `ingest_status: "⏳ pending"` 상태가 되어 `/ingest`가 자동으로 탐지한다.

---

> **추적:** `python3 scripts/skill_usage.py track capture`

---

## Step 0 — 캡처 타입 결정

`/capture` 실행 시 타입을 확인한다.

| 타입 | 트리거 | 저장 경로 |
|---|---|---|
| `meeting` | `/capture meeting` | `raw/meetings/` |
| `decision` | `/capture decision` | `raw/decisions/` |
| `dev-log` | `/capture dev-log` | `raw/dev-logs/` |

인자가 없으면 묻는다:

> "어떤 내용을 기록할까요?
> 1. meeting — 회의·논의 내용
> 2. decision — 아키텍처·기술 결정
> 3. dev-log — 개발 과정·회고"

---

## Step 1 — 정보 수집

### meeting 타입

다음을 한 번에 묻는다:

1. 회의 제목이 뭐야?
2. 참석자가 누구야?
3. 주요 결정 사항이 뭐야?
4. 다음 액션 아이템이 있어?

### decision 타입

다음을 한 번에 묻는다:

1. 결정 제목이 뭐야? (예: "DB를 PostgreSQL로 선택")
2. 선택지가 뭐였어? (A vs B vs C)
3. 왜 이걸 선택했어?
4. 이 결정의 트레이드오프는?
5. 재검토 조건이 있어? (예: "사용자 1만 명 초과 시")

**decision은 ambiguity-check 적용**: `skills/setup/ambiguity-check.md` 기준으로 이유와 트레이드오프가 구체적인지 확인. 모호하면 follow-up.

### dev-log 타입

다음을 한 번에 묻는다:

1. 기록 제목이 뭐야? (파일명 슬러그로 사용됨)
2. 오늘 무엇을 했어?
3. 막혔던 부분이 있어? 어떻게 해결했어?
4. 다음에 할 일은?
5. 오늘 배운 것·깨달은 것이 있어?

---

## Step 2 — 파일 생성

**파일명 규칙:**
- 제목에서 슬러그 생성: 공백 → `-`, 특수문자 제거, 최대 40자
- 날짜 자동: `YYYY-MM-DD`

| 타입 | 파일명 형식 |
|---|---|
| meeting | `raw/meetings/YYYY-MM-DD_meeting_슬러그.md` |
| decision | `raw/decisions/YYYY-MM-DD_decision_슬러그.md` |
| dev-log | `raw/dev-logs/YYYY-MM-DD_dev-log_슬러그.md` |

**frontmatter 템플릿:**

```yaml
---
title: "[제목]"
raw_type: "[meeting|decision|dev-log]"
date: YYYY-MM-DD
created: YYYY-MM-DD
ingest_status: "⏳ pending"
tags:
  - "raw/[타입]"
---
```

본문은 수집한 정보를 구조화해서 작성한다. 사용자 답변은 원문 그대로 유지.

---

## Step 3 — 확인 및 완료

파일 생성 후:

1. 생성된 경로와 내용 요약을 보여준다
2. 바로 인제스트할지 묻는다:
   - **Yes** → `/ingest [파일경로]` 실행
   - **No** → "저장 완료. `/ingest` 로 나중에 처리하세요." 안내

---

## devlog 자동 생성 (git commit 연동)

`.hooks/devlog-auto.sh` 훅이 커밋 후 다음을 수행한다:

1. 커밋 메시지·변경 파일 목록 수집
2. `raw/dev-logs/YYYY-MM-DD_dev-log_auto.md` 자동 생성 (ingest_status: "⏳ pending")
3. 당일 두 번째 이상 커밋이면 기존 dev-log 파일에 append

**일일 요약**: 하루가 끝날 때 `/capture dev-log` 로 수동 보완 권장.

---

## 규칙

| 항목 | 규칙 |
|---|---|
| raw/ 본문 | 사용자 답변 원문 유지. 과도한 편집 금지 |
| ingest_status | 항상 `"⏳ pending"` 으로 생성 |
| decision ambiguity | 이유·트레이드오프 모호하면 반드시 follow-up |
| 덮어쓰기 | 동일 파일명 존재 시 경고 후 확인 |
| 자동 devlog | 커밋마다 raw/ 파일 생성. 직접 편집하지 않음 |
