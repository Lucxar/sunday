#!/usr/bin/env bash
# voice-to-text.sh — Telegram voice file-path → transcription via whisper.cpp.
#
# Usage: voice-to-text.sh "<file_path from Telegram getFile>"
#   e.g.: voice-to-text.sh "voice/file_42.oga"
#
# Bot token comes from $TELEGRAM_BOT_TOKEN_FILE (chmod 600).
# Output: only the transcribed text (stdout).
# Used by: telegram-poll.sh and the n8n Telegram workflow (via SSH bridge).

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "ERROR: file_path missing" >&2
  echo "Usage: $0 'voice/file_xyz.oga'" >&2
  exit 1
fi

TOKEN_FILE="${TELEGRAM_BOT_TOKEN_FILE:-$HOME/.telegram-bot-token}"
if [[ ! -r "$TOKEN_FILE" ]]; then
  echo "ERROR: token file $TOKEN_FILE not readable" >&2
  exit 6
fi
TOKEN=$(cat "$TOKEN_FILE")

FILE_PATH="$1"
FILE_URL="https://api.telegram.org/file/bot${TOKEN}/${FILE_PATH}"
WHISPER_DIR="${WHISPER_DIR:-$HOME/whisper.cpp}"
MODEL="${WHISPER_MODEL:-$WHISPER_DIR/models/ggml-small.bin}"
PROMPT_FILE="${WHISPER_PROMPT:-}"
LANG="${WHISPER_LANG:-en}"
THREADS="${WHISPER_THREADS:-4}"

TMP_DIR=$(mktemp -d /tmp/voice-XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

OGA="$TMP_DIR/voice.oga"
WAV="$TMP_DIR/voice.wav"
OUT_BASE="$TMP_DIR/transcript"

curl -fsSL --max-time 30 -o "$OGA" "$FILE_URL" || {
  echo "ERROR: audio download failed" >&2
  exit 2
}

ffmpeg -loglevel error -y -i "$OGA" -ar 16000 -ac 1 "$WAV" || {
  echo "ERROR: ffmpeg conversion failed" >&2
  exit 3
}

PROMPT_ARG=()
if [[ -n "$PROMPT_FILE" && -f "$PROMPT_FILE" ]]; then
  PROMPT_ARG=(--prompt "$(cat "$PROMPT_FILE")")
fi

"$WHISPER_DIR/build/bin/whisper-cli" \
  --model "$MODEL" \
  --language "$LANG" \
  --threads "$THREADS" \
  --no-timestamps \
  --output-txt \
  --output-file "$OUT_BASE" \
  "${PROMPT_ARG[@]}" \
  "$WAV" >/dev/null 2>&1 || {
  echo "ERROR: whisper-cli failed" >&2
  exit 4
}

if [[ ! -f "$OUT_BASE.txt" ]]; then
  echo "ERROR: no transcript produced" >&2
  exit 5
fi

cat "$OUT_BASE.txt" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
