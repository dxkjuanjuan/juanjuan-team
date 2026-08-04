#!/bin/bash
# Juanjuan Team — v1.9 任务分级判定
# 用法: ./task-classify.sh <task-description> [<files-list-file>]
#
# 输出: Lite | Medium | Complex
#
# 判定逻辑:
#   - 涉及文件数 ≤1 + 不跨模块 + 无架构影响 + 无新功能 → Lite
#   - 涉及文件 2-5 / 跨 1-2 模块 / 新功能但不跨模块 → Medium
#   - >5 文件 / 跨 ≥3 模块 / 安全关键（auth/payment/PII）/ 大型架构设计 → Complex

set -uo pipefail

TASK_DESC="${1:?用法: task-classify.sh <task-description> [<files-list-file>]}"
FILES_LIST_FILE="${2:-}"

# 统计文件数
FILE_COUNT=0
if [ -n "$FILES_LIST_FILE" ] && [ -f "$FILES_LIST_FILE" ]; then
    FILE_COUNT=$(wc -l < "$FILES_LIST_FILE" | tr -d ' ')
fi

# 计分
SCORE=0
REASONS=()

# 文件数
if [ "$FILE_COUNT" -ge 5 ]; then
    SCORE=$((SCORE + 3))
    REASONS+=("文件数 $FILE_COUNT ≥5 (+3)")
elif [ "$FILE_COUNT" -ge 2 ]; then
    SCORE=$((SCORE + 2))
    REASONS+=("文件数 $FILE_COUNT 在 2-5 (+2)")
elif [ "$FILE_COUNT" -eq 1 ]; then
    SCORE=$((SCORE + 1))
    REASONS+=("文件数 1 (+1)")
fi

# 安全关键（关键词匹配）
if echo "$TASK_DESC" | grep -qiE "auth|login|password|payment|信用卡|支付|密码|登录|JWT|token|secret|credential"; then
    SCORE=$((SCORE + 3))
    REASONS+=("安全关键 (+3)")
fi

# 跨模块（关键词）
if echo "$TASK_DESC" | grep -qiE "跨模块|重构|架构|系统|平台|服务|微服务"; then
    SCORE=$((SCORE + 2))
    REASONS+=("跨模块/架构 (+2)")
fi

# 大型架构设计
if echo "$TASK_DESC" | grep -qiE "设计|架构|方案|整体|完整|百万用户"; then
    SCORE=$((SCORE + 2))
    REASONS+=("大型架构设计 (+2)")
fi

# 新功能
if echo "$TASK_DESC" | grep -qiE "新功能|新增|添加|创建"; then
    SCORE=$((SCORE + 1))
    REASONS+=("新功能 (+1)")
fi

# 单文件
if [ "$FILE_COUNT" -le 1 ] && [ $SCORE -lt 3 ]; then
    LEVEL="Lite"
elif [ $SCORE -ge 5 ]; then
    LEVEL="Complex"
elif [ $SCORE -ge 3 ]; then
    LEVEL="Medium"
else
    LEVEL="Lite"
fi

echo "=== 任务分级判定 ==="
echo "任务: $TASK_DESC"
echo "文件数: $FILE_COUNT"
echo "得分: $SCORE"
echo "理由:"
for r in "${REASONS[@]}"; do
    echo "  - $r"
done
echo ""
echo "判定: $LEVEL"
echo ""
echo "推荐 spawn 方式:"
case $LEVEL in
    Lite)
        echo "  Agent Teams teammate（同进程独立 context）"
        echo "  scripts/spawn-agent-team.sh <role> <prompt-file>"
        ;;
    Medium)
        echo "  Agent Teams teammate（同进程独立 context）"
        echo "  scripts/spawn-agent-team.sh <role> <prompt-file>"
        ;;
    Complex)
        echo "  claude -p 真独立进程（进程级隔离）"
        echo "  scripts/global-spawn.sh <team-name> <role> <prompt-file>"
        ;;
esac
