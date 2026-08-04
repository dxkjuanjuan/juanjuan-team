#!/bin/bash
# Juanjuan Team — 元验证执行器 (v1.5)
# 用法: ./meta-verify.sh <项目目录>
#
# 跑 MV-1 ~ MV-5 五项检查，输出 JSON 报告
# 详见 references/meta-verification.md

set -uo pipefail

PROJECT_DIR="${1:?用法: meta-verify.sh <项目目录>}"
PROJECT_DIR="${PROJECT_DIR/#\~/$HOME}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "{\"error\": \"项目目录不存在: $PROJECT_DIR\"}" >&2
    exit 1
fi

MSG_DIR="$PROJECT_DIR/.msg"
BACKUP_DIR="$PROJECT_DIR/.backups"
MODE_SWITCHES="$PROJECT_DIR/.mode-switches.json"
TRACE_FILE="$PROJECT_DIR/.phase-trace.json"

# 初始化报告
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
CHECKS="[]"

# MV-1: 独立审核证据
check_mv1() {
    local status="skip"
    local evidence=""
    if [ ! -d "$MSG_DIR" ]; then
        echo '{"id":"MV-1","name":"独立审核证据","status":"skip","evidence":"无 .msg 目录"}'
        return
    fi
    # 查找 Phase 4/6/8 的 ack 文件
    local phase4_acks=$(ls "$MSG_DIR"/*_Phase4_*.ack.json 2>/dev/null | wc -l | tr -d ' ')
    local phase6_acks=$(ls "$MSG_DIR"/*_Phase6_*.ack.json 2>/dev/null | wc -l | tr -d ' ')
    local phase8_acks=$(ls "$MSG_DIR"/*_Phase8_*.ack.json 2>/dev/null | wc -l | tr -d ' ')
    local total=$((phase4_acks + phase6_acks + phase8_acks))
    if [ "$total" -ge 3 ]; then
        status="pass"
        evidence="Phase4:$phase4_acks, Phase6:$phase6_acks, Phase8:$phase8_acks ack 文件存在"
    else
        status="fail"
        evidence="三方审核 ack 文件不足（共 $total，应≥3）"
    fi
    echo "{\"id\":\"MV-1\",\"name\":\"独立审核证据\",\"status\":\"$status\",\"evidence\":\"$evidence\"}"
}

# MV-2: 并行调用证据
check_mv2() {
    local status="skip"
    local evidence=""
    if [ ! -d "$MSG_DIR" ]; then
        echo '{"id":"MV-2","name":"并行调用证据","status":"skip","evidence":"无 .msg 目录"}'
        return
    fi
    # 查找 convener 发起三方的 request 文件（Phase 4）
    local architect_reqs=$(ls "$MSG_DIR"/convener_architect_Phase4_*.json 2>/dev/null | head -1)
    local reviewer_reqs=$(ls "$MSG_DIR"/convener_reviewer_Phase4_*.json 2>/dev/null | head -1)
    local docs_reqs=$(ls "$MSG_DIR"/convener_docs-researcher_Phase4_*.json 2>/dev/null | head -1)

    if [ -z "$architect_reqs" ] || [ -z "$reviewer_reqs" ] || [ -z "$docs_reqs" ]; then
        status="skip"
        evidence="Phase 4 三方 request 文件不全，无法验证并行"
    else
        # 提取时间戳（文件名末尾的 <ts>，假设格式 YYYYMMDDHHmmss 或 ISO）
        local t1=$(basename "$architect_reqs" | sed -E 's/.*_([0-9]+)\.json/\1/')
        local t2=$(basename "$reviewer_reqs" | sed -E 's/.*_([0-9]+)\.json/\1/')
        local t3=$(basename "$docs_reqs" | sed -E 's/.*_([0-9]+)\.json/\1/')
        if [ -n "$t1" ] && [ -n "$t2" ] && [ -n "$t3" ]; then
            # 时间差（秒级，文件名时间戳可能是 epoch 或 YYYYMMDDHHmmss）
            # 简单做法：用文件 mtime
            local mt1=$(stat -f %m "$architect_reqs" 2>/dev/null || stat -c %Y "$architect_reqs" 2>/dev/null)
            local mt2=$(stat -f %m "$reviewer_reqs" 2>/dev/null || stat -c %Y "$reviewer_reqs" 2>/dev/null)
            local mt3=$(stat -f %m "$docs_reqs" 2>/dev/null || stat -c %Y "$docs_reqs" 2>/dev/null)
            if [ -n "$mt1" ] && [ -n "$mt2" ] && [ -n "$mt3" ]; then
                local max_ts=$(printf "%s\n%s\n%s\n" "$mt1" "$mt2" "$mt3" | sort -n | tail -1)
                local min_ts=$(printf "%s\n%s\n%s\n" "$mt1" "$mt2" "$mt3" | sort -n | head -1)
                local delta=$((max_ts - min_ts))
                if [ "$delta" -le 1 ]; then
                    status="pass"
                    evidence="三方 request mtime 差 ${delta}s（≤1s 并行）"
                else
                    status="fail"
                    evidence="三方 request mtime 差 ${delta}s（>1s 可能串行）"
                fi
            else
                status="skip"
                evidence="无法获取文件 mtime"
            fi
        else
            status="skip"
            evidence="文件名时间戳解析失败"
        fi
    fi
    echo "{\"id\":\"MV-2\",\"name\":\"并行调用证据\",\"status\":\"$status\",\"evidence\":\"$evidence\"}"
}

# MV-3: 模式切换日志
check_mv3() {
    local status="skip"
    local evidence=""
    if [ ! -f "$MODE_SWITCHES" ]; then
        echo '{"id":"MV-3","name":"模式切换日志","status":"skip","evidence":"无 .mode-switches.json（本次任务未切换模式）"}'
        return
    fi
    # 验证每条记录的 7 字段
    if ! command -v jq >/dev/null 2>&1; then
        status="skip"
        evidence="jq 未安装，无法解析"
    else
        local invalid=$(jq -r '.[] | select((.from // null) == null or (.to // null) == null or (.at // null) == null or (.phase // null) == null or (.reason // null) == null or (.transaction_id // null) == null or (.status // null) == null) | .transaction_id // "unknown"' "$MODE_SWITCHES" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$invalid" -eq 0 ]; then
            local partial=$(jq -r '.[] | select(.status == "partial") | .transaction_id' "$MODE_SWITCHES" 2>/dev/null | wc -l | tr -d ' ')
            if [ "$partial" -gt 0 ]; then
                status="fail"
                evidence="检测到 $partial 条 partial 状态（违反原子性）"
            else
                status="pass"
                evidence="所有模式切换记录字段完整，无 partial"
            fi
        else
            status="fail"
            evidence="$invalid 条记录字段不完整"
        fi
    fi
    echo "{\"id\":\"MV-3\",\"name\":\"模式切换日志\",\"status\":\"$status\",\"evidence\":\"$evidence\"}"
}

# MV-4: 记忆闭环
check_mv4() {
    local status="skip"
    local evidence=""
    # 跑 memory-roundtrip-test.sh
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local roundtrip_script="$script_dir/memory-roundtrip-test.sh"
    if [ ! -x "$roundtrip_script" ]; then
        status="skip"
        evidence="memory-roundtrip-test.sh 不存在或不可执行"
    else
        local result=$("$roundtrip_script" 2>&1 || echo "FAIL")
        if echo "$result" | grep -q "ROUNDTRIP_PASS"; then
            status="pass"
            evidence="存一条测试 memory → 立即查 → 能查到"
        else
            status="fail"
            evidence="记忆闭环失效: $result"
        fi
    fi
    echo "{\"id\":\"MV-4\",\"name\":\"记忆闭环\",\"status\":\"$status\",\"evidence\":\"$evidence\"}"
}

# MV-5: 备份触发
check_mv5() {
    local status="skip"
    local evidence=""
    if [ ! -d "$BACKUP_DIR" ]; then
        echo '{"id":"MV-5","name":"备份触发","status":"skip","evidence":"无 .backups 目录（可能未到 Phase 9）"}'
        return
    fi
    # 检查是否有 tar.gz + bundle
    local tar_count=$(ls "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l | tr -d ' ')
    local bundle_count=$(ls "$BACKUP_DIR"/*.bundle 2>/dev/null | wc -l | tr -d ' ')
    if [ "$tar_count" -ge 1 ]; then
        status="pass"
        evidence="备份存在: $tar_count tar.gz, $bundle_count bundle"
    else
        status="fail"
        evidence="无 tar.gz 备份文件"
    fi
    echo "{\"id\":\"MV-5\",\"name\":\"备份触发\",\"status\":\"$status\",\"evidence\":\"$evidence\"}"
}

# MV-6: 主+sub 双层对抗验证 (v1.6 新增)
check_mv6() {
    local status="skip"
    local evidence=""
    local sub_calls_dir="$MSG_DIR/sub-calls"

    if [ ! -d "$sub_calls_dir" ]; then
        echo '{"id":"MV-6","name":"主+sub 双层对抗","status":"skip","evidence":"无 .msg/sub-calls 目录（未派 sub-agent）"}'
        return
    fi

    # 检查 sub-agent 调用记录数量
    local sub_call_count=$(ls "$sub_calls_dir"/*Phase4_*.json "$sub_calls_dir"/*Phase6_*.json "$sub_calls_dir"/*Phase8_*.json 2>/dev/null | wc -l | tr -d ' ')

    # 检查主 Agent self finding 文件
    local self_findings=$(ls "$MSG_DIR"/*_self_Phase4_*.json "$MSG_DIR"/*_self_Phase6_*.json "$MSG_DIR"/*_self_Phase8_*.json 2>/dev/null | wc -l | tr -d ' ')

    if [ "$sub_call_count" -eq 0 ] && [ "$self_findings" -eq 0 ]; then
        status="skip"
        evidence="无 sub-agent 调用和主 Agent self finding（可能未到 Phase 4/6/8）"
    elif [ "$sub_call_count" -eq 0 ]; then
        status="fail"
        evidence="主 Agent 有 self finding 但未派 sub-agent（违反双层对抗）"
    elif [ "$self_findings" -eq 0 ]; then
        status="fail"
        evidence="派了 sub-agent 但主 Agent 无 self finding（违反主 Agent 必须参与）"
    else
        # 时间戳验证：主 Agent self 必须 ≤ sub-agent 调用 + 1s（平行产出）
        local earliest_sub=$(ls -t "$sub_calls_dir"/*Phase[468]_*.json 2>/dev/null | tail -1)
        local earliest_self=$(ls -t "$MSG_DIR"/*_self_Phase[468]_*.json 2>/dev/null | tail -1)

        if [ -n "$earliest_sub" ] && [ -n "$earliest_self" ]; then
            local sub_mt=$(stat -f %m "$earliest_sub" 2>/dev/null || stat -c %Y "$earliest_sub" 2>/dev/null)
            local self_mt=$(stat -f %m "$earliest_self" 2>/dev/null || stat -c %Y "$earliest_self" 2>/dev/null)
            if [ -n "$sub_mt" ] && [ -n "$self_mt" ]; then
                local delta=$((self_mt - sub_mt))
                if [ "$delta" -le 1 ] && [ "$delta" -ge -60 ]; then
                    # 检查 verdict 是否含 consensus/divergence/blind_spots 分类
                    # 简化：检查任何 verdict 文件是否含这些字段
                    local has_classification=$(grep -lE '"(consensus|divergence|blind_spots)"' "$MSG_DIR"/*Phase[468]*.json 2>/dev/null | wc -l | tr -d ' ')
                    if [ "$has_classification" -ge 1 ]; then
                        status="pass"
                        evidence="sub-calls=$sub_call_count, self_findings=$self_findings, 时间差=${delta}s（平行产出）, finding 已分类"
                    else
                        status="fail"
                        evidence="sub/self 都有但 verdict 未分类（缺 consensus/divergence/blind_spots）"
                    fi
                else
                    status="fail"
                    evidence="主 Agent self 与 sub-agent 时间差 ${delta}s（>1s 可能锚定效应）"
                fi
            else
                status="skip"
                evidence="无法获取 mtime，跳过时间戳验证"
            fi
        else
            status="pass"
            evidence="sub-calls=$sub_call_count, self_findings=$self_findings（时间戳验证跳过）"
        fi
    fi
    echo "{\"id\":\"MV-6\",\"name\":\"主+sub 双层对抗\",\"status\":\"$status\",\"evidence\":\"$evidence\"}"
}

# 跑 6 项检查
MV1=$(check_mv1)
MV2=$(check_mv2)
MV3=$(check_mv3)
MV4=$(check_mv4)
MV5=$(check_mv5)
MV6=$(check_mv6)

# 汇总
FAIL_COUNT=$(printf "%s\n%s\n%s\n%s\n%s\n%s\n" "$MV1" "$MV2" "$MV3" "$MV4" "$MV5" "$MV6" | grep -c '"status":"fail"' || true)
FAIL_COUNT=${FAIL_COUNT:-0}
FAIL_COUNT=$(echo "$FAIL_COUNT" | tail -1)
FAIL_COUNT=${FAIL_COUNT:-0}

if [ "$FAIL_COUNT" -eq 0 ]; then
    OVERALL="pass"
else
    OVERALL="fail"
fi

# 输出 JSON
cat <<EOF
{
  "project_dir": "$PROJECT_DIR",
  "timestamp": "$TIMESTAMP",
  "checks": [
    $MV1,
    $MV2,
    $MV3,
    $MV4,
    $MV5,
    $MV6
  ],
  "overall": "$OVERALL",
  "failures": $FAIL_COUNT
}
EOF

exit 0
