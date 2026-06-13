# /code-lint — 컨벤션 기반 코드 검증 스킬

LLM 기반 리뷰 + 정적 분석 도구를 조합해서 코드를 검증한다.
wiki/conventions/의 팀 규칙을 기준으로 판단한다.

---

> **추적:** `python3 scripts/skill_usage.py track code-lint`

---

## Step 0 — 대상 결정

**인자가 있으면**: 해당 파일·디렉토리를 대상으로 한다.

**인자가 없으면**: 변경된 파일 목록을 확인한다.

```bash
{ git diff --name-only HEAD; git ls-files --others --exclude-standard; } | sort -u
```

- 파일이 있으면 해당 목록으로 진행
- 파일이 없으면: "변경된 파일이 없습니다. 파일 경로를 직접 지정해주세요."

---

## Step 1 — 컨벤션 로드

`wiki/conventions/`에서 코드 관련 페이지를 읽는다:

우선순위:
1. `wiki/conventions/03-naming.md` — 네이밍 규칙
2. `wiki/conventions/05-architecture.md` — 아키텍처 규칙
3. `wiki/conventions/06-tdd.md` — TDD 규칙 (테스트 파일 확인)
4. `wiki/conventions/11-error-handling.md` — 에러 핸들링
5. `wiki/conventions/12-security.md` — 보안 규칙

> wiki/conventions/ 가 없으면: "/setup 으로 먼저 컨벤션을 정의해주세요." 안내 후 종료.

---

## Step 2 — 정적 분석 실행

`wiki/conventions/02-tech-stack.md`에서 기술 스택 확인 후 해당 도구를 실행한다.

| 스택 | 도구 | 명령 |
|---|---|---|
| Python | pylint | `pylint [파일]` |
| Python | mypy | `mypy [파일]` |
| JavaScript/TypeScript | eslint | `npx eslint [파일]` |
| Java | checkstyle | `checkstyle [파일]` |

도구가 설치되지 않은 경우: 해당 도구 결과는 건너뛰고 "미설치" 표시.

결과를 저장해두고 Step 3에서 함께 활용한다.

---

## Step 3 — LLM 기반 리뷰

로드한 컨벤션을 기준으로 대상 코드를 읽고 다음 항목을 점검한다:

| 항목 | 점검 내용 |
|---|---|
| **네이밍** | 규칙과 다른 변수명·함수명·클래스명 |
| **아키텍처** | 레이어 간 의존성 방향 위반, 금지된 직접 접근 |
| **TDD** | 기능 코드에 대응하는 테스트 파일 누락 |
| **에러 핸들링** | 나쁜 예외 처리 (bare except, 무시, 무분별한 print) |
| **보안** | 하드코딩된 시크릿, 검증 없는 외부 입력 처리 |
| **컨벤션 추가** | wiki/conventions/에 있는 기타 규칙 |

LLM 리뷰는 정적 분석이 잡지 못하는 **맥락적 판단**에 집중한다.

---

## Step 4 — 통합 리포트

정적 분석 + LLM 리뷰 결과를 합쳐 하나의 리포트로 제시한다:

```text
## /code-lint 결과 — YYYY-MM-DD

### 🔴 위반 (즉시 수정)
- [naming] src/api/userHandler.py:23 — 함수명 `GetUser`는 PascalCase. snake_case 사용 필요
  > 컨벤션: wiki/conventions/03-naming.md
- [security] src/db/connect.py:5 — DB 비밀번호 하드코딩
  > 컨벤션: wiki/conventions/12-security.md

### 🟡 개선 권장
- [tdd] src/services/payment.py — 대응 테스트 파일 없음
- [error-handling] src/utils/parser.py:41 — bare except 사용

### 🟢 정적 분석 결과
pylint: 8.2/10 (경고 3개)
mypy: 에러 없음
```

---

## Step 5 — HITL 확인 (HIGH 위반 시)

🔴 위반이 있으면:

> "위반 사항이 있습니다. 수정 후 다시 실행하거나, 예외로 처리할 항목을 알려주세요.
> 코드 병합 전에 수정을 권장합니다."

- 수정 제안을 원하면 각 항목에 대해 수정 코드를 제안한다
- 예외 처리 시: `wiki/conventions/`에 예외 규칙 추가 여부를 확인한다

---

## 규칙

| 항목 | 규칙 |
|---|---|
| 컨벤션 기준 | wiki/conventions/ 없으면 실행 불가 |
| 정적 도구 | 미설치 시 건너뜀. 강제 설치 금지 |
| 자동 수정 | 금지. 제안만 함 |
| HITL | 🔴 위반 시 반드시 사람 확인 |
| wiki 업데이트 | 예외 인정 시 conventions에 기록 |
