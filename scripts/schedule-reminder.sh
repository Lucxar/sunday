#!/usr/bin/env bash
# schedule-reminder.sh — schedule a Telegram push for a later time via at(1).
#
# Usage: schedule-reminder.sh "<when>" "<chat_id>" "<message>"
#
# <when> accepts at(1) syntax:
#   "now + 5 minutes"
#   "15:00"
#   "15:00 tomorrow"
#   "10:30 2026-05-12"
#   "next monday 10:00"

set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "ERROR: usage: $0 '<when>' '<chat_id>' '<message>'" >&2
  exit 1
fi

WHEN="$1"
CHAT_ID="$2"
MESSAGE="$3"

REMINDER_DIR="$HOME/.reminders"
mkdir -p "$REMINDER_DIR"
RID="$(date +%s)-$$-$RANDOM"
PAYLOAD_FILE="$REMINDER_DIR/$RID.json"

# Store the payload as JSON to avoid quoting hell when at(1) executes.
jq -n --arg cid "$CHAT_ID" --arg t "$MESSAGE" \
  '{chat_id: ($cid|tonumber), text: $t}' > "$PAYLOAD_FILE"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "bash $SCRIPT_DIR/fire-reminder.sh '$PAYLOAD_FILE'" | at "$WHEN" 2>&1
echo "scheduled reminder id=$RID at='$WHEN'"
