#!/usr/bin/env bash
# claude-respond.sh — message → Claude reply (Pro/Max plan, no API key).
#
# Usage: claude-respond.sh "<message>" [<conversation-key>]
#   <conversation-key>: optional, e.g. a telegram-chat-id. When the same key is
#   used again within 30 minutes, the previous conversation is resumed via
#   --resume. Otherwise a fresh conversation is started.
#
# Special commands:
#   /reset or /new — reset the conversation for this key, force fresh next time.
#
# Input format: either a plain string, OR "b64:<base64-encoded-string>" to
# avoid quoting pain when the caller can't escape reliably (e.g. n8n nodes).
#
# Output: Claude's reply on stdout.

set -uo pipefail

LOG="${SUNDAY_RESPOND_LOG:-/tmp/claude-respond.log}"
echo "----- [$(date -Iseconds)] called -----" >> "$LOG"
echo "argc=$# args=$1 ${2:-}" >> "$LOG"

if [[ $# -lt 1 ]]; then
  echo "ERROR: message argument missing" >&2
  echo "EXIT: missing arg" >> "$LOG"
  exit 1
fi

INPUT_RAW="$1"
if [[ "$INPUT_RAW" == b64:* ]]; then
  MESSAGE=$(echo "${INPUT_RAW#b64:}" | base64 -d)
else
  MESSAGE="$INPUT_RAW"
fi
echo "message: $MESSAGE" >> "$LOG"

CONV_KEY="${2:-default}"
VAULT_DIR="${VAULT_DIR:-$HOME/sunday}"
CLAUDE_BIN="${CLAUDE_BIN:-$HOME/.npm-global/bin/claude}"
AGENT_NAME="${SUNDAY_AGENT_NAME:-the user's personal-assistant agent}"

# /reset lets the caller wipe the conversation state for this key.
if [[ "$MESSAGE" == "/reset" || "$MESSAGE" == "/new" ]]; then
  rm -f "$HOME/.claude-sessions/$CONV_KEY.state"
  echo "Conversation reset. Fresh session next time."
  exit 0
fi

STATE_DIR="$HOME/.claude-sessions"
mkdir -p "$STATE_DIR"
STATE_FILE="$STATE_DIR/$CONV_KEY.state"
TIMEOUT_SEC="${SUNDAY_RESUME_TIMEOUT_SEC:-1800}"   # 30 minutes default

RESUME_ARGS=()
if [[ -f "$STATE_FILE" ]]; then
  STATE=$(cat "$STATE_FILE")
  PREV_SID="${STATE%%:*}"
  PREV_TS="${STATE##*:}"
  NOW=$(date +%s)
  AGE=$((NOW - PREV_TS))
  if (( AGE < TIMEOUT_SEC )) && [[ -n "$PREV_SID" ]]; then
    RESUME_ARGS=(--resume "$PREV_SID")
    echo "resuming session $PREV_SID (age ${AGE}s)" >> "$LOG"
  else
    echo "session expired (age ${AGE}s) — starting fresh" >> "$LOG"
  fi
else
  echo "no prior session — starting fresh" >> "$LOG"
fi

cd "$VAULT_DIR"
git pull --quiet 2>/dev/null || true

# Extract a chat-id-like value from the conversation key for the system prompt
# (useful when scheduling reminders that need to know which chat to reply to).
TG_CHAT_ID="${CONV_KEY#telegram-}"

SYSTEM_PROMPT="You are $AGENT_NAME on a Raspberry Pi, addressed via Telegram.
You work inside the user's vault — read ./CLAUDE.md FIRST before answering or editing anything.
You have broad permissions: vault edits, configured MCP tools (Calendar, Mail, etc.). Use them without asking.

Current Telegram chat id: $TG_CHAT_ID

Behaviour for Telegram mode:
- A QUESTION → short answer (max 4 sentences, fits a Telegram message), no vault edits.
- A NOTE / TODO / CALENDAR ITEM → triage per CLAUDE.md, commit + push, then a short confirmation of what you did.
- A REMINDER (\"remind me at X\", \"ping me tomorrow 9am\", etc.):
  Call $VAULT_DIR/scripts/schedule-reminder.sh '<at-syntax-time>' '$TG_CHAT_ID' '<message>'
  At-syntax examples: 'now + 30 minutes', '15:00', '15:00 tomorrow', '09:30 2026-05-12'.
  Default: Telegram reminder only. Only create a calendar event if the user explicitly asked for one.
- Ambiguous → ask one quick clarifying question instead of guessing.

Response format:
- Plain text, ≤ 500 characters.
- No markdown headers, no code blocks (unless explicitly requested).
- Match the user's language.

On vault edits:
- Use explicit paths for git add (NEVER git add -A).
- Meaningful commit message.
- Push at the end."

RAW=$("$CLAUDE_BIN" \
  --print \
  --output-format json \
  --permission-mode bypassPermissions \
  "${RESUME_ARGS[@]}" \
  --append-system-prompt "$SYSTEM_PROMPT" \
  "$MESSAGE" 2>>"$LOG")

RESPONSE=$(echo "$RAW" | jq -r '.result // empty')
NEW_SID=$(echo "$RAW" | jq -r '.session_id // empty')

if [[ -n "$NEW_SID" ]]; then
  echo "$NEW_SID:$(date +%s)" > "$STATE_FILE"
  echo "saved session $NEW_SID" >> "$LOG"
fi

echo "response length: ${#RESPONSE}" >> "$LOG"
echo "$RESPONSE"
