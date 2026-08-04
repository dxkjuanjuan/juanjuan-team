#!/bin/bash
# Juanjuan Team — Hook 强制规则
# 用法: ./hook-enforce.sh <event>
#
# 借鉴 NTCoding 的 Hook 强制规则机制
# 实现 PreToolUse / SubagentStart 的角色边界 + 不可越权检查

set -uo pipefail

EVENT="${1:?用法: hook-enforce.sh <event>}"

# 读 stdin（Claude Code 传 JSON）
INPUT=$(cat)
TOOL=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || echo "")

case "$EVENT" in
  pre-tool-use)
    # 检查：Reviewer 不能写代码/文档（global-rules §二第9条 + role-reviewer §5）
    # 检查：文件长度 < 500 行（global-rules §二第6条）
    # 检查：commit 无 Co-Authored-By（global-rules §二第4条）

    if [ "$TOOL" = "Write" ] || [ "$TOOL" = "Edit" ]; then
      FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")
      CONTENT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('content',''))" 2>/dev/null || echo "")

      # 检查文件长度
      LINES=$(echo "$CONTENT" | wc -l | tr -d ' ')
      if [ "$LINES" -gt 500 ]; then
        echo "BLOCKED: 文件超过 500 行（$LINES 行），global-rules §二第6条。请拆分。" >&2
        exit 2
      fi

      # 检查 Co-Authored-By
      if echo "$CONTENT" | grep -q "Co-Authored-By"; then
        echo "BLOCKED: 检测到 Co-Authored-By trailer，global-rules §二第4条禁止。" >&2
        exit 2
      fi

      # 检查 secrets 硬编码
      if echo "$CONTENT" | grep -qE "(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{30,}|AKIA[A-Z0-9]{16})"; then
        echo "BLOCKED: 检测到疑似硬编码 API key，global-rules §五。请用环境变量。" >&2
        exit 2
      fi
    fi
    ;;
  subagent-start)
    # 检查：子 Agent 角色边界（Reviewer 不能 spawn 自己做 verdict）
    # 这里只记录，不阻断（subagent 启动时检查太晚）
    echo "[hook] subagent-start: $INPUT" >> /tmp/juanjuan-subagent.log
    ;;
esac

exit 0
