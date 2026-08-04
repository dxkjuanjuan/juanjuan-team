#!/bin/bash
# Juanjuan Team — v2.0 任务分级判定（优化版）
# 用法: ./task-classify.sh <task-description> [<files-list-file>] [--interactive]
#
# 改进（v2.0）:
#   - 加结构化 5 问（ChatGPT 建议）：修改代码？模块数？影响 API？安全关键？新设计？
#   - 减关键词过敏（v1.9 的"login"让 typo 被判 Medium）
#   - 加 --interactive 模式让卷卷回答 5 问
#
# 输出: Lite | Medium | Complex

set -uo pipefail

TASK_DESC="${1:?用法: task-classify.sh <task-description> [<files-list-file>] [--interactive]}"
FILES_LIST_FILE="${2:-}"
INTERACTIVE=false

# 检查 --interactive 标志
for arg in "$@"; do
    [ "$arg" = "--interactive" ] && INTERACTIVE=true
done

# 统计文件数
FILE_COUNT=0
if [ -n "$FILES_LIST_FILE" ] && [ -f "$FILES_LIST_FILE" ]; then
    FILE_COUNT=$(wc -l < "$FILES_LIST_FILE" | tr -d ' ')
fi

# 5 问结构化判定（ChatGPT 建议）
Q1_MODIFY_CODE=0      # 是否修改代码？
Q2_MODULE_COUNT=0     # 涉及几个模块？
Q3_API_IMPACT=0       # 是否影响 API？
Q4_SECURITY_CRITICAL=0 # 是否安全关键？
Q5_NEW_DESIGN=0       # 是否需要新设计？

# 自动判定（基于任务描述 + 文件数）
# Q1: 修改代码？
if echo "$TASK_DESC" | grep -qiE "修|改|fix|update|refactor"; then
    Q1_MODIFY_CODE=1
fi
if echo "$TASK_DESC" | grep -qiE "新功能|新增|添加|创建|设计|实现"; then
    Q1_MODIFY_CODE=2  # 新功能权重更高
fi

# Q2: 模块数（用文件数估算）
if [ "$FILE_COUNT" -eq 0 ]; then
    # 没给文件清单，从任务描述粗估
    if echo "$TASK_DESC" | grep -qiE "跨模块|重构|架构|系统|平台"; then
        Q2_MODULE_COUNT=3
    elif echo "$TASK_DESC" | grep -qiE "新功能|完整|整体"; then
        Q2_MODULE_COUNT=2
    else
        Q2_MODULE_COUNT=1
    fi
elif [ "$FILE_COUNT" -le 1 ]; then
    Q2_MODULE_COUNT=1
elif [ "$FILE_COUNT" -le 5 ]; then
    Q2_MODULE_COUNT=2
else
    Q2_MODULE_COUNT=3
fi

# Q3: 影响 API？
if echo "$TASK_DESC" | grep -qiE "API|接口|端点|endpoint|REST|GraphQL"; then
    Q3_API_IMPACT=1
fi

# Q4: 安全关键（更严格，不只看"login"关键词）
# v2.0 修复：v1.9 把"login typo"误判为安全关键，v2.0 加上下文判断
if echo "$TASK_DESC" | grep -qiE "auth|password|支付|密码|JWT|token|secret|credential|PII|信用卡"; then
    Q4_SECURITY_CRITICAL=1
fi
# 单独"login"不算安全关键，要配合"系统/认证/设计"才算
if echo "$TASK_DESC" | grep -qiE "登录.*系统|认证.*系统|login.*system|auth.*system"; then
    Q4_SECURITY_CRITICAL=1
fi

# Q5: 新设计？
if echo "$TASK_DESC" | grep -qiE "设计|架构|方案|整体|百万用户|大型"; then
    Q5_NEW_DESIGN=1
fi

# Interactive 模式：让卷卷回答 5 问
if [ "$INTERACTIVE" = "true" ]; then
    echo "=== 卷卷请回答 5 问（ChatGPT 建议的结构化判定）==="
    echo "Q1 是否修改代码？(0=否, 1=是, 2=新功能)"
    read -r ANSWER
    [ -n "$ANSWER" ] && Q1_MODIFY_CODE=$ANSWER
    echo "Q2 涉及几个模块？(1/2/3+)"
    read -r ANSWER
    [ -n "$ANSWER" ] && Q2_MODULE_COUNT=$ANSWER
    echo "Q3 是否影响 API？(0=否, 1=是)"
    read -r ANSWER
    [ -n "$ANSWER" ] && Q3_API_IMPACT=$ANSWER
    echo "Q4 是否安全关键？(0=否, 1=是)"
    read -r ANSWER
    [ -n "$ANSWER" ] && Q4_SECURITY_CRITICAL=$ANSWER
    echo "Q5 是否需要新设计？(0=否, 1=是)"
    read -r ANSWER
    [ -n "$ANSWER" ] && Q5_NEW_DESIGN=$ANSWER
fi

# 总分计算
SCORE=$((Q1_MODIFY_CODE + Q2_MODULE_COUNT + Q3_API_IMPACT + Q4_SECURITY_CRITICAL * 2 + Q5_NEW_DESIGN))

# 判定
if [ "$Q4_SECURITY_CRITICAL" -ge 1 ] && [ "$SCORE" -ge 5 ]; then
    LEVEL="Complex"
elif [ "$SCORE" -ge 5 ]; then
    LEVEL="Complex"
elif [ "$SCORE" -ge 3 ]; then
    LEVEL="Medium"
else
    LEVEL="Lite"
fi

# 输出
echo "=== 任务分级判定（v2.0）==="
echo "任务: $TASK_DESC"
echo "文件数: $FILE_COUNT"
echo ""
echo "5 问结构化判定:"
echo "  Q1 修改代码: $Q1_MODIFY_CODE"
echo "  Q2 模块数: $Q2_MODULE_COUNT"
echo "  Q3 影响 API: $Q3_API_IMPACT"
echo "  Q4 安全关键: $Q4_SECURITY_CRITICAL"
echo "  Q5 新设计: $Q5_NEW_DESIGN"
echo ""
echo "总分: $SCORE"
echo "判定: $LEVEL"
echo ""
echo "推荐 spawn 方式:"
case $LEVEL in
    Lite|Medium)
        echo "  Agent Teams teammate（同进程独立 context）"
        ;;
    Complex)
        echo "  claude -p 真独立进程（进程级隔离）"
        echo "  scripts/global-spawn.sh <team-name> <role> <prompt-file> <project-dir>"
        ;;
esac
