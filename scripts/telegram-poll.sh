#!/usr/bin/env bash
# telegram-poll.sh — long-poll the Telegram bot, forward messages to
# claude-respond.sh, send replies back. Voice notes are transcribed via
# voice-to-text.sh first.
#
# Run as a daemon (systemd recommended — see scripts/README.md).
#
# Allowlist of permitted Telegram user IDs comes from
# $TELEGRAM_ALLOWED_IDS_FILE (default ~/.telegram-bot-allowed-ids),
# one numeric ID per line.

set -uo pipefail

TOKEN_FILE="${TELEGRAM_BOT_TOKEN_FILE:-$HOME/.telegram-bot-token}"
ALLOWED_FILE="${TELEGRAM_ALLOWED_IDS_FILE:-$HOME/.telegram-bot-allowed-ids}"

if [[ ! -r "$TOKEN_FILE" ]]; then
  echo "ERROR: token file $TOKEN_FILE not readable" >&2
  exit 1
fi
if [[ ! -r "$ALLOWED_FILE" ]]; then
  echo "ERROR: allowlist file $ALLOWED_FILE not readable" >&2
  echo "Create it with one Telegram user id per line (chmod 600)." >&2
  exit 1
fi

TOKEN=$(cat "$TOKEN_FILE")
OFFSET_FILE="$HOME/.telegram-offset"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="${SUNDAY_POLL_LOG:-/tmp/telegram-poll.log}"

API="https://api.telegram.org/bot${TOKEN}"

log() {
  echo "[$(date -Iseconds)] $*" | tee -a "$LOG"
}

is_allowed() {
  local id="$1"
  grep -qxF "$id" "$ALLOWED_FILE"
}

send_message() {
  local chat_id="$1"
  local text="$2"
  curl -s -X POST "${API}/sendMessage" \
    -H 'Content-Type: application/json' \
    -d "$(jq -n --arg cid "$chat_id" --arg t "$text" '{chat_id: $cid|tonumber, text: $t}')" \
      > /dev/null
}

process_update() {
  local update_json="$1"
  local from_id chat_id text voice_file_id
  from_id=$(echo "$update_json" | jq -r '.message.from.id // empty')
  chat_id=$(echo "$update_json" | jq -r '.message.chat.id // empty')
  text=$(echo "$update_json" | jq -r '.message.text // empty')
  voice_file_id=$(echo "$update_json" | jq -r '.message.voice.file_id // empty')

  if [[ -z "$from_id" ]]; then
    log "skip: no from.id (probably edited message or other update type)"
    return
  fi

  if ! is_allowed "$from_id"; then
    log "skip: unauthorized user $from_id"
    return
  fi

  local user_message=""
  if [[ -n "$voice_file_id" ]]; then
    log "voice update — file_id=$voice_file_id, transcribing"
    local file_path
    file_path=$(curl -s "${API}/getFile?file_id=${voice_file_id}" | jq -r '.result.file_path // empty')
    if [[ -z "$file_path" ]]; then
      log "ERROR: getFile returned no file_path"
      send_message "$chat_id" "Could not fetch the voice file."
      return
    fi
    user_message=$("$SCRIPT_DIR/voice-to-text.sh" "$file_path" 2>>"$LOG")
    if [[ -z "$user_message" ]]; then
      log "ERROR: whisper returned empty transcription"
      send_message "$chat_id" "Voice note could not be transcribed."
      return
    fi
    log "transcript: $user_message"
  elif [[ -n "$text" ]]; then
    user_message="$text"
    log "text update: $user_message"
  else
    log "skip: no text/voice in message"
    return
  fi

  log "calling claude..."
  local response
  response=$("$SCRIPT_DIR/claude-respond.sh" "$user_message" "telegram-$chat_id" 2>>"$LOG")
  if [[ -z "$response" ]]; then
    response="Empty reply from Claude — check the Pi logs."
    log "ERROR: empty claude response"
  else
    log "response: ${response:0:200}..."
  fi
  send_message "$chat_id" "$response"
}

log "telegram-poll started"

OFFSET=$(cat "$OFFSET_FILE" 2>/dev/null || echo 0)
log "starting with offset=$OFFSET"

while true; do
  RESPONSE=$(curl -s --max-time 35 "${API}/getUpdates?offset=${OFFSET}&timeout=25&allowed_updates=%5B%22message%22%5D")
  if [[ -z "$RESPONSE" ]]; then
    log "empty response from getUpdates — sleeping 5s"
    sleep 5
    continue
  fi
  OK=$(echo "$RESPONSE" | jq -r '.ok')
  if [[ "$OK" != "true" ]]; then
    log "API error: $RESPONSE"
    sleep 5
    continue
  fi
  COUNT=$(echo "$RESPONSE" | jq '.result | length')
  if [[ "$COUNT" -gt 0 ]]; then
    log "got $COUNT updates"
    while IFS= read -r update; do
      UPDATE_ID=$(echo "$update" | jq -r '.update_id')
      process_update "$update"
      OFFSET=$((UPDATE_ID + 1))
      echo "$OFFSET" > "$OFFSET_FILE"
    done < <(echo "$RESPONSE" | jq -c '.result[]')
  fi
done
