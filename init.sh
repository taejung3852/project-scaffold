#!/bin/bash
# init.sh — project-scaffold 초기화
# 새 프로젝트: GitHub 템플릿 클론 후 실행
# 기존 프로젝트: project-scaffold를 설치 도구로 사용해 기존 레포에 하네스 설치

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TODAY=$(date +%Y-%m-%d)

# shellcheck source=scripts/agent-setup.sh
source "${SCRIPT_DIR}/scripts/agent-setup.sh"

echo "🚀 project-scaffold 초기화"
echo ""

# ════════════════════════════════════════════════
# 모드 선택
# ════════════════════════════════════════════════
echo "📌 설치 모드를 선택하세요"
echo ""
_mode_label=$(_choose_one \
  "1  새 프로젝트   — 현재 디렉토리에 하네스 초기화" \
  "2  기존 프로젝트 — 이미 존재하는 프로젝트에 하네스 설치")
_mode="${_mode_label%%[[:space:]]*}"

if [ "$_mode" != "1" ] && [ "$_mode" != "2" ]; then
  echo "❌ 잘못된 입력입니다."
  exit 1
fi

# ════════════════════════════════════════════════
# 대상 디렉토리 결정 & 파일 복사 (기존 프로젝트 모드)
# ════════════════════════════════════════════════
if [ "$_mode" = "2" ]; then
  echo ""
  _target_input=$(_input "/Users/me/workspace/MyProject")
  if [ -z "$_target_input" ]; then
    echo "❌ 경로를 입력해주세요. (예: /Users/me/workspace/MyProject)"
    exit 1
  fi
  TARGET_DIR="$(cd "$_target_input" 2>/dev/null && pwd)" || {
    echo "❌ 경로를 찾을 수 없습니다: $_target_input"
    exit 1
  }

  echo "  → 대상: $TARGET_DIR"

  if [ "$TARGET_DIR" = "$SCRIPT_DIR" ]; then
    echo ""
    echo "❌ 대상 경로가 project-scaffold 자체입니다."
    echo "   기존 프로젝트의 경로를 입력해주세요."
    echo "   예: /Users/me/workspace/MyProject"
    exit 1
  fi

  echo ""
  echo "📋 하네스 파일 복사 중..."

  # 디렉토리 복사 (이미 있으면 덮어쓸지 확인)
  _copy_dir() {
    local name="$1"
    local src="$SCRIPT_DIR/$name"
    local dst="$TARGET_DIR/$name"
    [ -d "$src" ] || return 0
    if [ -d "$dst" ]; then
      if _confirm "⚠️  $name/ 이미 존재합니다. 덮어쓸까요?"; then
        cp -r "$src/." "$dst/"
        echo "  ✅ $name/ 덮어쓰기 완료"
      else
        echo "  ⏭  $name/ 건너뜀 (기존 유지)"
      fi
    else
      cp -r "$src" "$TARGET_DIR/"
      echo "  ✅ $name/ 복사 완료"
    fi
  }

  # 파일 복사 (없을 때만)
  _copy_file_if_absent() {
    local name="$1"
    local src="$SCRIPT_DIR/$name"
    local dst="$TARGET_DIR/$name"
    [ -f "$src" ] || return 0
    if [ -f "$dst" ]; then
      echo "  ⏭  $name 이미 존재 — 건너뜀 (기존 유지)"
    else
      cp "$src" "$dst"
      echo "  ✅ $name 복사 완료"
    fi
  }

  _copy_dir  "skills"
  _copy_dir  "scripts"
  _copy_dir  ".hooks"
  _copy_dir  ".obsidian-template"
  _copy_file_if_absent "AGENT.md"
  _copy_file_if_absent "SOUL.md"
  _copy_file_if_absent "CLAUDE.md"

  # .gitignore — 병합 (덮어쓰기 아님)
  if [ -f "$SCRIPT_DIR/.gitignore" ]; then
    if [ -f "$TARGET_DIR/.gitignore" ]; then
      echo ""
      echo "  📄 .gitignore 병합 중 (기존 파일에 없는 항목만 추가)..."
      while IFS= read -r line; do
        # 빈 줄·주석은 건너뜀
        [[ -z "$line" || "$line" == \#* ]] && continue
        if ! grep -qF "$line" "$TARGET_DIR/.gitignore" 2>/dev/null; then
          echo "$line" >> "$TARGET_DIR/.gitignore"
        fi
      done < "$SCRIPT_DIR/.gitignore"
      echo "  ✅ .gitignore 병합 완료"
    else
      cp "$SCRIPT_DIR/.gitignore" "$TARGET_DIR/.gitignore"
      echo "  ✅ .gitignore 복사 완료"
    fi
  fi

  # init.sh 복사 (대상 프로젝트에서 재실행 가능하도록)
  cp "$SCRIPT_DIR/init.sh" "$TARGET_DIR/init.sh"
  echo "  ✅ init.sh 복사 완료 (이후 재실행 가능)"

  # 이후 모든 작업은 TARGET_DIR에서
  cd "$TARGET_DIR"
  echo ""
  echo "  → 이후 작업을 $TARGET_DIR 에서 진행합니다"

else
  TARGET_DIR="$(pwd)"
fi

# ════════════════════════════════════════════════
# Git 저장소 확인
# ════════════════════════════════════════════════
echo ""
if [ ! -d ".git" ]; then
  echo "❌ .git/ 가 없습니다. git 저장소 루트에서 실행해주세요."
  exit 1
fi

# ════════════════════════════════════════════════
# Git hooks 설치
# ════════════════════════════════════════════════
echo "🔗 Git hooks 설치 중..."

HOOKS_DIR=".git/hooks"
CUSTOM_HOOKS=".hooks"

if [ ! -d "$CUSTOM_HOOKS" ]; then
  echo "❌ .hooks/ 디렉토리가 없습니다."
  exit 1
fi

_install_hook() {
  local src="$1" dst="$2" label="$3"
  if [ -f "$dst" ]; then
    if ! _confirm "⚠️  기존 $(basename "$dst") hook이 있습니다. 덮어쓸까요?"; then
      echo "  ⏭  $(basename "$dst") hook 건너뜀 (기존 유지)"
      return
    fi
  fi
  cp "$src" "$dst"
  chmod +x "$dst"
  echo "  ✅ $(basename "$dst") hook 설치 ($label)"
}

_install_hook "$CUSTOM_HOOKS/convention-check.sh" "$HOOKS_DIR/pre-commit" "convention-check"
_install_hook "$CUSTOM_HOOKS/devlog-auto.sh" "$HOOKS_DIR/post-commit" "devlog-auto"

# ════════════════════════════════════════════════
# wiki/ 디렉토리 구조 생성
# ════════════════════════════════════════════════
echo ""
echo "📁 wiki/ 구조 생성 중..."

for _dir in wiki/conventions wiki/decisions wiki/devlog wiki/meetings wiki/synthesis wiki/sources; do
  mkdir -p "$_dir"
  touch "$_dir/.gitkeep"
done

echo "  ✅ wiki/ 구조 생성 완료"

# ════════════════════════════════════════════════
# raw/ 디렉토리 구조 생성
# ════════════════════════════════════════════════
echo ""
echo "📁 raw/ 구조 생성 중..."

for _dir in raw/meetings raw/decisions raw/dev-logs raw/ideas; do
  mkdir -p "$_dir"
  touch "$_dir/.gitkeep"
done

echo "  ✅ raw/ 구조 생성 완료"

# ════════════════════════════════════════════════
# wiki 템플릿 파일 생성
# ════════════════════════════════════════════════
echo ""
echo "📄 wiki 템플릿 파일 생성 중..."

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

# ════════════════════════════════════════════════
# Obsidian 설정 복사
# ════════════════════════════════════════════════
echo ""
echo "🔭 Obsidian 설정 복사 중..."

if [ -d ".obsidian-template" ]; then
  mkdir -p wiki/.obsidian
  cp -r .obsidian-template/. wiki/.obsidian/
  echo "  ✅ wiki/.obsidian/ 생성 완료 (폴더 색상·그래프·플러그인 설정 포함)"
  echo "     → Obsidian에서 wiki/ 폴더를 vault로 열면 즉시 적용됩니다"
else
  echo "  ⚠️  .obsidian-template/ 폴더가 없습니다. Obsidian 설정이 생략됩니다."
fi

# ════════════════════════════════════════════════
# 에이전트 선택
# ════════════════════════════════════════════════
_run_agent_selection

# ════════════════════════════════════════════════
# Graphify 설정
# ════════════════════════════════════════════════
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

# ════════════════════════════════════════════════
# 완료
# ════════════════════════════════════════════════
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 초기화 완료!"

# 기존 프로젝트 모드: project-scaffold 디렉토리 자동 삭제
if [ "$_mode" = "2" ] && [ "$SCRIPT_DIR" != "$TARGET_DIR" ]; then
  echo ""
  echo "🗑  project-scaffold 설치 디렉토리 삭제 중..."
  echo "   ($SCRIPT_DIR)"
  rm -rf "$SCRIPT_DIR"
  echo "  ✅ 삭제 완료 — 모든 파일은 $TARGET_DIR 에 있습니다"
fi

echo ""
echo "다음 단계:"
echo ""
if [ "$_mode" = "2" ]; then
  echo "  1. 위에서 선택한 AI 에이전트로 $TARGET_DIR 열기"
  echo "  2. /setup 입력 → 기존 코드 기반으로 컨벤션 인터뷰 시작"
else
  echo "  1. 위에서 선택한 AI 에이전트 실행"
  echo "  2. /setup 입력 → 프로젝트 컨벤션 인터뷰 시작"
fi
echo "     (예상 소요: 약 1시간. 중단 후 이어서 진행 가능)"
echo ""
echo "스킬 목록:"
echo "  /setup       프로젝트 초기 인터뷰"
echo "  /capture     회의·결정·개발 기록"
echo "  /ingest      raw/ → wiki/ 반영"
echo "  /query       wiki 기반 질의응답"
echo "  /report      회의·인터뷰·ADR 리포트 생성 (내 파악용 + 팀 공유용)"
echo "  /code-lint   컨벤션 기반 코드 검증"
echo "  /wiki-lint   wiki 품질 점검"
echo "  /dashboard   프로젝트 현황 대시보드"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
