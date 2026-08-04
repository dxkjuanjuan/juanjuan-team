#!/bin/bash
# Juanjuan Team — Lite 模式判断脚本
# 用法: ./lite-check.sh <任务描述> [文件数]
#
# 实现 lite-mode.md §一的触发条件判断

set -uo pipefail

TASK_DESC="${1:?用法: lite-check.sh <任务描述> [文件数]}"
FILE_COUNT="${2:-1}"

# 判断 4 个条件
IS_SINGLE_FILE=0
IS_NO_CROSS_MODULE=0
IS_NO_ARCH_IMPACT=0
IS_NO_NEW_FEATURE=0

# 条件 1: 单文件
if [ "$FILE_COUNT" -eq 1 ]; then
  IS_SINGLE_FILE=1
fi

# 条件 2: 不跨模块（任务描述不含"跨"/"多模块"/"集成"）
if ! echo "$TASK_DESC" | grep -qE "跨|多模块|集成|多个文件"; then
  IS_NO_CROSS_MODULE=1
fi

# 条件 3: 无架构影响（不含"架构"/"重构"/"迁移"/"重构"）
if ! echo "$TASK_DESC" | grep -qE "架构|重构|迁移|重写"; then
  IS_NO_ARCH_IMPACT=1
fi

# 条件 4: 无新功能（不含"新功能"/"新增"/"实现"/"开发"）
if ! echo "$TASK_DESC" | grep -qE "新功能|新增|实现|开发"; then
  IS_NO_NEW_FEATURE=1
fi

TOTAL=$((IS_SINGLE_FILE + IS_NO_CROSS_MODULE + IS_NO_ARCH_IMPACT + IS_NO_NEW_FEATURE))

if [ "$TOTAL" -eq 4 ]; then
  echo "LITE: 建议走 Lite 模式（6 Phase）—— 4/4 条件满足"
  echo "  单文件=$IS_SINGLE_FILE 不跨模块=$IS_NO_CROSS_MODULE 无架构=$IS_NO_ARCH_IMPACT 无新功能=$IS_NO_NEW_FEATURE"
  exit 0
else
  echo "FULL: 走全流程（11 Phase + 0.5）—— $TOTAL/4 条件满足"
  echo "  单文件=$IS_SINGLE_FILE 不跨模块=$IS_NO_CROSS_MODULE 无架构=$IS_NO_ARCH_IMPACT 无新功能=$IS_NO_NEW_FEATURE"
  exit 1
fi
