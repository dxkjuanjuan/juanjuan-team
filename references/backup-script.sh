#!/bin/bash
# Juanjuan Team — 智能备份脚本
# 用法: ./backup-script.sh <项目目录> <任务简述> [--full]
#
# 功能:
#   1. tar.gz 整个项目目录（排除 secrets + 构建产物 + node_modules + .git）
#   2. git bundle 完整 git 历史
#   3. 命名: YYYY-MM-DD-HHmm-<任务简述>.tar.gz / .bundle
#   4. 位置: <项目目录>/.backups/
#   5. 频率控制: 每日 3 次（本地时区）

set -uo pipefail

PROJECT_DIR="${1:-}"
TASK_DESC="${2:-}"
FULL_MODE="${3:-}"

if [ -z "$PROJECT_DIR" ] || [ -z "$TASK_DESC" ]; then
    echo "用法: $0 <项目目录> <任务简述> [--full]"
    echo "例: $0 ~/项目/2026-08-03-1430-fix-login \"fix-login\""
    exit 1
fi

# 展开 ~
PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "ERROR: 项目目录不存在: $PROJECT_DIR"
    exit 1
fi

BACKUP_DIR="$PROJECT_DIR/.backups"
mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date "+%Y-%m-%d-%H%M")
TAR_NAME="${TIMESTAMP}-${TASK_DESC}.tar.gz"
BUNDLE_NAME="${TIMESTAMP}-${TASK_DESC}-git-bundle.bundle"

# === 频率控制: 每日 3 次 ===
TODAY=$(date "+%Y-%m-%d")
TODAY_COUNT=$(ls "$BACKUP_DIR" 2>/dev/null | grep "^${TODAY}-" | wc -l | tr -d ' ')

if [ "$TODAY_COUNT" -ge 3 ]; then
    echo "WARN: 今日备份已达 3 次上限（已有 $TODAY_COUNT 份）"
    echo "如需强制备份，请删除旧备份或手动运行 tar 命令"
    exit 2
fi

# === secrets 黑名单 ===
SECRET_PATTERNS=(
    ".env"
    ".env.*"
    "*.pem"
    "*.key"
    "id_rsa"
    "id_ed25519"
    "*.ppk"
    ".npmrc"
    ".pypirc"
    ".aws"
    ".gnupg"
    "*.keystore"
    "*.jks"
    "*.kdbx"
    "credentials.json"
    "*.htpasswd"
    ".netrc"
    ".gcloud"
    "*.p12"
    "*.pfx"
)

# === 构建排除参数 ===
EXCLUDES=(
    "--exclude=.git"
    "--exclude=node_modules"
    "--exclude=.backups"
)

# 构建产物默认排除，--full 时才包含
if [ "$FULL_MODE" != "--full" ]; then
    EXCLUDES+=(
        "--exclude=dist"
        "--exclude=build"
        "--exclude=.next"
        "--exclude=.nuxt"
        "--exclude=target"
        "--exclude=__pycache__"
        "--exclude=*.pyc"
    )
fi

# 加 secrets 黑名单
for pattern in "${SECRET_PATTERNS[@]}"; do
    EXCLUDES+=("--exclude=$pattern")
done

# === 1. tar.gz 备份 ===
echo "[1/2] 创建 tar.gz 备份..."
TAR_PATH="$BACKUP_DIR/$TAR_NAME"
# 进入项目目录的父目录，用项目名作为 tar 的根
PARENT_DIR=$(dirname "$PROJECT_DIR")
PROJECT_NAME=$(basename "$PROJECT_DIR")

tar -czf "$TAR_PATH" -C "$PARENT_DIR" "${EXCLUDES[@]}" "$PROJECT_NAME" 2>/dev/null || {
    echo "ERROR: tar.gz 创建失败"
    exit 3
}

TAR_SIZE=$(du -h "$TAR_PATH" | cut -f1)
echo "  ✓ $TAR_PATH ($TAR_SIZE)"

# === 2. git bundle 备份 ===
echo "[2/2] 创建 git bundle 备份..."
BUNDLE_PATH="$BACKUP_DIR/$BUNDLE_NAME"

if [ -d "$PROJECT_DIR/.git" ]; then
    # 在项目目录内执行 git bundle
    (cd "$PROJECT_DIR" && git bundle create "$BUNDLE_PATH" --all 2>/dev/null) || {
        echo "WARN: git bundle 创建失败（可能不是 git 仓库或无 commit）"
        BUNDLE_PATH=""
    }
    if [ -n "$BUNDLE_PATH" ] && [ -f "$BUNDLE_PATH" ]; then
        BUNDLE_SIZE=$(du -h "$BUNDLE_PATH" | cut -f1)
        echo "  ✓ $BUNDLE_PATH ($BUNDLE_SIZE)"
    fi
else
    echo "  SKIP: 非 git 仓库，跳过 git bundle"
    BUNDLE_PATH=""
fi

# === 汇总 ===
echo ""
echo "=== 备份完成 ==="
echo "时间戳: $TIMESTAMP"
echo "任务: $TASK_DESC"
echo "tar.gz: $TAR_PATH"
[ -n "$BUNDLE_PATH" ] && echo "bundle: $BUNDLE_PATH"
echo "今日备份次数: $((TODAY_COUNT + 1)) / 3"
