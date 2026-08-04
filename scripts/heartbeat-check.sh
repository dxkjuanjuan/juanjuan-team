#!/bin/bash
# Juanjuan Team — 心跳检测脚本
# 用法: ./heartbeat-check.sh <项目目录>
#
# 实现 fault-tolerance.md §1.1 的 convener 心跳检测

set -uo pipefail

PROJECT_DIR="${1:?用法: heartbeat-check.sh <项目目录>}"
PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"
HEARTBEAT_FILE="$PROJECT_DIR/.convener-heartbeat.json"

if [ ! -f "$HEARTBEAT_FILE" ]; then
  echo "CRITICAL: convener 心跳文件不存在（从未启动或已崩溃）"
  exit 2
fi

NOW=$(date +%s)
LAST_HEARTBEAT=$(python3 -c "import json,sys; d=json.load(open('$HEARTBEAT_FILE')); print(int(d.get('last_heartbeat_unix', 0)))" 2>/dev/null || echo 0)
DIFF=$((NOW - LAST_HEARTBEAT))

if [ "$DIFF" -gt 90 ]; then
  echo "CRITICAL: convener 失联（${DIFF}s 无心跳，阈值 90s）—— leader 应临时接管"
  exit 2
elif [ "$DIFF" -gt 60 ]; then
  echo "WARN: convener 心跳延迟（${DIFF}s）"
  exit 1
else
  echo "OK: convener 心跳正常（${DIFF}s 前）"
  exit 0
fi
