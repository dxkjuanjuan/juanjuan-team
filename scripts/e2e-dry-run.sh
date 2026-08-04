#!/bin/bash
# Juanjuan Team — e2e 干跑脚本 (v1.5)
# 用法: ./e2e-dry-run.sh [mode]
#
# 用 mock 任务"写一个 hello world 脚本"跑完整 Lite 流程（6 Phase）
# 不真 spawn Agent，只验证 phase-trace.json 能正确生成
# 输出: <项目目录>/.phase-trace.json
# 详见 references/observability.md

set -uo pipefail

MODE="${1:-auto}"

# 生成 mock 项目目录
TS=$(date "+%Y-%m-%d-%H%M")
RAND4=$(openssl rand -hex 2 2>/dev/null || echo "$$")
PROJECT_DIR="$HOME/项目/${TS}-e2e-dry-run-${RAND4}-hello-world"

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"
git init -q 2>/dev/null || true

# 初始化 .phase-trace.json
TRACE_FILE="$PROJECT_DIR/.phase-trace.json"
cat > "$TRACE_FILE" <<EOF
{
  "task_id": "$(basename "$PROJECT_DIR")",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "mode": "$MODE",
  "runs": [],
  "current_run_id": null,
  "current_phase": null
}
EOF

# mock 函数：模拟一个 Phase 的执行
mock_phase() {
    local phase=$1
    local phase_name=$2
    local agent=$3
    local outcome=$4
    local run_id="run-${phase}-$(date +%Y%m%d%H%M)-$(openssl rand -hex 1 2>/dev/null || echo 00)"

    local started=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    sleep 1  # 模拟执行
    local ended=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # 追加到 trace
    if command -v jq >/dev/null 2>&1; then
        jq --arg rid "$run_id" --arg p "Phase $phase" --arg pn "$phase_name" \
           --arg a "$agent" --arg s "$started" --arg e "$ended" --arg o "$outcome" \
           '.runs += [{"run_id": $rid, "phase": $p, "phase_name": $pn, "agent": $a, "started_at": $s, "ended_at": $e, "outcome": $o, "artifacts": []}] | .current_run_id = $rid | .current_phase = $p | .updated_at = $s' \
           "$TRACE_FILE" > "$TRACE_FILE.tmp" && mv "$TRACE_FILE.tmp" "$TRACE_FILE"
    fi

    echo "  [Phase $phase] $phase_name ($agent) → $outcome  run_id=$run_id"
}

echo "=== Juanjuan Team e2e Dry Run ==="
echo "项目目录: $PROJECT_DIR"
echo "模式: $MODE"
echo ""

# Lite 模式 6 Phase
echo "[Lite 模式 6 Phase 干跑]"
mock_phase "0" "头脑风暴" "convener" "completed"
mock_phase "1" "模式选择" "convener" "completed"
mock_phase "3" "方案生成" "convener+architect" "completed"
mock_phase "7" "实施" "coder" "completed"
mock_phase "8" "代码审查" "reviewer" "completed"
mock_phase "11" "汇报归档" "convener" "completed"

echo ""
echo "=== Dry Run 完成 ==="
echo "phase-trace.json: $TRACE_FILE"
echo ""

# 验证 trace 文件
if command -v jq >/dev/null 2>&1; then
    echo "=== Trace 验证 ==="
    jq '.' "$TRACE_FILE" 2>/dev/null | head -40
    echo ""
    RUN_COUNT=$(jq '.runs | length' "$TRACE_FILE" 2>/dev/null)
    echo "总 runs: $RUN_COUNT (期望 6)"
    if [ "$RUN_COUNT" -eq 6 ]; then
        echo "✓ 干跑成功，trace 完整"
        exit 0
    else
        echo "✗ trace 不完整"
        exit 1
    fi
else
    echo "⚠ jq 未安装，无法验证 trace"
    cat "$TRACE_FILE"
fi
