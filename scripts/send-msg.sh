#!/bin/bash
# Juanjuan Team — Agent 间消息发送脚本
# 用法: ./send-msg.sh <项目目录> <from> <to> <phase> <type> <payload-json>
#
# 实现 message-protocol.md §1.1 的文件消息机制

set -uo pipefail

PROJECT_DIR="${1:?用法: send-msg.sh <项目目录> <from> <to> <phase> <type> <payload-json>}"
FROM="${2:?missing from}"
TO="${3:?missing to}"
PHASE="${4:?missing phase}"
TYPE="${5:?missing type}"
PAYLOAD="${6:-{}}"

PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"
MSG_DIR="$PROJECT_DIR/.msg"
mkdir -p "$MSG_DIR"

TS=$(date "+%Y%m%d-%H%M%S")
ID="${FROM}-${TO}-${PHASE}-${TS}-$$"
FILE="$MSG_DIR/${FROM}_${TO}_${PHASE}_${TS}.json"

cat > "$FILE" << EOF
{
  "id": "$ID",
  "from": "$FROM",
  "to": "$TO",
  "phase": "$PHASE",
  "type": "$TYPE",
  "payload": $PAYLOAD,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "ack": false
}
EOF

echo "$FILE"
echo "msg-id: $ID"
