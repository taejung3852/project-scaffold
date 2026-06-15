#!/bin/bash
# init.sh — project-scaffold 초기화
# 새 프로젝트: GitHub 템플릿 클론 후 실행
# 기존 프로젝트: project-scaffold를 설치 도구로 사용해 기존 레포에 하네스 설치

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TODAY=$(date +%Y-%m-%d)

echo "🚀 project-scaffold 초기화"
echo ""

# ════════════════════════════════════════════════
# 모드 선택
# ════════════════════════════════════════════════
echo "📌 설치 모드를 선택하세요"
echo ""
echo "  1) 새 프로젝트   — 현재 디렉토리에 하네스 초기화"
echo "     (GitHub 템플릿으로 생성한 레포에서 실행)"
echo "  2) 기존 프로젝트 — 이미 존재하는 프로젝트에 하네스 설치"
echo "     (harness 파일 복사 후 초기화)"
echo ""
read -r -p "선택 [기본값: 1]: " _mode
[ -z "$_mode" ] && _mode="1"
if [ "$_mode" != "1" ] && [ "$_mode" != "2" ]; then
  echo "❌ 잘못된 입력입니다. 1 또는 2만 입력해주세요."
  exit 1
fi

# ════════════════════════════════════════════════
# 대상 디렉토리 결정 & 파일 복사 (기존 프로젝트 모드)
# ════════════════════════════════════════════════
if [ "$_mode" = "2" ]; then
  echo ""
  read -p "📁 기존 프로젝트 경로 [기본값: 현재 위치 $(pwd)]: " _target_input
  if [ -z "$_target_input" ]; then
    TARGET_DIR="$(pwd)"
  else
    TARGET_DIR="$(cd "$_target_input" 2>/dev/null && pwd)" || {
      echo "❌ 경로를 찾을 수 없습니다: $_target_input"
      exit 1
    }
  fi

  echo "  → 대상: $TARGET_DIR"
  echo ""
  echo "📋 하네스 파일 복사 중..."

  # 디렉토리 복사 (이미 있으면 덮어쓸지 확인)
  _copy_dir() {
    local name="$1"
    local src="$SCRIPT_DIR/$name"
    local dst="$TARGET_DIR/$name"
    [ -d "$src" ] || return 0
    if [ -d "$dst" ]; then
      read -p "  ⚠️  $name/ 이미 존재합니다. 덮어쓸까요? [y/N]: " _ow
      if [ "$_ow" = "y" ] || [ "$_ow" = "Y" ]; then
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
    read -r -p "  ⚠️  기존 $(basename "$dst") hook이 있습니다. 덮어쓸까요? [y/N]: " _ow_hook
    if [ "$_ow_hook" != "y" ] && [ "$_ow_hook" != "Y" ]; then
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
echo ""
echo "🤖 사용할 AI 에이전트를 선택하세요"
echo "   (번호를 쉼표로 구분, 복수 선택 가능. 예: 1,3,4  /  all 입력 시 전체)"
echo ""
echo "  1) Claude Code     → .claude/skills/"
echo "  2) Codex CLI       → .agents/skills/"
echo "  3) Antigravity     → .agents/skills/  (Codex CLI와 경로 공유)"
echo "  4) Windsurf        → .windsurf/skills/"
echo "  5) Cursor          → .cursor/rules/   (변환 생성)"
echo "  6) Continue.dev    → .continue/prompts/  (변환 생성)"
echo "  7) Hermes          → ~/.hermes/config.yaml 외부 디렉토리 등록"
echo "  8) Aider           → .aider.conf.yml read 목록 추가"
echo ""
read -p "선택 [기본값: 1 (Claude Code)]: " agent_raw

[ -z "$agent_raw" ] && agent_raw="1"
[ "$agent_raw" = "all" ] && agent_raw="1,2,3,4,5,6,7,8"

# ── 에이전트별 설정 함수 ──

_setup_claude_code() {
  echo "  📦 Claude Code 스킬 심링크 설정 중..."
  mkdir -p .claude/skills
  for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    [ -f "${skill_dir}SKILL.md" ] || continue
    ln -sf "$(pwd)/${skill_dir}" ".claude/skills/${skill_name}" 2>/dev/null || true
  done
  echo "  ✅ Claude Code: .claude/skills/ 심링크 완료"
}

_setup_agents_dir() {
  echo "  📦 Codex CLI / Antigravity 스킬 심링크 설정 중..."
  mkdir -p .agents/skills
  for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    [ -f "${skill_dir}SKILL.md" ] || continue
    ln -sf "$(pwd)/${skill_dir}" ".agents/skills/${skill_name}" 2>/dev/null || true
  done
  echo "  ✅ Codex CLI / Antigravity: .agents/skills/ 심링크 완료"
}

_setup_windsurf() {
  echo "  📦 Windsurf 스킬 심링크 설정 중..."
  mkdir -p .windsurf/skills
  for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    [ -f "${skill_dir}SKILL.md" ] || continue
    ln -sf "$(pwd)/${skill_dir}" ".windsurf/skills/${skill_name}" 2>/dev/null || true
  done
  echo "  ✅ Windsurf: .windsurf/skills/ 심링크 완료"
}

_setup_cursor() {
  echo "  📦 Cursor Rules 변환 생성 중..."
  mkdir -p .cursor/rules
  for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    skill_file="${skill_dir}SKILL.md"
    [ -f "$skill_file" ] || continue
    desc=$(grep -m1 "^description:" "$skill_file" | sed 's/^description: *//;s/^"//;s/"$//' 2>/dev/null || echo "/${skill_name} 스킬")
    {
      echo "---"
      echo "description: \"${desc}\""
      echo "---"
      echo ""
      cat "$skill_file"
    } > ".cursor/rules/${skill_name}.mdc"
  done
  echo "  ✅ Cursor: .cursor/rules/*.mdc 생성 완료"
}

_setup_continue() {
  echo "  📦 Continue.dev 프롬프트 변환 생성 중..."
  mkdir -p .continue/prompts
  for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    skill_file="${skill_dir}SKILL.md"
    [ -f "$skill_file" ] || continue
    desc=$(grep -m1 "^description:" "$skill_file" | sed 's/^description: *//;s/^"//;s/"$//' 2>/dev/null || echo "/${skill_name} 스킬")
    {
      echo "---"
      echo "name: ${skill_name}"
      echo "description: \"${desc}\""
      echo "invokable: true"
      echo "---"
      echo ""
      cat "$skill_file"
    } > ".continue/prompts/${skill_name}.md"
  done
  echo "  ✅ Continue.dev: .continue/prompts/*.md 생성 완료"
}

_setup_hermes() {
  echo "  📦 Hermes 외부 스킬 디렉토리 등록 중..."
  mkdir -p "$HOME/.hermes"
  local config_file="$HOME/.hermes/config.yaml"
  local skills_abs
  skills_abs="$(pwd)/skills"
  if grep -qF "$skills_abs" "$config_file" 2>/dev/null; then
    echo "  ✅ Hermes: 이미 등록됨 — 건너뜀"
    return
  fi
  python3 - "$config_file" "$skills_abs" <<'PYEOF'
import sys, re, os
cfg, path = sys.argv[1], sys.argv[2]
txt = open(cfg).read() if os.path.exists(cfg) else ""
if re.search(r'^  external_dirs:', txt, re.MULTILINE):
    txt = re.sub(r'(  external_dirs:(?:\n    - [^\n]+)*)',
                 r'\1\n    - ' + path, txt)
elif re.search(r'^skills:', txt, re.MULTILINE):
    txt = re.sub(r'^(skills:)', r'\1\n  external_dirs:\n    - ' + path,
                 txt, flags=re.MULTILINE)
else:
    if txt and not txt.endswith('\n'):
        txt += '\n'
    txt += 'skills:\n  external_dirs:\n    - ' + path + '\n'
open(cfg, 'w').write(txt)
PYEOF
  echo "  ✅ Hermes: ~/.hermes/config.yaml에 외부 스킬 경로 등록"
}

_setup_aider() {
  echo "  📦 Aider 설정 중..."
  local config_file=".aider.conf.yml"
  local new_skills=()
  for skill_dir in skills/*/; do
    local skill_file="${skill_dir}SKILL.md"
    [ -f "$skill_file" ] || continue
    grep -qF "$skill_file" "$config_file" 2>/dev/null || new_skills+=("$skill_file")
  done
  if [ ${#new_skills[@]} -eq 0 ]; then
    echo "  ✅ Aider: 이미 등록됨 — 건너뜀"
    return
  fi
  python3 - "$config_file" "${new_skills[@]}" <<'PYEOF'
import sys, re, os
cfg, *skills = sys.argv[1], *sys.argv[2:]
txt = open(cfg).read() if os.path.exists(cfg) else ""
items = ''.join(f'  - {s}\n' for s in skills)
if re.search(r'^read:', txt, re.MULTILINE):
    txt = re.sub(r'^(read:(?:\n  - [^\n]+)*)',
                 lambda m: m.group(0) + '\n' + items.rstrip('\n'),
                 txt, flags=re.MULTILINE)
else:
    if txt and not txt.endswith('\n'):
        txt += '\n'
    txt += 'read:\n' + items
open(cfg, 'w').write(txt)
PYEOF
  echo "  ✅ Aider: .aider.conf.yml read 목록에 스킬 추가"
}

# ── 선택 파싱 및 실행 ──
echo ""
echo "🔧 에이전트 스킬 설정 중..."

AGENTS_DIR_DONE=false
IFS=',' read -ra _agent_nums <<< "$agent_raw"

for _num in "${_agent_nums[@]}"; do
  _num=$(echo "$_num" | tr -d ' ')
  case "$_num" in
    1) _setup_claude_code ;;
    2)
      if [ "$AGENTS_DIR_DONE" = false ]; then
        _setup_agents_dir
        AGENTS_DIR_DONE=true
      fi
      ;;
    3)
      if [ "$AGENTS_DIR_DONE" = false ]; then
        _setup_agents_dir
        AGENTS_DIR_DONE=true
      fi
      ;;
    4) _setup_windsurf ;;
    5) _setup_cursor ;;
    6) _setup_continue ;;
    7) _setup_hermes ;;
    8) _setup_aider ;;
    *) echo "  ⚠️  알 수 없는 번호: ${_num} — 건너뜁니다" ;;
  esac
done

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
echo "     (예상 소요: 2~3시간. 중단 후 이어서 진행 가능)"
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
