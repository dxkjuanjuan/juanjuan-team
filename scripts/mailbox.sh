#!/bin/bash
# Juanjuan Team — v1.9 Mailbox 消息工具
# 用法:
#   ./mailbox.sh send <team-name> <from> <to> <type> <payload-file>
#   ./mailbox.sh poll <team-name> <role>
#   ./mailbox.sh read <team-name> <msg-file>

set -uo pipefail

CMD="${1:?用法: mailbox.sh send|poll|read ...}"
shift

case "$CMD" in
    send)
        TEAM_NAME="${1:?需要 team-name}"
        FROM="${2:?需要 from}"
        TO="${3:?需要 to}"
        TYPE="${4:?需要 type}"
        PAYLOAD_FILE="${5:?需要 payload-file}"

        TEAM_DIR="$HOME/.juanjuan/teams/${TEAM_NAME}"
        MAILBOX_DIR="$TEAM_DIR/mailbox"
        mkdir -p "$MAILBOX_DIR"

        TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
        MSG_ID="${FROM}_${TO}_$(date +%s%N | tail -c 10)"
        MSG_FILE="$MAILBOX_DIR/${MSG_ID}.json"

        PAYLOAD=$(cat "$PAYLOAD_FILE" | jq -c .)
        cat > "$MSG_FILE" <<EOF
{
  "id": "$MSG_ID",
  "from": "$FROM",
  "to": "$TO",
  "type": "$TYPE",
  "payload": $PAYLOAD,
  "timestamp": "$TS"
}
EOF
        echo "$MSG_FILE"
        ;;

    poll)
        TEAM_NAME="${1:?需要 team-name}"
        ROLE="${2:?需要 role}"

        TEAM_DIR="$HOME/.juanjuan/teams/${TEAM_NAME}"
        MAILBOX_DIR="$TEAM_DIR/mailbox"

        # 找所有发给这个 role 的消息，按时间排序
        for msg_file in $(ls "$MAILBOX_DIR"/*_${ROLE}_*.json 2>/dev/null | sort); do
            [ -f "$msg_file" ] || continue
            # 检查是否已读
            ack_file="${msg_file%.json}.ack"
            if [ ! -f "$ack_file" ]; then
                echo "$msg_file"
            fi
        done
        ;;

    read)
        TEAM_NAME="${1:?需要 team-name}"
        MSG_FILE="${2:?需要 msg-file basename}"

        TEAM_DIR="$HOME/.juanjuan/teams/${TEAM_NAME}"
        FULL_PATH="$TEAM_DIR/mailbox/$MSG_FILE"

        if [ ! -f "$FULL_PATH" ]; then
            echo "ERROR: 消息文件不存在: $FULL_PATH" >&2
            exit 1
        fi

        cat "$FULL_PATH" | jq .

        # 标记已读
        ACK_FILE="${FULL_PATH%.json}.ack"
        echo "{\"read_at\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" > "$ACK_FILE"
        ;;

    *)
        echo "未知命令: $CMD" >&2
        echo "用法: mailbox.sh send|poll|read ..." >&2
        exit 1
        ;;
esac
