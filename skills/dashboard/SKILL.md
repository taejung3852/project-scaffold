# /dashboard — 프로젝트 대시보드 스킬

프로젝트 현황을 markdown → terminal → web UI 순으로 렌더링한다.
wiki/의 devlog, conventions, decisions 데이터를 읽어 자동으로 생성한다.

---

## Step 0 — 렌더 모드 확인

`/dashboard` 실행 시 모드를 확인한다:

| 모드 | 트리거 | 설명 |
|---|---|---|
| **markdown** | `/dashboard` 또는 `/dashboard md` | wiki/dashboard.md 갱신 |
| **terminal** | `/dashboard term` | 터미널에 컬러 출력 |
| **web** | `/dashboard web` | browser로 HTML 열기 |

인자가 없으면 markdown 모드 기본값.

---

## Step 1 — 데이터 수집

다음 파일들을 읽어 데이터를 수집한다:

| 데이터 | 소스 |
|---|---|
| 오늘 할 일 | `wiki/dashboard.md` 의 TODO 섹션 (있으면) |
| 최근 devlog | `raw/dev-logs/` 최신 3개 파일 |
| 마일스톤 진행도 | `wiki/conventions/01-project-overview.md` 의 마일스톤 |
| 미해결 결정 | `raw/decisions/` 중 `ingest_status: "⏳ pending"` |
| wiki 건강 | `wiki/log.md` 최신 lint 결과 (있으면) |

---

## Step 2 — 대시보드 구성

대시보드는 다음 섹션으로 구성된다:

```text
## 📋 오늘 할 일
- [ ] 항목 1
- [ ] 항목 2

## 📈 마일스톤 진행도
| 마일스톤 | 상태 | 진행도 |
|---|---|---|
| MVP | 진행 중 | 60% |

## 📝 최근 devlog (최신 3개)
- YYYY-MM-DD: 요약 한 줄

## ⚠️ 주의 필요
- 미처리 결정: n개
- wiki 모순: n개 (있으면)

## 🔗 빠른 링크
- [[wiki/index.md]] | [[wiki/log.md]] | [[wiki/conventions/]]
```

---

## Step 3 — 렌더링

### markdown 모드

`wiki/dashboard.md`를 갱신한다.

```yaml
---
title: Dashboard
updated: YYYY-MM-DD HH:MM
---
```

기존 파일이 없으면 생성. 있으면 전체 갱신.

### terminal 모드

ANSI 컬러 코드로 터미널에 직접 출력한다:

```bash
echo -e "\033[1;34m📋 오늘 할 일\033[0m"
# ... 섹션별 출력
```

명세서 형식 사용 (bold, color, separator lines).

### web 모드

`wiki/dashboard.html`을 생성하고 브라우저로 연다:

```bash
open wiki/dashboard.html  # macOS
xdg-open wiki/dashboard.html  # Linux
```

HTML은 간단한 인라인 CSS 포함. 외부 CDN 의존 없음.

---

## 자동 갱신 트리거

`.hooks/devlog-auto.sh` 커밋 훅이 실행 후 자동으로 `/dashboard markdown`을 호출한다.

즉, 커밋할 때마다 `wiki/dashboard.md`가 자동 갱신된다.

---

## 오늘 할 일 관리

사용자가 TODO를 추가하려면:

> `/dashboard add [항목]`

`wiki/dashboard.md`의 TODO 섹션에 항목을 추가한다.

완료 처리:

> `/dashboard done [번호]`

`[ ]` → `[x]` 로 변경. 완료된 항목은 다음 갱신 시 devlog에 자동 기록.

---

## 규칙

| 항목 | 규칙 |
|---|---|
| 기본 모드 | markdown. terminal·web은 명시적 요청 시만 |
| 데이터 소스 | wiki/ 와 raw/ 읽기만. 수정하지 않음 |
| 자동 갱신 | 커밋 훅에서만. 수동 `/dashboard` 는 즉시 실행 |
| HTML 생성 | 외부 CDN 없음. 인라인 CSS만 |
| 이전 대시보드 | 갱신 시 덮어씀. 버전 관리는 git에 위임 |
