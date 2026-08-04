#!/bin/bash
# Juanjuan Team Skill - 一键安装脚本
# 用法: ./install.sh [target_dir]
# 默认安装到 ~/.claude/skills/juanjuan-team/

set -uo pipefail

TARGET_DIR="${1:-$HOME/.claude/skills/juanjuan-team}"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Juanjuan Team Skill 安装 ==="
echo "源目录: $SCRIPT_DIR"
echo "目标目录: $TARGET_DIR"
echo ""

# 检查源目录
if [ ! -f "$SCRIPT_DIR/SKILL.md" ]; then
  echo "ERROR: 源目录无效（找不到 SKILL.md）: $SCRIPT_DIR"
  exit 1
fi

# 创建目标目录的父目录
mkdir -p "$(dirname "$TARGET_DIR")"

# 如果目标已存在，先备份
if [ -e "$TARGET_DIR" ]; then
  BACKUP="$TARGET_DIR.backup.$(date +%Y%m%d%H%M%S)"
  echo "已存在，备份到: $BACKUP"
  mv "$TARGET_DIR" "$BACKUP"
fi

# symlink（推荐）或 copy
if [ "$1" = "--copy" ]; then
  echo "复制模式（--copy）..."
  cp -r "$SCRIPT_DIR" "$TARGET_DIR"
else
  echo "symlink 模式（默认，推荐——源码更新自动同步）..."
  ln -s "$SCRIPT_DIR" "$TARGET_DIR"
fi

# 给脚本加可执行权限
chmod +x "$TARGET_DIR/references/backup-script.sh" 2>/dev/null
chmod +x "$TARGET_DIR/scripts/"*.sh 2>/dev/null

echo ""
echo "=== 安装完成 ==="
echo ""
echo "验证:"
echo "  ls $TARGET_DIR/SKILL.md"
ls -la "$TARGET_DIR/SKILL.md" 2>&1 | head -1
echo ""
echo "使用方法:"
echo "  重启 Claude Code，在对话中说 'juanjuan skill' 或 'team up' 即可触发"
echo ""
echo "如要更新（symlink 模式）:"
echo "  cd $SCRIPT_DIR && git pull"
echo "  自动同步到 $TARGET_DIR"
echo ""
echo "如要卸载:"
echo "  rm $TARGET_DIR"
