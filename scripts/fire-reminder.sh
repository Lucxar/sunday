#!/usr/bin/env bash
# fire-reminder.sh — invoked by at(1) at the reminder time.
# Reads the payload JSON (chat_id + text), sends the Telegram message,
# then removes the payload file.
#
# Usage: fire-reminder.sh <payload-json-file>
#
# Not called directly — schedule-reminder.sh queues this via at(1).

set -uo pipefail

if [[ $# -lt 1 ]]; then
  echo "ERROR: payload file missing" >&2
  exit 1
fi

FILE="$1"
if [[ ! -f "$FILE" ]]; then
  echo "ERROR: payload file does not exist: $FILE" >&2
  exit 2
fi

TOKEN_FILE="${TELEGRAM_BOT_TOKEN_FILE:-$HOME/.telegram-bot-token}"
TOKEN=$(cat "$TOKEN_FILE")
LOG="${SUNDAY_REMINDER_LOG:-/tmp/reminder.log}"

# Decorate the message with a reminder prefix and send it.
SEND_PAYLOAD=$(jq '.text = "Reminder: " + .text' "$FILE")

curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
  -H 'Content-Type: application/json' \
  -d "$SEND_PAYLOAD" >> "$LOG" 2>&1

echo "[$(date -Iseconds)] sent reminder from $FILE" >> "$LOG"
rm -f "$FILE"
