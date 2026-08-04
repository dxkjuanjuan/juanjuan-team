#!/bin/bash
# Juanjuan Team — v1.9 全局 SPAWN 调度框架
# 用法: ./global-spawn.sh <team-name> <role> <prompt-file> <project-dir>
#
# 启动一个完全独立的 Claude 进程（claude -p headless 模式）
# 每个主角色是真 OS 进程，进程级隔离
# 适用: Complex 任务（>5 文件 / 跨 ≥3 模块 / 安全关键）

set -uo pipefail

TEAM_NAME="${1:?用法: global-spawn.sh <team-name> <role> <prompt-file> <project-dir>}"
ROLE="${2:?用法: global-spawn.sh <team-name> <role> <prompt-file> <project-dir>}"
PROMPT_FILE="${3:?用法: global-spawn.sh <team-name> <role> <prompt-file> <project-dir>}"
PROJECT_DIR="${4:-$HOME/项目}"

# team 工作区
TEAM_DIR="$HOME/.juanjuan/teams/${TEAM_NAME}"
mkdir -p "$TEAM_DIR"/{mailbox,outputs,audit}

# 角色定义文件
ROLE_FILE="$HOME/.claude/agents/juanjuan-${ROLE}.md"
if [ ! -f "$ROLE_FILE" ]; then
    echo "ERROR: 角色文件不存在: $ROLE_FILE" >&2
    exit 1
fi

# prompt 内容
if [ ! -f "$PROMPT_FILE" ]; then
    echo "ERROR: prompt 文件不存在: $PROMPT_FILE" >&2
    exit 1
fi

# 启动 claude -p 真进程
OUTPUT_FILE="$TEAM_DIR/outputs/${ROLE}.jsonl"
LOG_FILE="$TEAM_DIR/outputs/${ROLE}.log"

# v1.9.2 修复（卷卷要求）:
# - 加 --dangerously-skip-permissions: YOLO 模式，跳过所有权限检查
# - 加 --add-dir: 授权读 agent/skill/项目目录
# - rate_limit 429 由 claude 自己重试（max_retries=10）
claude -p \
    --append-system-prompt "$(cat "$ROLE_FILE")" \
    --output-format stream-json \
    --verbose \
    --dangerously-skip-permissions \
    --add-dir "$HOME/.claude/agents" \
    --add-dir "$HOME/.claude/skills" \
    --add-dir "$PROJECT_DIR" \
    < "$PROMPT_FILE" \
    > "$OUTPUT_FILE" 2>"$LOG_FILE" &

PID=$!
echo "$PID" > "$TEAM_DIR/${ROLE}.pid"

# 记录 spawn 事件
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PROMPT_HASH=$(shasum -a 256 "$PROMPT_FILE" | cut -d' ' -f1)
PROMPT_FULL=$(cat "$PROMPT_FILE" | jq -Rs .)

cat >> "$TEAM_DIR/audit/events.jsonl" <<EOF
{"event":"agent_spawn","agent":"$ROLE","team":"$TEAM_NAME","timestamp":"$TS","spawn_method":"claude -p (real process)","pid":$PID,"prompt_file":"$PROMPT_FILE","prompt_hash":"sha256:$PROMPT_HASH","prompt_full":$PROMPT_FULL,"output_file":"$OUTPUT_FILE","isolation":"process-level"}
EOF

echo "✓ $ROLE 已 spawn (PID $PID)"
echo "  team: $TEAM_DIR"
echo "  output: $OUTPUT_FILE"
echo "  log: $LOG_FILE"
echo "  pid_file: $TEAM_DIR/${ROLE}.pid"
echo ""
echo "查看进度:"
echo "  tail -f $OUTPUT_FILE"
echo ""
echo "等完成:"
echo "  wait $PID"
echo ""
echo "杀进程:"
echo "  kill $PID"
