#!/bin/bash
# Juanjuan Team — Hook 强制规则
# 用法: ./hook-enforce.sh <event>
#
# 借鉴 NTCoding 的 Hook 强制规则机制
# 实现 PreToolUse / SubagentStart 的角色边界 + 不可越权检查
#
# 依赖: jq（macOS 自带 / Linux apt install jq）
# 路径自检: 自动定位 skill 目录，不依赖硬编码路径

set -uo pipefail

EVENT="${1:?用法: hook-enforce.sh <event>}"

# 路径自检：自动定位 skill 目录
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
if [ ! -f "$SCRIPT_DIR/SKILL.md" ]; then
  # fallback: 尝试 ~/.claude/skills/juanjuan-team/
  if [ -f "$HOME/.claude/skills/juanjuan-team/SKILL.md" ]; then
    SCRIPT_DIR="$HOME/.claude/skills/juanjuan-team"
  else
    echo "[hook] WARN: 无法定位 juanjuan-team skill 目录，跳过检查" >&2
    exit 0
  fi
fi

# 检查 jq 依赖
if ! command -v jq >/dev/null 2>&1; then
  echo "[hook] WARN: jq 未安装，跳过 Hook 强制规则（建议 brew install jq / apt install jq）" >&2
  exit 0
fi

# 读 stdin（Claude Code 传 JSON）
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null || echo "")

case "$EVENT" in
  pre-tool-use)
    if [ "$TOOL" = "Write" ] || [ "$TOOL" = "Edit" ]; then
      FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null || echo "")
      CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // ""' 2>/dev/null || echo "")

      # 检查文件长度（global-rules §二第6条）
      LINES=$(echo "$CONTENT" | wc -l | tr -d ' ')
      if [ "$LINES" -gt 500 ]; then
        echo "BLOCKED: 文件超过 500 行（$LINES 行），global-rules §二第6条。请拆分。" >&2
        exit 2
      fi

      # 检查 Co-Authored-By（global-rules §二第4条）
      if echo "$CONTENT" | grep -q "Co-Authored-By"; then
        echo "BLOCKED: 检测到 Co-Authored-By trailer，global-rules §二第4条禁止。" >&2
        exit 2
      fi

      # 检查 secrets 硬编码（覆盖 SKILL.md §七 黑名单）
      # sk- (Anthropic) / ghp_ (GitHub) / AKIA (AWS) / -----BEGIN (PEM) / api_key= 等
      if echo "$CONTENT" | grep -qE "(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{30,}|AKIA[A-Z0-9]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|api_key\s*=\s*['\"][a-zA-Z0-9]{20,})"; then
        echo "BLOCKED: 检测到疑似硬编码 secret（sk-/ghp_/AKIA/PEM/api_key），global-rules §五。请用环境变量。" >&2
        exit 2
      fi

      # 检查 .env 文件直接写入 secrets
      if echo "$FILE_PATH" | grep -qE "\.env$"; then
        if echo "$CONTENT" | grep -qE "(KEY|SECRET|TOKEN|PASSWORD)="; then
          echo "BLOCKED: 检测到 .env 文件含 secrets，global-rules §七。请用 .env.example + 环境变量。" >&2
          exit 2
        fi
      fi
    fi
    ;;
  subagent-start)
    # 记录子 Agent 启动（不阻断——PreToolUse 阶段才是检查点）
    echo "[hook] subagent-start: $(date -u +%Y-%m-%dT%H:%M:%SZ) $INPUT" >> /tmp/juanjuan-subagent.log 2>/dev/null || true
    ;;
esac

exit 0
