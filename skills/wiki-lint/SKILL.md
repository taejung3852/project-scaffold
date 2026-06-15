---
description: "wiki/ 전체를 스캔해 구조적 문제를 탐지한다. 고아 페이지·깨진 링크·모순·stale 정보 탐지. 읽기 전용 — 자동 수정 안 함. 주기적 건강 점검 시 사용."
---

# /wiki-lint — wiki 품질 점검 스킬

wiki/ 전체를 스캔해서 구조적 문제를 탐지한다.
lint는 읽기 전용 — 자동 수정하지 않는다. 결과를 보고하고 사용자가 결정한다.

---

> **추적:** `python3 scripts/skill_usage.py track wiki-lint`

---

## Step 1 — 전체 스캔

`wiki/` 하위 전체 파일을 스캔한다.

스캔 항목:

| 항목 | 설명 |
|---|---|
| **고아 페이지** | inbound wikilink가 0개인 페이지 |
| **깨진 wikilink** | `[[페이지명]]` 이 존재하지 않는 파일을 가리키는 경우 |
| **누락 백링크** | A가 B를 언급하지만 B가 A를 가리키지 않는 경우 |
| **모순 블록** | `> ⚠️ 모순` 이 있는 페이지 (미해결 상태) |
| **stale 페이지** | `updated` 날짜가 90일 이상 지났고 소스도 없는 페이지 |
| **frontmatter 누락** | `title`, `type`, `created`, `updated` 중 하나라도 없는 경우 |
| **index.md 미등록** | wiki/ 에 페이지가 있지만 index.md에 없는 경우 |

---

## Step 2 — 결과 리포트

다음 형식으로 결과를 보여준다:

```text
## /wiki-lint 결과 — YYYY-MM-DD

### 🔴 즉시 수정 필요
1. [깨진 wikilink] wiki/concepts/Foo.md → [[Bar]] 없음
2. [frontmatter 누락] wiki/projects/Baz.md — updated 필드 없음

### 🟡 검토 권장
3. [고아 페이지] wiki/concepts/Qux.md — 아무도 링크하지 않음
4. [미해결 모순] wiki/synthesis/Alpha.md — ⚠️ 모순 블록 존재

### 🟢 참고
5. [stale] wiki/concepts/Beta.md — 120일 미업데이트
6. [누락 백링크] wiki/projects/Gamma.md → [[Delta]] 언급하지만 역링크 없음

전체: 🔴 2개 / 🟡 2개 / 🟢 2개
```

---

## Step 3 — 사용자 결정 대기

리포트 후 다음을 묻는다:

> "어떤 항목을 수정할까요? 번호를 입력하거나(예: 1 3 5), all이면 전체, skip이면 log만 기록합니다."

- 선택한 항목은 **사용자와 함께 수정** (AI가 수정안 제안 → 확인 후 적용)
- 자동 일괄 수정은 금지

---

## Step 4 — log.md 기록

`wiki/log.md` 맨 위에 append:

```text
## [YYYY-MM-DD] wiki-lint

- **🔴 즉시 수정:** n개
- **🟡 검토 권장:** n개
- **🟢 참고:** n개
- **처리 내역:** 수정한 항목 목록 또는 "skip"
```

---

## 규칙

| 항목 | 규칙 |
|---|---|
| 자동 수정 | 금지. 리포트만 한다 |
| raw/ | 절대 스캔하지 않음 |
| 수정 범위 | 사용자가 명시적으로 선택한 항목만 |
| log.md | 수정 여부와 관계없이 항상 기록 |
| 실행 주기 | 수동 실행. 자동 스케줄 없음 |
