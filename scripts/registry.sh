#!/bin/bash
# Juanjuan Team — v1.9 项目注册表
# 用法:
#   ./registry.sh register <project-id> <project-dir>
#   ./registry.sh list
#   ./registry.sh latest <project-id>
#   ./registry.sh status <project-id> <new-status>

set -uo pipefail

REGISTRY_FILE="$HOME/.juanjuan/registry.json"
mkdir -p "$(dirname "$REGISTRY_FILE")"

# 初始化 registry
if [ ! -f "$REGISTRY_FILE" ]; then
    echo '{}' > "$REGISTRY_FILE"
fi

CMD="${1:?用法: registry.sh register|list|latest|status ...}"
shift

case "$CMD" in
    register)
        PROJECT_ID="${1:?需要 project-id}"
        PROJECT_DIR="${2:?需要 project-dir}"
        TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

        # 读现有
        EXISTING=$(jq --arg id "$PROJECT_ID" '.[$id] // null' "$REGISTRY_FILE")

        if [ "$EXISTING" = "null" ]; then
            # 新建
            jq --arg id "$PROJECT_ID" \
               --arg dir "$PROJECT_DIR" \
               --arg ts "$TS" \
               '.[$id] = {first_created: $ts, project_dirs: [$dir], latest_dir: $dir, status: "active"}' \
               "$REGISTRY_FILE" > "$REGISTRY_FILE.tmp" && mv "$REGISTRY_FILE.tmp" "$REGISTRY_FILE"
        else
            # 追加
            jq --arg id "$PROJECT_ID" \
               --arg dir "$PROJECT_DIR" \
               --arg ts "$TS" \
               '.[$id].project_dirs += [$dir] | .[$id].latest_dir = $dir | .[$id].status = "active"' \
               "$REGISTRY_FILE" > "$REGISTRY_FILE.tmp" && mv "$REGISTRY_FILE.tmp" "$REGISTRY_FILE"
        fi

        echo "✓ 已注册: $PROJECT_ID"
        echo "  latest_dir: $PROJECT_DIR"
        ;;

    list)
        jq -r 'to_entries[] | "\(.key) [\(.value.status)]: \(.value.project_dirs | length) dirs, latest=\(.value.latest_dir)"' "$REGISTRY_FILE"
        ;;

    latest)
        PROJECT_ID="${1:?需要 project-id}"
        jq -r --arg id "$PROJECT_ID" '.[$id].latest_dir // "未找到"' "$REGISTRY_FILE"
        ;;

    status)
        PROJECT_ID="${1:?需要 project-id}"
        NEW_STATUS="${2:?需要 new-status}"
        jq --arg id "$PROJECT_ID" \
           --arg status "$NEW_STATUS" \
           '.[$id].status = $status' \
           "$REGISTRY_FILE" > "$REGISTRY_FILE.tmp" && mv "$REGISTRY_FILE.tmp" "$REGISTRY_FILE"
        echo "✓ $PROJECT_ID 状态改为 $NEW_STATUS"
        ;;

    *)
        echo "未知命令: $CMD" >&2
        exit 1
        ;;
esac
