#!/bin/bash
# Juanjuan Team — v1.8 Commit 0 验证脚本
# 用法: ./v1.8-commit0-verify.sh
#
# 检查 v1.8 Commit 0 的产出是否完整:
#   1. 3 个 agent 定义文件存在
#   2. audit-event-schema.md 存在
#   3. SKILL.md 有 §十六 v1.8 MVP 章节
#   4. agent 文件有正确的 YAML frontmatter
#   5. 目录协议在 SKILL.md 里定义清楚

set -uo pipefail

AGENTS_DIR="$HOME/.claude/agents"
SKILL_DIR="$HOME/.claude/skills/juanjuan-team"

PASS=0
FAIL=0

check() {
    local name=$1
    local condition=$2
    if [ "$condition" = "true" ]; then
        echo "  ✓ $name"
        PASS=$((PASS + 1))
    else
        echo "  ✗ $name"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== v1.8 Commit 0 验证 ==="
echo ""

echo "[1] Agent 定义文件存在性"
check "juanjuan-convener.md" "$([ -f "$AGENTS_DIR/juanjuan-convener.md" ] && echo true || echo false)"
check "juanjuan-architect.md" "$([ -f "$AGENTS_DIR/juanjuan-architect.md" ] && echo true || echo false)"
check "juanjuan-reviewer.md" "$([ -f "$AGENTS_DIR/juanjuan-reviewer.md" ] && echo true || echo false)"
echo ""

echo "[2] Agent 文件 YAML frontmatter"
for f in juanjuan-convener juanjuan-architect juanjuan-reviewer; do
    file="$AGENTS_DIR/$f.md"
    has_frontmatter=$(head -1 "$file" 2>/dev/null | grep -q "^---$" && echo true || echo false)
    has_name=$(grep -q "^name: $f" "$file" 2>/dev/null && echo true || echo false)
    has_description=$(grep -q "^description:" "$file" 2>/dev/null && echo true || echo false)
    has_tools=$(grep -q "^tools:" "$file" 2>/dev/null && echo true || echo false)
    has_model=$(grep -q "^model:" "$file" 2>/dev/null && echo true || echo false)
    check "$f frontmatter ---" "$has_frontmatter"
    check "$f name 字段" "$has_name"
    check "$f description 字段" "$has_description"
    check "$f tools 字段" "$has_tools"
    check "$f model 字段" "$has_model"
done
echo ""

echo "[3] audit-event-schema.md"
check "schema 文件存在" "$([ -f "$SKILL_DIR/references/audit-event-schema.md" ] && echo true || echo false)"
check "schema 含 agent_spawn 事件" "$(grep -q 'agent_spawn' "$SKILL_DIR/references/audit-event-schema.md" 2>/dev/null && echo true || echo false)"
check "schema 含 allowed_files 字段" "$(grep -q 'allowed_files' "$SKILL_DIR/references/audit-event-schema.md" 2>/dev/null && echo true || echo false)"
check "schema 含 forbidden_files 字段" "$(grep -q 'forbidden_files' "$SKILL_DIR/references/audit-event-schema.md" 2>/dev/null && echo true || echo false)"
check "schema 含 prompt_full 字段" "$(grep -q 'prompt_full' "$SKILL_DIR/references/audit-event-schema.md" 2>/dev/null && echo true || echo false)"
echo ""

echo "[4] SKILL.md v1.8 章节"
check "SKILL.md 含 §十六 v1.8 MVP" "$(grep -q '## 十六、v1.8 MVP' "$SKILL_DIR/SKILL.md" 2>/dev/null && echo true || echo false)"
check "SKILL.md 含 6 Phase 流程" "$(grep -q 'MVP 6 Phase' "$SKILL_DIR/SKILL.md" 2>/dev/null && echo true || echo false)"
check "SKILL.md 含目录协议" "$(grep -q '目录协议' "$SKILL_DIR/SKILL.md" 2>/dev/null && echo true || echo false)"
check "SKILL.md 含盲审硬约束" "$(grep -q '盲审硬约束' "$SKILL_DIR/SKILL.md" 2>/dev/null && echo true || echo false)"
check "SKILL.md 含验收标准" "$(grep -q '验收标准' "$SKILL_DIR/SKILL.md" 2>/dev/null && echo true || echo false)"
echo ""

echo "[5] Agent 文件内容关键点"
check "convener 含 6 Phase 流程" "$(grep -q 'Phase 0\|Phase 1\|Phase 2\|Phase 3\|Phase 4\|Phase 5' "$AGENTS_DIR/juanjuan-convener.md" 2>/dev/null && echo true || echo false)"
check "convener 含 Agent 工具调用指令" "$(grep -q '调用 Agent 工具' "$AGENTS_DIR/juanjuan-convener.md" 2>/dev/null && echo true || echo false)"
check "convener 含盲审隔离规则" "$(grep -q '绝对不能' "$AGENTS_DIR/juanjuan-convener.md" 2>/dev/null && echo true || echo false)"
check "architect 含 design.md vs reasoning.md 分离" "$(grep -q 'design.md\|reasoning.md' "$AGENTS_DIR/juanjuan-architect.md" 2>/dev/null && echo true || echo false)"
check "architect 含策略性语言禁止" "$(grep -q '考虑过\|担心\|怕' "$AGENTS_DIR/juanjuan-architect.md" 2>/dev/null && echo true || echo false)"
check "reviewer 含只读 design.md 约束" "$(grep -q '不读.*reasoning' "$AGENTS_DIR/juanjuan-reviewer.md" 2>/dev/null && echo true || echo false)"
check "reviewer 含 5 审查维度" "$(grep -q '数据一致性\|扩展性\|安全\|API 设计\|边界情况' "$AGENTS_DIR/juanjuan-reviewer.md" 2>/dev/null && echo true || echo false)"
echo ""

echo "=== 验证结果 ==="
echo "通过: $PASS"
echo "失败: $FAIL"
if [ "$FAIL" -eq 0 ]; then
    echo ""
    echo "✓ v1.8 Commit 0 验证通过"
    exit 0
else
    echo ""
    echo "✗ v1.8 Commit 0 验证失败，请检查上述 ✗ 项"
    exit 1
fi
