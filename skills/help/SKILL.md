---
description: "프로젝트 하네스 사용법 안내. 전체 스킬 목록과 역할 분류(직접 실행/에이전트 제안/시스템 자동), 추천 시작 흐름을 한 화면에 보여준다. 하네스가 처음이거나 어떤 스킬을 써야 할지 헷갈릴 때 사용."
---

# /help — 하네스 사용 가이드

스킬이 늘어날수록 어떤 걸 언제 써야 하는지 헷갈리기 쉽다. `/help`는 문서를 찾아볼 필요 없이 지금 이 프로젝트에 어떤 스킬이 있고 어떻게 동작하는지 한 화면에 보여준다.

---

> **추적:** `python3 scripts/skill_usage.py track help`

---

## Step 1 — 스킬 목록 동적 수집

`skills/` 하위 디렉토리를 스캔해 각 `SKILL.md`의 frontmatter `description`을 읽는다.
(`.archive/`, `.usage.json`, `setup/ambiguity-check.md` 같은 서브 파일은 제외)

```bash
for d in skills/*/; do [ -f "$d/SKILL.md" ] && echo "${d%/}"; done
```

각 스킬명과 description을 수집한다. **하드코딩하지 않는다** — 실제 디렉토리 기준으로 매번 다시 읽는다.

---

## Step 2 — 역할별로 분류해 출력

아래 고정 카테고리에 수집된 스킬을 배치한다 (`README.md`의 "사용자 vs 시스템 역할 분리"와 동일 기준):

| 스킬 | 카테고리 |
|---|---|
| setup, capture, ingest, query, report, code-lint, help | 직접 실행 |
| dashboard, wiki-lint, curate | 에이전트 제안 · 사용자 확인 |

Step 1에서 발견했지만 이 표에 없는 스킬은 **"🆕 미분류"**로 별도 표시한다 (임의로 카테고리를 추정하지 않는다).

**출력 형식:**

```text
=== 이 프로젝트의 스킬 ===

▶ 직접 실행 — 필요할 때 네가 호출
  /setup        [description]
  /capture      [description]
  /ingest       [description]
  /query        [description]
  /report       [description]
  /code-lint    [description]
  /help         [description]

▶ 에이전트가 제안 — 조건 충족 시 한 줄로 알려줌, 확인 후 실행
  /dashboard    [description]
  /wiki-lint    [description]
  /curate       [description]

▶ 시스템이 완전 자동 처리 — 호출 불필요
  git commit 시       → pre-commit/post-commit hook
  스킬 실행 시         → skill_usage.py, prompt_builder.py

🆕 미분류 (있는 경우만)
  /[스킬명]     [description]  ← README 분류 업데이트 필요
```

---

## Step 3 — 구조 한 줄 설명

```text
raw/ (사람이 쓴 원본)
  → /ingest → wiki/ (에이전트가 정리한 지식)
  → /query 로 다시 꺼내 씀

AGENT.md = 에이전트가 항상 지키는 규칙
SOUL.md  = 에이전트의 성격 (프로젝트가 바뀌어도 유지)
```

자세한 구조는 `README.md`의 "LLM Wiki란?", "시스템 구조" 섹션을 참조하라고 안내한다.

---

## Step 4 — 추천 시작 흐름

`wiki/conventions/`에 `.gitkeep` 외 파일이 있는지 확인한다.

**없으면 (미설정 프로젝트):**

> "아직 컨벤션이 설정되지 않았어요. `/setup`부터 시작하는 걸 추천해요 (2~3시간, 중단해도 이어서 진행 가능)."

**있으면 (설정된 프로젝트):** 다음 흐름을 보여준다.

```text
1. /capture   — 작업 중 결정·회의 내용 기록
2. /ingest    — (완료 시 자동 제안됨) wiki에 반영
3. /query     — 필요할 때 wiki에 물어보기
4. /code-lint — PR 올리기 전 검증
```

---

## 규칙

| 항목 | 규칙 |
|---|---|
| 스킬 목록 | 항상 `skills/` 실제 디렉토리 기준 — 하드코딩 금지 |
| 분류 불명 스킬 | "🆕 미분류"로 표시. 임의로 카테고리 추정하지 않음 |
| 파일 수정 | 없음. 읽기 전용 스킬 |
