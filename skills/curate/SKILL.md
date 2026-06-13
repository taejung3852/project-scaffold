# /curate — 스킬 진화 큐레이터

curator.py의 기계적 분류 + LLM 클러스터링 판단으로 스킬을 정리하고 진화시킨다.
새 스킬 추가·통합·아카이브 모두 이 스킬을 통해 실행한다.

---

> **추적:** `python3 scripts/skill_usage.py track curate`

---

## Step 1 — curator.py 리포트 실행

```bash
python3 scripts/curator.py report
```

출력 결과를 읽고 Step 2로 넘어간다.

---

## Step 2 — LLM 클러스터링 분석

Step 1 리포트를 바탕으로 다음을 판단한다:

| 항목 | 판단 기준 |
|---|---|
| 기능 중복 | 두 스킬이 유사한 목적 → 통합 후보 |
| 특화 vs 일반 | 범용 스킬은 분리 불필요 |
| Stale 정당성 | 30일 미사용이 진짜 불필요인가, 주기적 사용인가? |
| Archive 타당성 | 90일 미사용 스킬을 아카이브해도 되는가? |
| 신규 스킬 탐지 | 반복 패턴에서 아직 없는 스킬이 필요한가? |

**출력 형식:**

```text
## /curate 분석 — YYYY-MM-DD

### 통합 제안
1. [스킬A] + [스킬B] → [새스킬명]
   이유: ...

### 아카이브 승인 필요
- [스킬명]: N일 미사용. 아카이브해도 됩니까?

### 현상 유지
- [스킬명]: 이유

### 신규 스킬 제안
- 패턴: "X를 Y번 반복 중 → /[스킬명] 추가 권장"
```

---

## Step 3 — HITL 확인

분석 결과를 보여주고 묻는다:

> "어떤 액션을 실행할까요? (번호 입력 또는 skip)"

- **통합 선택** → `python3 scripts/skill_manager.py create [새스킬명]` 후 SKILL.md 병합 작업
- **아카이브 선택** → `python3 scripts/curator.py archive`
- **신규 생성** → `python3 scripts/skill_manager.py create [스킬명]`
- **skip** → log.md에 결과만 기록

---

## Step 4 — log.md 기록

`wiki/log.md` 맨 위에 append:

```text
## [YYYY-MM-DD] curate

- **스킬 현황:** 활성 n개 / stale n개 / archive n개
- **통합:** 있으면 목록, 없으면 "없음"
- **아카이브:** 있으면 목록, 없으면 "없음"
- **신규 제안:** 있으면 목록, 없으면 "없음"
```

---

## 규칙

| 항목 | 규칙 |
|---|---|
| 자동 실행 | 금지. 항상 HITL 확인 후 실행 |
| 아카이브 | 활성 스킬 3개 이하이면 curator.py가 자동 차단 |
| 통합 | 두 SKILL.md 내용 병합 확인 후 기존 파일 삭제 |
| 실행 주기 | 수동. stale 3개 이상 또는 총 호출 50회 이상일 때 권장 |
