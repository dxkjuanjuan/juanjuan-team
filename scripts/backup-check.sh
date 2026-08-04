#!/bin/bash
# Juanjuan Team — 备份触发条件检查
# 用法: ./backup-check.sh <项目目录>
#
# 检查是否符合备份触发条件:
#   1. git diff 累计 > 200 行
#   2. 文件改动数 > 5 个
# 输出 "BACKUP" 或 "SKIP"

set -uo pipefail

PROJECT_DIR="${1:-}"
PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"

if [ ! -d "$PROJECT_DIR/.git" ]; then
    echo "SKIP (非 git 仓库)"
    exit 0
fi

cd "$PROJECT_DIR" || exit 1

# 统计改动文件数（git tracked，含新增/修改/删除）
CHANGED_FILES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' \n')
CHANGED_FILES=${CHANGED_FILES:-0}

# 统计改动行数（新增 + 删除，对 HEAD；无 commit 时退化为 unstaged diff）
if git rev-parse HEAD >/dev/null 2>&1; then
    DIFF_LINES=$(git diff HEAD 2>/dev/null | grep -cE "^[+-]" || echo 0)
else
    DIFF_LINES=$(git diff 2>/dev/null | grep -cE "^[+-]" || echo 0)
fi
# grep -c 会把 +/- 行都各算一次，需排除 --- +++ 头
DIFF_LINES=${DIFF_LINES:-0}

echo "diff_lines=$DIFF_LINES"
echo "changed_files=$CHANGED_FILES"

SHOULD_BACKUP=false
REASON=""

if [ "$DIFF_LINES" -gt 200 ] 2>/dev/null; then
    SHOULD_BACKUP=true
    REASON="diff_lines > 200 ($DIFF_LINES)"
elif [ "$CHANGED_FILES" -gt 5 ] 2>/dev/null; then
    SHOULD_BACKUP=true
    REASON="changed_files > 5 ($CHANGED_FILES)"
fi

if [ "$SHOULD_BACKUP" = "true" ]; then
    echo "BACKUP ($REASON)"
else
    echo "SKIP (diff=$DIFF_LINES, files=$CHANGED_FILES, 未达阈值)"
fi
