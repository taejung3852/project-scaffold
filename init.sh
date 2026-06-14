#!/bin/bash
# init.sh — project-scaffold 초기화
# GitHub 템플릿 클론 후 한 번만 실행하세요

set -e

echo "🚀 project-scaffold 초기화 시작..."
echo ""

# ── Git 저장소 확인 ──
if [ ! -d ".git" ]; then
  echo "❌ .git/ 가 없습니다. git 저장소 루트에서 실행해주세요."
  exit 1
fi

# ── Git hooks 설치 ──
echo "🔗 Git hooks 설치 중..."

HOOKS_DIR=".git/hooks"
CUSTOM_HOOKS=".hooks"

if [ ! -d "$CUSTOM_HOOKS" ]; then
  echo "❌ .hooks/ 디렉토리가 없습니다."
  exit 1
fi

# pre-commit: convention-check
cp "$CUSTOM_HOOKS/convention-check.sh" "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"
echo "  ✅ pre-commit hook 설치 (convention-check)"

# post-commit: devlog-auto
cp "$CUSTOM_HOOKS/devlog-auto.sh" "$HOOKS_DIR/post-commit"
chmod +x "$HOOKS_DIR/post-commit"
echo "  ✅ post-commit hook 설치 (devlog-auto)"

# ── wiki/ 디렉토리 구조 생성 ──
echo ""
echo "📁 wiki/ 구조 생성 중..."

mkdir -p wiki/conventions
mkdir -p wiki/decisions
mkdir -p wiki/devlog
mkdir -p wiki/meetings
mkdir -p wiki/synthesis
mkdir -p wiki/sources

touch wiki/conventions/.gitkeep
touch wiki/decisions/.gitkeep
touch wiki/devlog/.gitkeep
touch wiki/meetings/.gitkeep
touch wiki/synthesis/.gitkeep
touch wiki/sources/.gitkeep

echo "  ✅ wiki/ 구조 생성 완료"

# ── raw/ 디렉토리 구조 생성 ──
echo ""
echo "📁 raw/ 구조 생성 중..."

mkdir -p raw/meetings
mkdir -p raw/decisions
mkdir -p raw/dev-logs
mkdir -p raw/ideas

touch raw/meetings/.gitkeep
touch raw/decisions/.gitkeep
touch raw/dev-logs/.gitkeep
touch raw/ideas/.gitkeep

echo "  ✅ raw/ 구조 생성 완료"

# ── wiki 템플릿 파일 생성 ──
echo ""
echo "📄 wiki 템플릿 파일 생성 중..."

TODAY=$(date +%Y-%m-%d)

if [ ! -f "wiki/index.md" ]; then
  cat > "wiki/index.md" << EOF
---
title: Wiki Index
updated: ${TODAY}
---

# Wiki Index

> /setup 실행 전 상태입니다. /setup 완료 후 자동으로 채워집니다.

## 통계

| 항목 | 수 |
|---|---|
| 전체 페이지 | 0 |
| Conventions | 0 |
| Sources | 0 |

마지막 업데이트: ${TODAY}
EOF
  echo "  ✅ wiki/index.md 생성"
fi

if [ ! -f "wiki/log.md" ]; then
  cat > "wiki/log.md" << EOF
---
title: Wiki Log
updated: ${TODAY}
---

# Wiki Operation Log

> 모든 ingest·query·lint 오퍼레이션이 여기에 기록됩니다.

---
EOF
  echo "  ✅ wiki/log.md 생성"
fi

if [ ! -f "wiki/dashboard.md" ]; then
  cat > "wiki/dashboard.md" << EOF
---
title: Dashboard
updated: ${TODAY}
---

# 프로젝트 대시보드

> /setup 완료 후 /dashboard 로 갱신하세요.

## 📋 오늘 할 일

- [ ] /setup 실행하여 프로젝트 컨벤션 정의

## ⚠️ 주의 필요

- wiki/conventions/ 비어있음 → /setup 필요
EOF
  echo "  ✅ wiki/dashboard.md 생성"
fi

# ── Obsidian 설정 복사 ──
echo ""
echo "🔭 Obsidian 설정 복사 중..."

if [ -d ".obsidian-template" ]; then
  cp -r .obsidian-template/. wiki/.obsidian/
  echo "  ✅ wiki/.obsidian/ 생성 완료 (폴더 색상·그래프·플러그인 설정 포함)"
  echo "     → Obsidian에서 wiki/ 폴더를 vault로 열면 즉시 적용됩니다"
else
  echo "  ⚠️  .obsidian-template/ 폴더가 없습니다. Obsidian 설정이 생략됩니다."
fi

# ── Graphify 설정 ──
echo ""
echo "🔗 Graphify 설정 중..."

if command -v graphify &> /dev/null; then
  echo "  ✅ graphifyy 설치 확인"
  graphify install
  echo "  ✅ graphify install 완료 — AI 에이전트에 스킬 등록됨"
  echo "     → wiki/ 갱신 후 'graphify update wiki/' 로 그래프를 업데이트하세요"
else
  echo "  ⚠️  graphifyy 미설치 — Graphify 스킬을 사용하려면 아래 명령어로 설치하세요:"
  echo ""
  echo "     pip install graphifyy"
  echo "     graphify install"
  echo ""
  echo "     설치 후 'graphify update wiki/' 로 지식 그래프를 빌드할 수 있습니다"
fi

# ── 완료 ──
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 초기화 완료!"
echo ""
echo "다음 단계:"
echo ""
echo "  1. Claude Code (또는 선호 AI 에이전트) 실행"
echo "  2. /setup 입력 → 프로젝트 컨벤션 인터뷰 시작"
echo "     (예상 소요: 2~3시간. 중단 후 이어서 진행 가능)"
echo ""
echo "스킬 목록:"
echo "  /setup       프로젝트 초기 인터뷰"
echo "  /capture     회의·결정·개발 기록"
echo "  /ingest      raw/ → wiki/ 반영"
echo "  /query       wiki 기반 질의응답"
echo "  /code-lint   컨벤션 기반 코드 검증"
echo "  /wiki-lint   wiki 품질 점검"
echo "  /dashboard   프로젝트 현황 대시보드"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
