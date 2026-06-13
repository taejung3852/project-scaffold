#!/bin/bash
# .hooks/devlog-auto.sh
# 커밋 후 raw/dev-logs/ 에 자동으로 dev-log 항목 생성
# init.sh 실행 시 .git/hooks/post-commit 으로 복사됨

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
COMMIT_MSG=$(git log -1 --pretty=%B | head -5)
COMMIT_HASH=$(git log -1 --pretty=%h)
CHANGED_FILES=$(git diff-tree --no-commit-id -r --name-only HEAD 2>/dev/null | head -20)

DEV_LOG_DIR="raw/dev-logs"
DEV_LOG_FILE="$DEV_LOG_DIR/${DATE}_dev-log_auto.md"

mkdir -p "$DEV_LOG_DIR"

ENTRY="
### 커밋 \`$COMMIT_HASH\` — $TIME

**메시지:**
\`\`\`
$COMMIT_MSG
\`\`\`

**변경 파일:**
$(echo "$CHANGED_FILES" | sed 's/^/- /')
"

if [ -f "$DEV_LOG_FILE" ]; then
  echo "$ENTRY" >> "$DEV_LOG_FILE"
  echo "📝 dev-log 갱신: $DEV_LOG_FILE"
else
  cat > "$DEV_LOG_FILE" << FRONTMATTER
---
title: "${DATE} 개발 일지 (자동 생성)"
raw_type: "dev-log"
date: ${DATE}
created: ${DATE}
description: "${DATE} 커밋 기록 자동 수집"
ingest_status: "⏳ pending"
tags:
  - "raw/dev-log"
  - "auto-generated"
---

# ${DATE} 개발 일지
FRONTMATTER
  echo "$ENTRY" >> "$DEV_LOG_FILE"
  echo "📝 dev-log 생성: $DEV_LOG_FILE"
fi
