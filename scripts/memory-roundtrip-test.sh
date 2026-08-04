#!/bin/bash
# Juanjuan Team — 记忆闭环验证 (v1.5)
# 用法: ./memory-roundtrip-test.sh
#
# 流程: 存一条测试 memory → 立即查 → 验证能查到
# 输出: ROUNDTRIP_PASS 或 ROUNDTRIP_FAIL <reason>
# 详见 references/meta-verification.md §MV-4

set -uo pipefail

# 测试 key + value
TS=$(date -u +%Y%m%d%H%M%S)
TEST_KEY="test-roundtrip-${TS}"
TEST_VALUE="juanjuan-team meta-verify roundtrip test at ${TS}"

# fallback 本地 JSON
JAAOS_MEMORY="$HOME/.jaaos/memory.json"

# 尝试 ruflo MCP（通过 claude CLI 调用）
# 注意：本脚本不直接调 MCP（MCP 在 Claude Code 会话内），而是验证本地 JSON 闭环
# 真正的 MCP 闭环测试由 convener 在会话内跑

# 1. 存
mkdir -p "$(dirname "$JAAOS_MEMORY")"
if [ ! -f "$JAAOS_MEMORY" ]; then
    echo '[]' > "$JAAOS_MEMORY"
fi

# 追加测试条目
if command -v jq >/dev/null 2>&1; then
    jq --arg key "$TEST_KEY" --arg val "$TEST_VALUE" --arg ts "$TS" \
       '. += [{"key": $key, "value": $val, "timestamp": $ts, "namespace": "roundtrip-test"}]' \
       "$JAAOS_MEMORY" > "$JAAOS_MEMORY.tmp" && mv "$JAAOS_MEMORY.tmp" "$JAAOS_MEMORY"
else
    # 无 jq 时简单 append
    echo "{\"key\":\"$TEST_KEY\",\"value\":\"$TEST_VALUE\",\"timestamp\":\"$TS\",\"namespace\":\"roundtrip-test\"}" >> "$JAAOS_MEMORY"
fi

# 2. 查
FOUND=""
if command -v jq >/dev/null 2>&1; then
    FOUND=$(jq -r --arg key "$TEST_KEY" '.[] | select(.key == $key) | .value' "$JAAOS_MEMORY" 2>/dev/null | head -1)
else
    FOUND=$(grep -F "$TEST_KEY" "$JAAOS_MEMORY" 2>/dev/null | head -1)
fi

# 3. 验证
if [ -n "$FOUND" ] && echo "$FOUND" | grep -qF "$TEST_VALUE"; then
    echo "ROUNDTRIP_PASS"
    echo "  key: $TEST_KEY"
    echo "  value: $TEST_VALUE"
    echo "  found: $FOUND"
    exit 0
else
    echo "ROUNDTRIP_FAIL"
    echo "  key: $TEST_KEY"
    echo "  value: $TEST_VALUE"
    echo "  found: (empty)"
    exit 1
fi
