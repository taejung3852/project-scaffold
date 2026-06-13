# project-scaffold

> AI 에이전트와 함께 개발하는 모든 프로젝트를 위한 LLM Wiki 기반 개발 하네스 템플릿

[![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Markdown](https://img.shields.io/badge/Markdown-LLM_Wiki-000000?logo=markdown&logoColor=white)](https://gist.github.com/karpathy/00d7fb4bde0f8c7ef86ab2a2b3ab6bcd)
[![Status](https://img.shields.io/badge/Status-🚧_In_Development-yellow)]()

---

## 목차

1. [개요](#개요)
2. [왜 만들었나](#왜-만들었나)
3. [시스템 구조](#시스템-구조)
4. [핵심 기능](#핵심-기능)
5. [설계 원칙](#설계-원칙)
6. [빠른 시작](#빠른-시작)
7. [프로젝트 구조](#프로젝트-구조)
8. [현재 상태](#현재-상태)

---

## 개요

project-scaffold는 소프트웨어 개발 프로젝트에 **AI 에이전트 거버넌스 레이어**를 구축하는 GitHub 템플릿이다.

AI 에이전트는 강력하지만, 컨텍스트가 없으면 매번 같은 실수를 반복한다. 팀 컨벤션을 모르고, 지난 결정을 기억하지 못하며, 코드리뷰 기준도 없다. project-scaffold는 이 문제를 **에이전트가 스스로 읽고 따를 수 있는 살아있는 wiki**로 해결한다.

[Andrej Karpathy가 제안한 LLM Wiki 패턴](https://gist.github.com/karpathy/00d7fb4bde0f8c7ef86ab2a2b3ab6bcd)을 기반으로 하며, RAG 없이 에이전트가 소유·유지하는 마크다운 wiki가 프로젝트 전체의 단일 진실 소스가 된다.

---

## 왜 만들었나

### 문제 정의

AI 코딩 에이전트를 프로젝트에 도입할 때 가장 큰 장벽은 **"에이전트가 우리 팀처럼 행동하게 만드는 것"**이다.

- 커밋 메시지 형식이 매번 다르다
- 아키텍처 레이어 규칙을 무시한다
- 테스트 없이 구현 코드부터 짠다
- 지난 회의에서 결정한 내용을 알지 못한다

프롬프트로 매번 설명하는 건 확장되지 않는다. 대화가 끝나면 사라진다.

### 해결 방안

팀 컨벤션을 **구조화된 wiki로 문서화**하고, 에이전트가 작업마다 해당 wiki를 읽고 따르게 한다. `/setup` 인터뷰로 프로젝트 고유의 규칙을 정의하고, git hook으로 위반을 차단하며, devlog가 자동으로 쌓인다.

> **핵심 아이디어**: 에이전트에게 규칙을 외우게 하는 대신, 에이전트가 언제든 꺼내 읽을 수 있는 장소를 만든다.

---

## 시스템 구조

7개의 스킬과 2개의 git hook, 그리고 `AGENT.md` 단일 진실 소스로 구성된다.

```
사용자
  │
  ├─ /setup      ─── wiki/conventions/ (13개 페이지) + AGENT.md 생성
  ├─ /capture    ─── raw/ 저장 (회의·결정·dev-log)
  ├─ /ingest     ─── raw/ → wiki/ 통합
  ├─ /query      ─── wiki/ 기반 질의응답
  ├─ /code-lint  ─── wiki/conventions/ 기준 코드 검증
  ├─ /wiki-lint  ─── wiki/ 품질 점검
  └─ /dashboard  ─── 프로젝트 현황 대시보드

git commit
  ├─ pre-commit  ─── .hooks/convention-check.sh (보안·정적 분석)
  └─ post-commit ─── .hooks/devlog-auto.sh (raw/dev-logs/ 자동 생성)

AGENT.md
  └─ 단일 진실 소스. CLAUDE.md/@AGENT.md 로 모든 에이전트가 읽음
```

---

## 핵심 기능

### `/setup` — 프로젝트 초기 인터뷰

2~3시간의 심층 인터뷰로 13개 카테고리 컨벤션을 정의하고 `wiki/conventions/` 페이지를 자동 생성한다.

**13개 인터뷰 카테고리:**

| # | 카테고리 | 산출물 |
|---|---|---|
| 1 | 프로젝트 개요 | `wiki/conventions/01-project-overview.md` |
| 2 | 기술 스택 | `wiki/conventions/02-tech-stack.md` |
| 3 | 네이밍 컨벤션 | `wiki/conventions/03-naming.md` |
| 4 | Git 컨벤션 | `wiki/conventions/04-git.md` |
| 5 | 아키텍처 규칙 | `wiki/conventions/05-architecture.md` |
| 6 | TDD 규칙 | `wiki/conventions/06-tdd.md` |
| 7 | devlog 템플릿 | `wiki/conventions/07-devlog.md` |
| 8 | HITL 리스크 기준 | `wiki/conventions/08-hitl-risk.md` |
| 9 | 대시보드 설정 | `wiki/conventions/09-dashboard.md` |
| 10 | 코드리뷰 체크리스트 | `wiki/conventions/10-code-review.md` |
| 11 | 에러 핸들링 | `wiki/conventions/11-error-handling.md` |
| 12 | 보안 컨벤션 | `wiki/conventions/12-security.md` |
| 13 | 의존성 관리 | `wiki/conventions/13-dependencies.md` |

모든 카테고리 완료 후 `AGENT.md`가 자동 생성된다. 카테고리마다 독립 파일로 저장되어 중단 후 이어서 진행할 수 있다.

**ambiguity-check 내장:**
모든 답변은 4가지 기준(구체성·실행가능성·예시가능성·완결성)을 통과해야 다음 질문으로 넘어간다. "적절히", "필요시" 같은 모호한 표현은 즉시 재질문을 유발한다. 에이전트가 추가 질문 없이 따를 수 있는 규칙만 wiki에 기록된다.

---

### `/capture` — 회의·결정·개발 기록

작업 중 발생하는 중요한 내용을 `raw/`에 저장한다.

| 타입 | 저장 경로 | 용도 |
|---|---|---|
| `meeting` | `raw/meetings/` | 회의 내용, 결정 사항, 액션 아이템 |
| `decision` | `raw/decisions/` | 아키텍처·기술 결정, 트레이드오프, 재검토 조건 |
| `dev-log` | `raw/dev-logs/` | 개발 과정, 문제 해결, 회고 |

저장된 파일은 `ingest_status: "⏳ pending"` 상태가 되어 `/ingest`가 자동으로 탐지한다.

---

### `/ingest` — wiki 자동 통합

raw 소스를 wiki 전체에 통합한다. 단일 소스가 10~15개 페이지에 영향을 줄 수 있다.

```
raw/ 파일 읽기
  → 소스 요약 페이지 생성 (wiki/sources/)
  → 관련 conventions/decisions/devlog 페이지 업데이트
  → 백링크 감사 (누락된 wikilink 추가)
  → wiki/index.md 갱신
  → wiki/log.md 기록
  → raw/ ingest_status → "✅ done"
```

모순 발견 시 덮어쓰지 않고 양쪽 소스를 인용하여 `> ⚠️ 모순` 블록으로 표시한다.

---

### `/query` — wiki 기반 질의응답

"테스트 파일 어디에 두지?", "이 패키지 써도 돼?" 같은 질문에 wiki를 근거로 답한다.

```
wiki/index.md 읽기 (전체 페이지 파악)
  → 관련 pages 읽기 (conventions → decisions → devlog 우선순위)
  → [[wikilink]] 인용 포함 답변 합성
  → 필요 시 raw/ 보충 참조
  → 좋은 답변은 wiki/synthesis/에 저장
```

소스가 쌓일수록 답변 품질이 높아진다.

---

### `/code-lint` — 컨벤션 기반 코드 검증

**2-레이어 검증**: 정적 분석 도구 + LLM 컨텍스트 리뷰를 조합한다.

| 레이어 | 도구 | 역할 |
|---|---|---|
| 정적 분석 | pylint / mypy / eslint | 문법·타입 오류, 코드 품질 |
| LLM 리뷰 | wiki/conventions/ 기반 | 네이밍·아키텍처·보안·TDD 컨텍스트 위반 |

LLM은 `wiki/conventions/`를 읽고 팀 규칙 기준으로 판단한다. 정적 도구가 잡지 못하는 **의미적·아키텍처적 위반**을 탐지한다.

🔴 위반 발견 시 HITL 확인 후 진행. 자동 수정은 하지 않는다.

---

### `/wiki-lint` — wiki 품질 점검

| 탐지 항목 | 설명 |
|---|---|
| 고아 페이지 | inbound wikilink가 0개인 페이지 |
| 깨진 wikilink | 존재하지 않는 파일을 가리키는 `[[링크]]` |
| 누락 백링크 | A가 B를 언급하지만 B가 A를 역참조하지 않는 경우 |
| 미해결 모순 | `> ⚠️ 모순` 블록이 있는 페이지 |
| stale 페이지 | `updated` 날짜가 90일 이상 지난 페이지 |
| frontmatter 누락 | 필수 필드 누락 |

리포트만 하고 자동 수정은 하지 않는다. 수정 여부는 사용자가 결정한다.

---

### `/dashboard` — 프로젝트 현황 대시보드

오늘 할 일, 마일스톤 진행도, 최근 devlog를 한 화면에 집약한다.

**3가지 렌더 모드 (A→B→C 순서로 구축):**

| 모드 | 명령 | 출력 |
|---|---|---|
| markdown | `/dashboard` | `wiki/dashboard.md` 갱신 |
| terminal | `/dashboard term` | ANSI 컬러 터미널 출력 |
| web | `/dashboard web` | `wiki/dashboard.html` → 브라우저 오픈 |

커밋 훅(`devlog-auto.sh`)에 연결되어 커밋마다 `wiki/dashboard.md`가 자동 갱신된다.

---

### git hooks

**pre-commit — `.hooks/convention-check.sh`**
- 하드코딩된 시크릿 탐지 (password, api_key, secret 패턴)
- pylint / eslint 정적 분석 (설치된 경우만)
- 위반 발견 시 커밋 차단

**post-commit — `.hooks/devlog-auto.sh`**
- 커밋 메시지 + 변경 파일 목록을 `raw/dev-logs/YYYY-MM-DD_dev-log_auto.md`에 자동 저장
- 당일 두 번째 이상 커밋이면 기존 파일에 append

---

## 설계 원칙

### 에이전트 무관 (Agent-Agnostic)

`AGENT.md` 하나가 모든 AI 에이전트의 단일 진실 소스다. 에이전트를 교체할 때 `AGENT.md`는 그대로 유지되고 래퍼 파일만 바꾸면 된다.

| 에이전트 | 설정 파일 | 내용 |
|---|---|---|
| Claude Code | `CLAUDE.md` | `@AGENT.md` |
| Cursor | `.cursorrules` | `@AGENT.md` |
| Continue | `.continuerc` | `@AGENT.md` |

### 두 레이어 강제

- **Soft (에이전트 레이어)**: `AGENT.md`가 TDD·보안 규칙을 항상 참조. 작업마다 관련 conventions 페이지를 읽고 따름
- **Hard (훅 레이어)**: `.hooks/convention-check.sh`가 커밋 시 `wiki/conventions/`를 참조하여 정적 검사 실행

### 지식 복리 (Knowledge Compounding)

```
raw/ → /ingest → wiki/ → /query → wiki/synthesis/
```

소스가 쌓일수록 에이전트의 답변 품질이 높아진다. wiki는 에이전트가 쓰고, 사람이 읽는다.

### raw/ 불변성

`raw/`의 모든 파일은 원본 그대로 보존한다. AI는 읽기만 할 수 있다. `ingest_status` 필드만 예외적으로 수정 허용된다.

---

## 빠른 시작

```bash
# 1. 이 레포지토리를 GitHub 템플릿으로 사용하여 새 레포 생성
# 2. 클론
git clone https://github.com/[your-name]/[your-project].git
cd [your-project]

# 3. 초기화 — git hook 설치 + wiki/raw 디렉토리 생성
bash init.sh

# 4. AI 에이전트에서 인터뷰 시작
/setup
```

`/setup`은 중간에 중단해도 완료된 카테고리가 보존된다. 나중에 이어서 진행할 수 있다.

---

## 프로젝트 구조

```
[your-project]/
├── AGENT.md                        ← 에이전트 지시서 (단일 진실 소스, /setup이 생성)
├── CLAUDE.md                       ← @AGENT.md (Claude Code용 1줄 래퍼)
├── init.sh                         ← 초기화 스크립트 (clone 후 한 번만 실행)
│
├── skills/
│   ├── setup/
│   │   ├── SKILL.md                ← 13개 카테고리 인터뷰 플로우
│   │   └── ambiguity-check.md      ← 모호성 평가 서브스킬
│   ├── capture/SKILL.md            ← 회의·결정·dev-log 캡처
│   ├── ingest/SKILL.md             ← raw/ → wiki/ 통합
│   ├── query/SKILL.md              ← wiki 기반 질의응답
│   ├── code-lint/SKILL.md          ← 컨벤션 기반 코드 검증
│   ├── wiki-lint/SKILL.md          ← wiki 품질 점검
│   └── dashboard/SKILL.md          ← 대시보드 렌더링
│
├── .hooks/
│   ├── convention-check.sh         ← pre-commit: 보안·정적 분석 검사
│   └── devlog-auto.sh              ← post-commit: dev-log 자동 생성
│
├── wiki/                           ← 에이전트가 소유·유지하는 지식 베이스
│   ├── conventions/                ← /setup이 생성하는 컨벤션 페이지 (13개)
│   ├── decisions/                  ← 아키텍처·기술 결정 기록
│   ├── devlog/                     ← 개발 진행 기록
│   ├── meetings/                   ← 회의록
│   ├── sources/                    ← raw 소스 요약 페이지
│   ├── synthesis/                  ← 종합 분석 페이지
│   ├── index.md                    ← 전체 wiki 카탈로그
│   ├── log.md                      ← 오퍼레이션 로그
│   └── dashboard.md                ← 프로젝트 현황 대시보드
│
└── raw/                            ← 불변 원본 소스 (읽기 전용)
    ├── meetings/
    ├── decisions/
    ├── dev-logs/
    └── ideas/
```

---

## 현재 상태

| 항목 | 상태 |
|---|---|
| 스킬 파일 7개 (setup·capture·ingest·query·code-lint·wiki-lint·dashboard) | ✅ 완료 |
| ambiguity-check 서브스킬 | ✅ 완료 |
| git hook 2개 (convention-check·devlog-auto) | ✅ 완료 |
| init.sh | ✅ 완료 |
| AGENT.md 템플릿 | ✅ 완료 |
| AutoDoc MAS v2 dogfooding | 🔜 예정 |

---

## 영감

- [Andrej Karpathy — LLM Wiki 패턴 (GitHub Gist)](https://gist.github.com/karpathy/00d7fb4bde0f8c7ef86ab2a2b3ab6bcd)
- [walkinglabs/awesome-harness-engineering](https://github.com/walkinglabs/awesome-harness-engineering)
