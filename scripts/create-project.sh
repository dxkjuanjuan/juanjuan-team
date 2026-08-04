#!/bin/bash
# Juanjuan Team — 项目目录创建脚本（自动加 4 位随机后缀，避免撞名）
# 用法: ./create-project.sh <任务简述>
# 输出: 项目目录路径

set -uo pipefail

TASK_DESC="${1:?用法: create-project.sh <任务简述>}"
TS=$(date "+%Y-%m-%d-%H%M")
RAND4=$(openssl rand -hex 2 2>/dev/null || echo "$$")
DIR_NAME="${TS}-${TASK_DESC}-${RAND4}"
PROJECT_DIR="$HOME/项目/${DIR_NAME}"

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"
git init -q
echo "# ${TASK_DESC}" > README.md
echo "" >> README.md
echo "Created by juanjuan-team v1.4.1" >> README.md
echo "Created at: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> README.md
git add . && git -c user.email=juanjuan@local -c user.name="juanjuan-team" commit -m "init: ${TASK_DESC}" -q

echo "$PROJECT_DIR"
