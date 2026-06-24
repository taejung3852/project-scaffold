#!/bin/bash
# add-agent.sh — 기존 프로젝트에 AI 에이전트 추가
# init.sh 실행 이후 에이전트를 추가하거나 재설정할 때 사용

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🤖 에이전트 추가 설정"
echo ""

# git 저장소 확인
if [ ! -d ".git" ]; then
  echo "❌ .git/ 가 없습니다. git 저장소 루트에서 실행해주세요."
  exit 1
fi

# skills/ 디렉토리 확인
if [ ! -d "skills" ]; then
  echo "❌ skills/ 디렉토리가 없습니다."
  echo "   init.sh 를 먼저 실행하거나 project-scaffold가 설치된 디렉토리에서 실행해주세요."
  exit 1
fi

# 에이전트 설정 함수 로드
# shellcheck source=scripts/agent-setup.sh
source "${SCRIPT_DIR}/scripts/agent-setup.sh"

# 에이전트 선택 및 실행
_run_agent_selection

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 에이전트 설정 완료!"
echo ""
echo "선택한 에이전트를 실행하고 /setup 으로 컨벤션을 확인하세요."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
