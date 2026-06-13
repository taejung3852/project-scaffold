#!/bin/bash
# .hooks/convention-check.sh
# wiki/conventions/ 규칙 기반 pre-commit 검사
# init.sh 실행 시 .git/hooks/pre-commit 으로 복사됨

WIKI_CONVENTIONS="wiki/conventions"
FAILED=0

# wiki/conventions/ 없으면 setup 안 된 것 → 경고만 하고 통과
if [ ! -d "$WIKI_CONVENTIONS" ]; then
  echo "⚠️  wiki/conventions/ 없음. /setup 먼저 실행 권장."
  exit 0
fi

# 스테이징된 파일 목록
STAGED=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)

if [ -z "$STAGED" ]; then
  exit 0
fi

echo "🔍 convention-check 실행 중..."

# ── 보안: 하드코딩된 시크릿 탐지 ──
SECRET_PATTERN='(password|secret|api_key|token)\s*=\s*['"'"'"][^'"'"'"]{4,}'
FOUND_SECRETS=$(echo "$STAGED" | xargs grep -lEi "$SECRET_PATTERN" 2>/dev/null)

if [ -n "$FOUND_SECRETS" ]; then
  echo ""
  echo "🔴 [security] 하드코딩된 시크릿 의심:"
  echo "$FOUND_SECRETS" | while read -r file; do
    echo "   → $file"
  done
  FAILED=1
fi

# ── Python: pylint (설치된 경우만) ──
if command -v pylint &>/dev/null; then
  PY_FILES=$(echo "$STAGED" | grep "\.py$")
  if [ -n "$PY_FILES" ]; then
    echo "$PY_FILES" | xargs pylint --errors-only --score=no 2>/dev/null
    if [ $? -ne 0 ]; then
      echo "🔴 [pylint] 에러 발견"
      FAILED=1
    fi
  fi
fi

# ── JavaScript/TypeScript: eslint (설치된 경우만) ──
if command -v npx &>/dev/null && { compgen -G ".eslintrc*" >/dev/null 2>&1 || compgen -G "eslint.config.*" >/dev/null 2>&1; }; then
  JS_FILES=$(echo "$STAGED" | grep -E "\.(js|ts|jsx|tsx)$")
  if [ -n "$JS_FILES" ]; then
    echo "$JS_FILES" | xargs npx eslint --quiet 2>/dev/null
    if [ $? -ne 0 ]; then
      echo "🔴 [eslint] 에러 발견"
      FAILED=1
    fi
  fi
fi

echo ""
if [ "$FAILED" -eq 1 ]; then
  echo "❌ convention-check 실패. 위반 사항을 수정 후 다시 커밋하세요."
  echo "   상세 검사: /code-lint"
  exit 1
fi

echo "✅ convention-check 통과"
exit 0
