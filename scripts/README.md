# Scripts

Optional shell helpers for the Telegram + voice setup (`docs/setup/telegram-voice.md`). You don't need these if you're using Sunday as a plain Obsidian vault — they exist for the headless Pi deployment.

## What's here

| Script | Purpose |
|---|---|
| `claude-respond.sh` | Take a message, run it through `claude --print` with the Sunday-Telegram system prompt, return the answer. Keeps a 30-min sliding-window conversation per chat. |
| `telegram-poll.sh` | Long-poll the Telegram bot, route incoming messages to `claude-respond.sh`, send the reply back. Voice notes go through `voice-to-text.sh` first. |
| `voice-to-text.sh` | Download a Telegram voice file, convert via `ffmpeg`, transcribe via `whisper.cpp`. Prints the transcript on stdout. |
| `schedule-reminder.sh` | Schedule a Telegram push for a later time using `at(1)`. The agent calls this when the user says "remind me at X". |
| `fire-reminder.sh` | Internal — called by the `at` job at the reminder time, reads the payload and sends the Telegram message. Not called directly. |

## Configuration

Every script is **env-driven**. No user IDs or paths are baked into the code. Set these in your shell (or in the systemd unit that runs `telegram-poll.sh`):

| Env var | What it does | Default |
|---|---|---|
| `VAULT_DIR` | Where the Sunday vault lives on the Pi. | `~/sunday` |
| `CLAUDE_BIN` | Path to the `claude` binary. | `~/.npm-global/bin/claude` |
| `TELEGRAM_BOT_TOKEN_FILE` | File containing the bot token (chmod 600). | `~/.telegram-bot-token` |
| `TELEGRAM_ALLOWED_IDS_FILE` | File with one allowed Telegram user ID per line. | `~/.telegram-bot-allowed-ids` |
| `WHISPER_DIR` | Path to `whisper.cpp` checkout. | `~/whisper.cpp` |
| `WHISPER_MODEL` | Path to the GGML model file. | `~/whisper.cpp/models/ggml-small.bin` |
| `WHISPER_PROMPT` | Optional file with an initial Whisper prompt (e.g. to bias the transcription towards your domain vocabulary). | none |
| `WHISPER_LANG` | Whisper language code. | `en` |
| `WHISPER_THREADS` | Threads for whisper-cli. | `4` |
| `SUNDAY_AGENT_NAME` | How the system prompt refers to "you" the assistant. | `"the user's personal-assistant agent"` |

## First-time setup

```bash
# Bot token (chmod 600 — keep secret)
echo "<your-bot-token>" > ~/.telegram-bot-token
chmod 600 ~/.telegram-bot-token

# Allowlist — one Telegram user ID per line
echo "<your-telegram-user-id>" > ~/.telegram-bot-allowed-ids
chmod 600 ~/.telegram-bot-allowed-ids

# Smoke-test the response pipeline (does not touch Telegram):
./claude-respond.sh "Hello, who are you?"
```

## systemd unit (recommended)

```ini
# /etc/systemd/system/sunday-telegram.service
[Unit]
Description=Sunday Telegram poller
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=<your-username>
WorkingDirectory=/home/<your-username>/sunday
Environment=PATH=/home/<your-username>/.npm-global/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=/home/<your-username>/sunday/scripts/telegram-poll.sh
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable + start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now sunday-telegram.service
journalctl -u sunday-telegram.service -f
```
