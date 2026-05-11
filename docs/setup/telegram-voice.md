# Telegram + Voice Pipeline for Sunday (bash + systemd)

End-to-end setup: **Telegram message (text or voice) → `telegram-poll.sh` on the Pi → Whisper transcription → `claude --print` → Telegram reply.** Pure shell — no n8n, no Docker, no webhook, no public endpoint. Runs on your Pro/Max plan, audio stays local.

**Setup time:** ~45–90 minutes including the whisper.cpp build.
**Prerequisite:** Pi setup (`docs/setup/raspberry-pi.md`) through section 12, and `claude --print` works headlessly on the Pi.

> Replace `<placeholder>` values with your own. The script defaults assume `~/sunday` as the vault path — adjust `VAULT_DIR` if yours is elsewhere.

---

## Architecture

```
[Telegram bot] (long-poll, no webhook)
        ↓
telegram-poll.sh   (systemd service)
   │
   ├── voice? → voice-to-text.sh
   │             ├── download .oga
   │             ├── ffmpeg → .wav (16 kHz, mono)
   │             └── whisper-cli → text
   │
   └── text or transcript
        ↓
   claude-respond.sh
        │
        └── claude --print --resume <session-id>     (Pro/Max plan)
              ↓
        reply text → Telegram sendMessage
```

**Why polling, not webhooks?** Webhooks need a public HTTPS endpoint. Polling doesn't — Telegram's `getUpdates` is a long-poll over plain HTTPS, works on a Pi behind NAT, no Tailscale Funnel, no ngrok, no Cloudflare Tunnel. For personal use the latency (~1 s) is irrelevant.

**Why bash, not n8n / Node?** Five short scripts you can read end-to-end in 10 minutes. No Docker, no web UI, no auth layer, no version churn. systemd babysits the loop. If something breaks you read the log.

---

## 1. Create a Telegram bot

1. Open Telegram → search @BotFather → start chat → `/start`.
2. Send `/newbot`.
3. Pick a display name (e.g. `My Sunday Assistant`).
4. Pick a username (must end in `bot`, e.g. `mysundaybot`).
5. **Copy the bot token** (format `1234567890:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`). Treat this like a password.

Optional via @BotFather:
- `/setdescription` — set a description.
- `/setcommands` — define slash commands (e.g. `triage — triage the inbox`, `query — ask the vault`).

---

## 2. Find your Telegram user ID (allow-list)

So only you can use the bot:

1. In Telegram, find @userinfobot → start → it replies with your numeric user ID.
2. Note the ID (format e.g. `123456789`).

If you want to add more people later, that's just another line in the allow-list file (see step 4).

---

## 3. Install whisper.cpp (for voice notes)

```bash
sudo apt install -y cmake ffmpeg jq at

git clone https://github.com/ggerganov/whisper.cpp.git ~/whisper.cpp
cd ~/whisper.cpp
cmake -B build
cmake --build build --config Release -j4
# ~3–5 min on Pi 5

bash ./models/download-ggml-model.sh small
# ~466 MB download
```

(`jq` is used by the scripts to parse Telegram's JSON. `at` is used for scheduled reminders. Both are tiny.)

**Model choice:**

| Model | Size | Speed on Pi 5 | Accuracy |
|---|---|---|---|
| `tiny` | 75 MB | very fast (0.3× RT) | mediocre |
| `base` | 142 MB | fast (0.5× RT) | OK |
| **`small`** | 466 MB | **~1.3× RT** | **good — default** |
| `medium` | 1.5 GB | ~3× RT | very good |
| `large-v3-turbo` | 1.6 GB | slow but solid | best multilingual |

Quick test:

```bash
~/whisper.cpp/build/bin/whisper-cli \
  --model ~/whisper.cpp/models/ggml-small.bin \
  --language <your-lang> \
  --threads 4 \
  ~/whisper.cpp/samples/jfk.wav
```

You should see a transcription on stdout.

---

## 4. Drop the bot token + allow-list on disk

```bash
# Bot token (chmod 600 so only you can read)
echo "<your-bot-token>" > ~/.telegram-bot-token
chmod 600 ~/.telegram-bot-token

# Allow-list — one Telegram numeric user ID per line
echo "<your-telegram-user-id>" > ~/.telegram-bot-allowed-ids
chmod 600 ~/.telegram-bot-allowed-ids
```

If you ever want to grant access to someone else, append their ID on a new line in the same file. No restart needed — the script reads the file every message.

---

## 5. Configure the scripts via env vars (optional)

The five scripts in `scripts/` are env-driven. Defaults are sensible — only override if your paths differ:

| Env var | Default |
|---|---|
| `VAULT_DIR` | `~/sunday` |
| `CLAUDE_BIN` | `~/.npm-global/bin/claude` |
| `TELEGRAM_BOT_TOKEN_FILE` | `~/.telegram-bot-token` |
| `TELEGRAM_ALLOWED_IDS_FILE` | `~/.telegram-bot-allowed-ids` |
| `WHISPER_DIR` | `~/whisper.cpp` |
| `WHISPER_MODEL` | `~/whisper.cpp/models/ggml-small.bin` |
| `WHISPER_LANG` | `en` |
| `WHISPER_THREADS` | `4` |
| `SUNDAY_AGENT_NAME` | `the user's personal-assistant agent` |
| `SUNDAY_RESUME_TIMEOUT_SEC` | `1800` (30-min conversation continuity per chat) |

Full reference: `scripts/README.md`.

---

## 6. Smoke-test before wiring up systemd

```bash
cd ~/sunday

# Test claude-respond.sh without any Telegram dependency:
./scripts/claude-respond.sh "Hello, who are you and what vault do you maintain?"
# Should print a short answer that references CLAUDE.md.

# Test voice-to-text.sh by sending yourself a voice note,
# grab the file_path from Telegram's getFile response:
./scripts/voice-to-text.sh "voice/file_42.oga"
# Should print the transcript.
```

If both work, the pipeline is healthy — proceed to systemd.

---

## 7. Run `telegram-poll.sh` as a systemd service

```bash
sudo nano /etc/systemd/system/sunday-telegram.service
```

Paste (replace `<your-username>`):

```ini
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

If your defaults differ (vault path, whisper path, language), add `Environment=KEY=VALUE` lines before `ExecStart`. Example:

```ini
Environment=WHISPER_LANG=de
Environment=VAULT_DIR=/home/<your-username>/my-vault
```

Enable + start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now sunday-telegram.service
sudo systemctl status sunday-telegram.service
# should show "active (running)"

# Live logs:
journalctl -u sunday-telegram.service -f
```

You should see a `telegram-poll started` line in the journal.

---

## 8. End-to-end test

1. Open Telegram → find your bot by username.
2. Send `/start` or any text → the bot should reply within 5–15 s.
3. Send a voice note (5 s, "test, can you hear me?") → expect a reply within 15–30 s.
4. Send a note: "remember to buy milk" → the assistant should triage it into `inbox/` (or directly into `tasks/`, depending on how you've worded it), commit + push, and confirm.
5. Send a reminder: "remind me in 2 minutes to stretch" → assistant calls `schedule-reminder.sh` → 2 minutes later, the Pi pushes a Telegram reminder.

---

## 9. The system prompt the assistant gets

`claude-respond.sh` injects a Telegram-specific system prompt on every call. The template:

```
You are <SUNDAY_AGENT_NAME> on a Raspberry Pi, addressed via Telegram.
You work inside the user's vault — read ./CLAUDE.md FIRST before answering or editing anything.
You have broad permissions: vault edits, configured MCP tools. Use them without asking.

Current Telegram chat id: <chat-id>

Behaviour for Telegram mode:
- A QUESTION → short answer (max 4 sentences, fits a Telegram message), no vault edits.
- A NOTE / TODO / CALENDAR ITEM → triage per CLAUDE.md, commit + push, then a short confirmation.
- A REMINDER ("remind me at X") → call schedule-reminder.sh with at-syntax time.
- Ambiguous → ask one quick clarifying question instead of guessing.

Response format:
- Plain text, ≤ 500 characters.
- No markdown headers, no code blocks (unless explicitly requested).
- Match the user's language.

On vault edits:
- explicit-path git add (NEVER git add -A).
- meaningful commit message.
- push at the end.
```

Tune it inside `scripts/claude-respond.sh` to your taste — keep the bits about Telegram-message length and explicit git staging, those exist for good reason.

---

## 10. Cheat-sheet — daily operation

| What | Command |
|---|---|
| Service status | `sudo systemctl status sunday-telegram.service` |
| Live logs | `journalctl -u sunday-telegram.service -f` |
| Restart | `sudo systemctl restart sunday-telegram.service` |
| Stop temporarily | `sudo systemctl stop sunday-telegram.service` |
| Reset conversation for a chat | send `/reset` or `/new` to the bot |
| Test Whisper standalone | `~/whisper.cpp/build/bin/whisper-cli -m ~/whisper.cpp/models/ggml-small.bin -l <lang> -t 4 <audio.wav>` |
| Tail the response log | `tail -f /tmp/claude-respond.log` |
| Tail the poll log | `tail -f /tmp/telegram-poll.log` |
| Add a user to the allow-list | `echo <new-id> >> ~/.telegram-bot-allowed-ids` |

---

## 11. Troubleshooting

**Bot doesn't respond at all:**
- `journalctl -u sunday-telegram.service -n 50` — what's the last line?
- Bot token correct? `cat ~/.telegram-bot-token` (don't paste publicly).
- Service active? `systemctl is-active sunday-telegram.service` → `active`.
- Allow-list correct? `cat ~/.telegram-bot-allowed-ids` — your numeric ID on a line of its own.

**Bot says "unauthorized" in logs:**
- The `from.id` of your messages doesn't match anything in `~/.telegram-bot-allowed-ids`. Cross-check with @userinfobot.

**Voice transcription empty or gibberish:**
- Wrong language? Set `WHISPER_LANG` to the language you actually speak.
- Model too small? Try `base` or `small` (you may currently be on `tiny`).
- Audio download failed? `tail -f /tmp/telegram-poll.log` — look for `getFile returned no file_path` (rare, usually a Telegram-side hiccup).

**Reply is empty / "not authenticated":**
- The Claude session expired on the Pi. SSH in, run `claude /login` once, restart the service.

**Whisper very slow:**
- Switch to `tiny` or `base`. Edit the systemd `Environment=WHISPER_MODEL=...` line, then `sudo systemctl daemon-reload && sudo systemctl restart sunday-telegram.service`.
- Bump threads: `Environment=WHISPER_THREADS=6` on a Pi 5 with headroom.

**Reminders don't fire:**
- Is `at` installed and running? `sudo systemctl status atd` → `active`. If not: `sudo systemctl enable --now atd`.
- Check `atq` to list pending jobs.
- Tail `/tmp/reminder.log` for when a job ran.

**Bot replies in the wrong language:**
- The assistant matches the user's language. Send a German message — it replies in German. Send English — it replies in English. If it's stuck on one language, the conversation may still be resumed from a prior chat. Send `/reset`.

**Pi pulled an old vault state and overwrote local edits:**
- The auto-sync cron from the Pi guide runs every 5 minutes. If the assistant just wrote a file and `git pull` runs before its push, conflicts happen. Mitigation already in `claude-respond.sh`: each call does a `git pull --quiet` first. If you're editing the vault from multiple places at once, slow down — the assistant isn't designed for concurrent multi-writer use.

---

## 12. What you can do next

- **Wider conversations**: extend `SUNDAY_RESUME_TIMEOUT_SEC` if you want longer continuity per chat. Default is 30 min.
- **Multi-user**: add more IDs to `~/.telegram-bot-allowed-ids`. Each chat gets its own session state.
- **WhatsApp**: drop in a parallel `whatsapp-poll.sh` that talks to the WhatsApp Cloud API and calls the same `claude-respond.sh`. Bot logic stays one place.
- **Email inbound**: an IMAP-polling loop in the same shape — fetch → strip → `claude-respond.sh` → reply.
- **Memory-aware reminders**: have the reminder include vault context (e.g. "check task X" with a wikilink) instead of plain text.

---

## 13. Security notes

- **The bot token is the key to your bot.** If it leaks, anyone can impersonate the bot. Keep it in `~/.telegram-bot-token` only, `chmod 600`, **never** commit, **never** include in a screenshot.
- **The allow-list is your only auth layer.** Without it, anyone who finds your bot username can query your vault. Treat the list like a guest list to your house.
- **The Pi has full write access to your vault.** Anyone with SSH on the Pi can do whatever the assistant can. Standard Pi hygiene applies: no password SSH (key-only), no port-forwarding (Tailscale only), keep system updates current.
- **`claude --remote-control` and the Telegram bot share the same Claude account.** Both can run in parallel; both touch the same `~/.claude` login state. If you `claude /login` while the bot is running, the next bot call may briefly fail mid-token-swap. Restart the service after relogin.

---

## Appendix: if you ever want a visual workflow editor

The bash path above is the recommended setup for Sunday. If you specifically want a graphical workflow editor (n8n, Node-RED, Activepieces, Pipedream), you can put one in front of `claude-respond.sh` — the script is just a plain CLI that takes a message and a conversation key. Any tool that can `ssh user@pi /home/user/sunday/scripts/claude-respond.sh "<msg>" "<key>"` will work. But you don't need it.
