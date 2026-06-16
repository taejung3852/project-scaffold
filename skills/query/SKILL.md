---
description: "wiki/ 기반으로 질문에 답한다. 좋은 답변은 wiki/synthesis/에 저장해 지식이 복리로 쌓인다. 프로젝트 컨벤션·결정·기록에 대해 물어볼 때 사용."
---

# /query — wiki 기반 질의응답 스킬

wiki/ 를 기반으로 질문에 답한다.
좋은 답변은 wiki/synthesis/ 에 저장해 지식이 복리로 쌓이게 한다.

---

> **추적:** `python3 scripts/skill_usage.py track query`

---

## Step 0.5 — 그래프 우선 탐색

`graphify-out/graph.json` 존재 여부를 확인한다.

- **있으면**: 그래프에서 질문과 연관된 노드를 먼저 탐색해 관련 문서 범위를 좁힌다. 이 결과를 Step 1의 index.md 전체 스캔보다 우선한다
- **없으면**: `command -v graphify`로 설치 여부를 확인한다
  - **설치는 됐지만 graph.json이 없는 경우(아직 update 안 함)**: `graphify update wiki/` 실행을 제안한다. 사용자가 거절하면 Step 1로 진행
  - **설치 자체가 안 되어 있는 경우**: 조용히 건너뛰지 않는다. 안내한다 — "Graphify를 쓰면 쿼리 토큰을 최대 71.5배 절감할 수 있어요. 설치할까요? (`pip install graphifyy && graphify install`)" 원치 않으면 Step 1(index.md 우선)로 진행

---

## Step 1 — index.md 먼저 읽기

Step 0.5에서 충분히 좁혀지지 않았거나 Graphify를 안 쓰는 경우 여기서 진행한다.

`wiki/index.md` 를 읽어 질문과 관련된 페이지를 파악한다.

우선순위:
1. `wiki/conventions/` — 컨벤션 관련 질문
2. `wiki/decisions/` — 아키텍처 결정 관련 질문
3. `wiki/devlog/` — 개발 진행 관련 질문
4. `wiki/dashboard.md` — 할 일·우선순위 관련 질문
5. `wiki/meetings/` — 회의 결정 관련 질문

---

## Step 2 — 관련 페이지 읽기 & 답변 합성

파악한 페이지들을 읽고 답변을 합성한다.

**답변 형식:**
- 출처는 반드시 `[[페이지명]]` wikilink로 인용
- 사실과 해석을 구분한다
- 모순이 있으면 `> ⚠️ 모순` 블록으로 양쪽 제시

**답변 유형별 형식:**
- 컨벤션 질문 → 규칙·이유·예시 포함
- 진행 상황 질문 → 타임라인 형식
- 의사결정 질문 → 결정 배경과 근거 포함

---

## Step 3 — raw/ 보충 (필요 시)

wiki/ 에 정보가 부족한 경우에만 `raw/` 를 추가로 읽는다.
raw/ 에서 가져온 정보는 "(raw/ 직접 참조)" 표시를 붙인다.

---

## Step 4 — 좋은 답변은 wiki에 저장

다음 조건이면 `wiki/synthesis/[슬러그].md` 로 저장한다:
- 여러 소스를 종합했거나
- 새로운 연결 고리를 발견했거나
- 이 질문이 다시 올 가능성이 있으면

저장 시 log.md에 기록:
```text
## [YYYY-MM-DD] query | [질문 요약]

- **참조 페이지:** 목록
- **Synthesis 저장:** [[페이지명]] 또는 "없음"
```

---

## 규칙

| 항목 | 규칙 |
|---|---|
| 읽기 순서 | graph.json(있으면) → index.md → wiki/ → raw/ (raw/는 최후 수단) |
| 그래프 미설치 | 건너뛰지 않고 설치 여부 확인 후 index.md 폴백 |
| 인용 형식 | `[[페이지명]]` wikilink 필수 |
| raw/ | 절대 수정 금지 |
| 답변 없을 때 | "현재 wiki에 충분한 정보가 없습니다. /ingest 로 관련 소스를 추가해보세요." |
