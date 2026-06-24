# agent-setup.sh — 에이전트별 스킬 심링크 + 컨텍스트 파일 설정 함수
# source로 불러서 사용 (직접 실행 불가)
# 사용: source "$(dirname "$0")/scripts/agent-setup.sh"

_GUM=$(command -v gum 2>/dev/null || true)

if [ -z "$_GUM" ]; then
  echo "💡 gum (터미널 UI 라이브러리)이 없습니다. 설치하면 인터랙티브 선택 UI를 사용할 수 있습니다."
  if command -v brew &>/dev/null; then
    echo -n "   brew install gum 으로 설치할까요? [Y/n]: "
    read -r _install_gum
    if [ "$_install_gum" != "n" ] && [ "$_install_gum" != "N" ]; then
      echo "   설치 중..."
      brew install gum
      _GUM=$(command -v gum 2>/dev/null || true)
      echo "  ✅ gum 설치 완료"
    else
      echo "  ⏭  gum 없이 진행합니다 (번호 입력 방식)"
    fi
  else
    echo "   brew가 없습니다. 수동 설치: https://github.com/charmbracelet/gum"
    echo "  ⏭  gum 없이 진행합니다 (번호 입력 방식)"
  fi
  echo ""
fi

# gum이 없으면 read 기반 fallback
_confirm() {
  local msg="$1"
  if [ -n "$_GUM" ]; then
    gum confirm "$msg"
  else
    local _ans
    read -r -p "  ${msg} [y/N]: " _ans
    [ "$_ans" = "y" ] || [ "$_ans" = "Y" ]
  fi
}

# 단일 선택 (gum choose / 번호 입력 fallback)
# 반환값: 선택된 항목 문자열 그대로
_choose_one() {
  if [ -n "$_GUM" ]; then
    gum choose "$@"
  else
    local i=1
    for opt in "$@"; do echo "  $i) $opt"; ((i++)); done
    local _num
    read -r -p "선택 [기본값: 1]: " _num
    [ -z "$_num" ] && _num=1
    local j=1
    for opt in "$@"; do
      [ "$j" = "$_num" ] && echo "$opt" && return
      ((j++))
    done
    echo "$1"
  fi
}

# 텍스트 입력 (gum input / read fallback)
_input() {
  local placeholder="$1"
  if [ -n "$_GUM" ]; then
    gum input --placeholder "$placeholder"
  else
    local _val
    read -r -p "${placeholder}: " _val
    echo "$_val"
  fi
}

# ── 에이전트 설정 함수 ──

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
  local label="$1"
  echo "  📦 ${label} 스킬 심링크 설정 중..."
  mkdir -p .agents/skills
  for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    [ -f "${skill_dir}SKILL.md" ] || continue
    ln -sf "$(pwd)/${skill_dir}" ".agents/skills/${skill_name}" 2>/dev/null || true
  done
  echo "  ✅ ${label}: .agents/skills/ 심링크 완료"

  local ctx_file="AGENTS.md"
  if [ -f "$ctx_file" ]; then
    _confirm "⚠️  $ctx_file 이미 존재합니다. 덮어쓸까요?" || return 0
  fi
  printf '@AGENT.md\n' > "$ctx_file"
  echo "  ✅ ${label}: AGENTS.md 생성 (AGENT.md 자동 임포트)"
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

  local ctx_file=".cursorrules"
  if [ -f "$ctx_file" ]; then
    _confirm "⚠️  $ctx_file 이미 존재합니다. 덮어쓸까요?" || return 0
  fi
  printf '@AGENT.md\n' > "$ctx_file"
  echo "  ✅ Cursor: .cursorrules 생성 (AGENT.md 자동 임포트)"
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
  echo "  📦 Hermes 스킬 심링크 설정 중..."
  mkdir -p .hermes/skills
  for skill_dir in skills/*/; do
    skill_name=$(basename "$skill_dir")
    [ -f "${skill_dir}SKILL.md" ] || continue
    # 상대 경로 사용 — Docker 마운트 후 컨테이너 내부에서도 해석 가능
    rm -f ".hermes/skills/${skill_name}"
    ln -sf "../../${skill_dir}" ".hermes/skills/${skill_name}"
  done
  echo "  ✅ Hermes: .hermes/skills/ 심링크 완료 (상대 경로)"

  # cli-config.yaml — PyYAML로 안전하게 병합
  local config_file="cli-config.yaml"
  python3 - "$config_file" <<'PYEOF'
import sys, os
cfg = sys.argv[1]
try:
    import yaml
except ImportError:
    print("  ⚠️  PyYAML 없음 — pip install pyyaml 후 재실행")
    sys.exit(0)
data = {}
if os.path.exists(cfg):
    with open(cfg) as f:
        data = yaml.safe_load(f) or {}

skills = data.setdefault("skills", {})
dirs = skills.setdefault("external_dirs", [])
if ".hermes/skills/" not in dirs:
    dirs.append(".hermes/skills/")

terminal = data.setdefault("terminal", {})
terminal["docker_mount_cwd_to_workspace"] = True

with open(cfg, "w") as f:
    yaml.dump(data, f, default_flow_style=False, allow_unicode=True)
print(f"  ✅ Hermes: {cfg} 업데이트 (skills.external_dirs + terminal.docker_mount_cwd_to_workspace)")
PYEOF

  # .hermes.md — 컨텍스트 파일 (AGENT.md 임포트)
  local ctx_file=".hermes.md"
  if [ -f "$ctx_file" ]; then
    _confirm "⚠️  $ctx_file 이미 존재합니다. 덮어쓸까요?" || return 0
  fi
  printf '@AGENT.md\n' > "$ctx_file"
  echo "  ✅ Hermes: .hermes.md 생성 (AGENT.md 자동 임포트)"
}

_setup_aider() {
  echo "  📦 Aider 설정 중..."
  local config_file=".aider.conf.yml"
  local new_files=()

  grep -qF "AGENT.md" "$config_file" 2>/dev/null || new_files+=("AGENT.md")

  for skill_dir in skills/*/; do
    local skill_file="${skill_dir}SKILL.md"
    [ -f "$skill_file" ] || continue
    grep -qF "$skill_file" "$config_file" 2>/dev/null || new_files+=("$skill_file")
  done

  if [ ${#new_files[@]} -eq 0 ]; then
    echo "  ✅ Aider: 이미 등록됨 — 건너뜀"
    return
  fi
  python3 - "$config_file" "${new_files[@]}" <<'PYEOF'
import sys, re, os
cfg, *files = sys.argv[1], *sys.argv[2:]
txt = open(cfg).read() if os.path.exists(cfg) else ""
items = ''.join(f'  - {s}\n' for s in files)
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
  echo "  ✅ Aider: .aider.conf.yml read 목록에 AGENT.md + 스킬 추가"
}

# ── 에이전트 선택 메뉴 ──
_run_agent_selection() {
  echo ""
  echo "🤖 사용할 AI 에이전트를 선택하세요"

  local selected_raw _AGENTS_LABEL=""

  if [ -n "$_GUM" ]; then
    selected_raw=$(gum choose --no-limit \
      --header "  스페이스: 선택/해제  •  엔터: 확인" \
      "1  Claude Code     → .claude/skills/" \
      "2  Codex CLI       → .agents/skills/ + AGENTS.md" \
      "3  Antigravity     → .agents/skills/ + AGENTS.md  (Codex와 경로 공유)" \
      "4  Windsurf        → .windsurf/skills/" \
      "5  Cursor          → .cursor/rules/ + .cursorrules" \
      "6  Continue.dev    → .continue/prompts/" \
      "7  Hermes          → .hermes/skills/ + cli-config.yaml + .hermes.md" \
      "8  Aider           → .aider.conf.yml") || true

    [ -z "$selected_raw" ] && selected_raw="1  Claude Code     → .claude/skills/"

    echo ""
    echo "🔧 에이전트 스킬 설정 중..."

    while IFS= read -r line; do
      local num="${line%%[[:space:]]*}"
      case "$num" in
        1) _setup_claude_code ;;
        2) [ -z "$_AGENTS_LABEL" ] && _AGENTS_LABEL="Codex CLI" || _AGENTS_LABEL="${_AGENTS_LABEL} / Codex CLI" ;;
        3) [ -z "$_AGENTS_LABEL" ] && _AGENTS_LABEL="Antigravity" || _AGENTS_LABEL="${_AGENTS_LABEL} / Antigravity" ;;
        4) _setup_windsurf ;;
        5) _setup_cursor ;;
        6) _setup_continue ;;
        7) _setup_hermes ;;
        8) _setup_aider ;;
      esac
    done <<< "$selected_raw"
  else
    echo "   (번호를 쉼표로 구분, 복수 선택 가능. 예: 1,3,4  /  all 입력 시 전체)"
    echo ""
    echo "  1) Claude Code     → .claude/skills/"
    echo "  2) Codex CLI       → .agents/skills/ + AGENTS.md"
    echo "  3) Antigravity     → .agents/skills/ + AGENTS.md  (Codex와 경로 공유)"
    echo "  4) Windsurf        → .windsurf/skills/"
    echo "  5) Cursor          → .cursor/rules/ + .cursorrules"
    echo "  6) Continue.dev    → .continue/prompts/"
    echo "  7) Hermes          → .hermes/skills/ + cli-config.yaml + .hermes.md"
    echo "  8) Aider           → .aider.conf.yml"
    echo ""
    read -r -p "선택 [기본값: 1 (Claude Code)]: " agent_raw
    [ -z "$agent_raw" ] && agent_raw="1"
    [ "$agent_raw" = "all" ] && agent_raw="1,2,3,4,5,6,7,8"

    echo ""
    echo "🔧 에이전트 스킬 설정 중..."

    IFS=',' read -ra _agent_nums <<< "$agent_raw"
    for _num in "${_agent_nums[@]}"; do
      _num=$(echo "$_num" | tr -d ' ')
      case "$_num" in
        1) _setup_claude_code ;;
        2) [ -z "$_AGENTS_LABEL" ] && _AGENTS_LABEL="Codex CLI" || _AGENTS_LABEL="${_AGENTS_LABEL} / Codex CLI" ;;
        3) [ -z "$_AGENTS_LABEL" ] && _AGENTS_LABEL="Antigravity" || _AGENTS_LABEL="${_AGENTS_LABEL} / Antigravity" ;;
        4) _setup_windsurf ;;
        5) _setup_cursor ;;
        6) _setup_continue ;;
        7) _setup_hermes ;;
        8) _setup_aider ;;
        *) echo "  ⚠️  알 수 없는 번호: ${_num} — 건너뜁니다" ;;
      esac
    done
  fi

  [ -n "$_AGENTS_LABEL" ] && _setup_agents_dir "$_AGENTS_LABEL"
}
