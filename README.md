# project-scaffold

> AI 에이전트와 함께 개발하는 프로젝트를 위한 LLM Wiki 기반 개발 하네스 템플릿

---

## 무엇인가

소프트웨어 개발 프로젝트에 **AI 에이전트 거버넌스 레이어**를 구축하는 GitHub 템플릿이다.

AI 에이전트는 강력하지만, 컨텍스트가 없으면 매번 같은 실수를 반복한다. 팀 컨벤션을 모르고, 지난 결정을 기억하지 못하며, 코드리뷰 기준도 없다. project-scaffold는 이 문제를 **에이전트가 스스로 읽고 따를 수 있는 살아있는 wiki**로 해결한다.

---

## 왜 만들었나

AI 코딩 에이전트를 팀에 도입할 때 가장 큰 장벽은 **"에이전트가 우리 팀처럼 행동하게 만드는 것"**이다.

- 커밋 메시지 형식이 매번 다르다
- 아키텍처 레이어 규칙을 무시한다
- 테스트 없이 구현 코드부터 짠다
- 지난 회의에서 결정한 내용을 알지 못한다

프롬프트로 매번 설명하는 건 확장되지 않는다. 이 문제를 Andrej Karpathy가 제안한 [LLM Wiki 패턴](https://gist.github.com/karpathy/00d7fb4bde0f8c7ef86ab2a2b3ab6bcd)으로 해결한다. 에이전트가 소유·유지하는 구조화된 wiki가 팀 전체의 단일 진실 소스가 된다.

---

## 핵심 기능

### `/setup` — 프로젝트 초기 인터뷰
2~3시간의 심층 인터뷰로 13개 카테고리 컨벤션을 정의한다.
모든 답변은 모호성 검사(ambiguity-check)를 통과해야 다음 질문으로 넘어간다.
완료 시 `wiki/conventions/` 하위에 13개 페이지와 `AGENT.md`가 자동 생성된다.

**인터뷰 카테고리:** 프로젝트 개요 · 기술 스택 · 네이밍 · Git · 아키텍처 · TDD · devlog · HITL 리스크 · 대시보드 · 코드리뷰 · 에러 핸들링 · 보안 · 의존성 관리

### `/capture` — 회의·결정·개발 기록
회의 내용, 아키텍처 결정, 개발 과정을 `raw/`에 저장한다.
저장된 파일은 `/ingest`가 자동으로 탐지하여 wiki에 반영한다.

### `/ingest` — wiki 자동 통합
raw 소스를 읽고 wiki 전체에 통합한다. 단일 소스가 10~15개 페이지에 영향을 줄 수 있다.
소스 요약 페이지 생성 → 관련 페이지 업데이트 → 백링크 감사 → 로그 기록 순으로 진행된다.

### `/query` — wiki 기반 질의응답
"테스트 파일 어디에 두지?" "이 패키지 써도 돼?" 같은 질문에 wiki를 근거로 답한다.
좋은 답변은 `wiki/synthesis/`에 저장되어 지식이 복리로 쌓인다.

### `/code-lint` — 컨벤션 기반 코드 검증
**2-레이어 검증**: 정적 분석 도구(pylint/eslint/mypy) + LLM 컨텍스트 리뷰.
LLM은 `wiki/conventions/`를 읽고 판단한다. 정적 도구가 잡지 못하는 아키텍처·의미적 위반을 탐지한다.

### `/wiki-lint` — wiki 품질 점검
고아 페이지, 깨진 wikilink, 미해결 모순, stale 페이지를 탐지한다.
자동 수정은 하지 않는다. 리포트 후 사용자가 결정한다.

### `/dashboard` — 프로젝트 현황 대시보드
오늘 할 일, 마일스톤 진행도, 최근 devlog를 한 화면에 집약한다.
**3가지 렌더 모드**: markdown(기본) → terminal(컬러 출력) → web(브라우저 HTML)
커밋 훅에 연결되어 커밋마다 자동 갱신된다.

---

## 빠른 시작

```bash
# 1. 이 레포지토리를 GitHub 템플릿으로 사용하여 새 레포 생성
# 2. 클론
git clone https://github.com/[your-name]/[your-project].git
cd [your-project]

# 3. 초기화 (git hook 설치 + wiki/raw 디렉토리 생성)
bash init.sh

# 4. AI 에이전트 실행 후 인터뷰 시작
/setup
```

`/setup`은 중간에 중단해도 완료된 카테고리는 보존된다. 나중에 이어서 진행할 수 있다.

---

## 프로젝트 구조

```
[your-project]/
├── AGENT.md                  ← 에이전트 지시서 (단일 진실 소스)
├── CLAUDE.md                 ← @AGENT.md (Claude Code용 1줄 래퍼)
├── init.sh                   ← 초기화 스크립트 (한 번만 실행)
│
├── skills/                   ← 에이전트 스킬 파일
│   ├── setup/SKILL.md        ← 프로젝트 초기 인터뷰
│   ├── capture/SKILL.md      ← 회의·결정 캡처
│   ├── ingest/SKILL.md       ← raw → wiki 통합
│   ├── query/SKILL.md        ← wiki 기반 질의응답
│   ├── code-lint/SKILL.md    ← 코드 검증
│   ├── wiki-lint/SKILL.md    ← wiki 품질 점검
│   └── dashboard/SKILL.md    ← 대시보드 렌더링
│
├── .hooks/
│   ├── convention-check.sh   ← pre-commit: 컨벤션 위반 차단
│   └── devlog-auto.sh        ← post-commit: devlog 자동 생성
│
├── wiki/                     ← 에이전트가 소유·유지하는 wiki
│   ├── conventions/          ← /setup이 생성하는 컨벤션 페이지 (13개)
│   ├── decisions/            ← 아키텍처 결정 기록
│   ├── devlog/               ← 개발 진행 기록
│   ├── meetings/             ← 회의록
│   ├── synthesis/            ← 종합 분석 페이지
│   ├── sources/              ← raw 소스 요약 페이지
│   ├── index.md              ← 전체 wiki 카탈로그
│   ├── log.md                ← 오퍼레이션 로그
│   └── dashboard.md          ← 대시보드
│
└── raw/                      ← 불변 원본 소스 (읽기 전용)
    ├── meetings/
    ├── decisions/
    ├── dev-logs/
    └── ideas/
```

---

## 설계 원칙

### 에이전트 무관 (Agent-Agnostic)
`AGENT.md` 하나가 모든 AI 에이전트의 단일 진실 소스다.
에이전트를 교체할 때 `AGENT.md`는 그대로 유지되고, 래퍼 파일만 바꾸면 된다.

| 에이전트 | 설정 파일 | 내용 |
|---|---|---|
| Claude Code | `CLAUDE.md` | `@AGENT.md` |
| Cursor | `.cursorrules` | `@AGENT.md` |
| Continue | `.continuerc` | `@AGENT.md` |

### 두 레이어 강제
- **Soft (에이전트 레이어)**: `AGENT.md`가 TDD·보안 규칙을 항상 참조
- **Hard (훅 레이어)**: `.hooks/convention-check.sh`가 커밋 시 정적 검사 실행

### 지식 복리 (Knowledge Compounding)
`raw/` → `/ingest` → `wiki/` → `/query` → `wiki/synthesis/`

소스가 쌓일수록 에이전트의 답변 품질이 높아진다.
wiki는 에이전트가 쓰고 사람이 읽는다.

### ambiguity-check
`/setup` 인터뷰의 모든 답변은 4가지 기준(구체성·실행가능성·예시가능성·완결성)을 통과해야 한다.
"적절히", "필요시" 같은 모호한 답변은 즉시 follow-up을 유발한다.
에이전트가 추가 질문 없이 따를 수 있는 규칙만 wiki에 기록된다.

---

## 상태

| 항목 | 상태 |
|---|---|
| 스킬 파일 (7개) | ✅ 완료 |
| git hooks | ✅ 완료 |
| init.sh | ✅ 완료 |
| AGENT.md 템플릿 | ✅ 완료 |
| AutoDoc MAS v2 dogfooding | 🔜 예정 |

---

## 영감

- [Andrej Karpathy — LLM Wiki 패턴](https://gist.github.com/karpathy/00d7fb4bde0f8c7ef86ab2a2b3ab6bcd)
- [walkinglabs/awesome-harness-engineering](https://github.com/walkinglabs/awesome-harness-engineering)
