#!/bin/bash
# Juanjuan Team - v2.2 接着跑命令
# 用法: ./continue.sh <project-id>
#
# 场景: 卷卷说"接着跑 todo-list"
# 流程:
#   1. 查 registry.json 找 project-id 对应的最新项目目录
#   2. 调 resume.sh 检查状态
#   3. 输出下一步建议

set -uo pipefail

PROJECT_ID="${1:?用法: continue.sh <project-id>}"
REGISTRY_FILE="$HOME/.juanjuan/registry.json"

if [ ! -f "$REGISTRY_FILE" ]; then
    echo "❌ 无 registry.json，没有注册过任何项目"
    exit 1
fi

LATEST_DIR=$(jq -r --arg id "$PROJECT_ID" '.[$id].latest_dir // empty' "$REGISTRY_FILE")

if [ -z "$LATEST_DIR" ]; then
    echo "❌ 项目 ID '$PROJECT_ID' 未注册过"
    echo ""
    echo "已注册的项目:"
    jq -r 'to_entries[] | "  - \(.key) [\(.value.status)]: \(.value.project_dirs | length) dirs"' "$REGISTRY_FILE"
    exit 1
fi

echo "=== 接着跑: $PROJECT_ID ==="
echo "最新目录: $LATEST_DIR"
echo ""

# 调 resume.sh 检查状态
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$SCRIPT_DIR/resume.sh" "$LATEST_DIR"
