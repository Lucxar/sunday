# Telegram + Voice Pipeline for Sunday

End-to-end setup: **Telegram message (text or voice) → n8n on the Pi → Whisper transcription → `claude --print` → Telegram reply.** Runs entirely on the Pi (apart from Telegram itself), uses your Pro/Max plan instead of API tokens, and audio stays local.

**Setup time:** ~1–2 hours including workflow testing.
**Prerequisite:** Pi setup (`docs/setup/raspberry-pi.md`) done through section 12, and `claude --print` works headlessly.

> Replace `<placeholder>` values with your own.

---

## Architecture

```
[Telegram bot] (polling mode)
      ↓
[n8n on Pi (Docker, 127.0.0.1:5678)]
   ├── Voice branch: download audio → ffmpeg → whisper.cpp → text
   └── Text branch: pass through
      ↓
[Execute command: claude --print --append-system-prompt "<telegram-mode>" "<msg>"]
      ↓ stdout
[Telegram send message: reply back]
```

**Polling instead of webhooks.** Telegram webhooks require a public HTTPS URL. Since n8n only listens on localhost / Tailscale, webhooks wouldn't reach it. Polling (n8n asks Telegram for updates every ~1–3 s) needs no public URL and is more than fast enough for personal use.

---

## 1. Create a Telegram bot

1. Open Telegram → search @BotFather → start chat → `/start`.
2. Send `/newbot`.
3. Pick a display name (e.g. `My Personal Assistant`).
4. Pick a username (must end in `bot`, e.g. `mysundaybot`).
5. **Copy the bot token** (format `1234567890:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`).

Optional, while at @BotFather:
- `/setdescription` — set a description.
- `/setcommands` — define slash commands (e.g. `triage — triage the inbox`, `query — ask the vault`).

---

## 2. Find your Telegram user ID (for the allow-list)

So only you can use the bot:

1. In Telegram, find @userinfobot → start → it replies with your numeric user ID.
2. Note the ID (format e.g. `123456789`).

---

## 3. n8n via Docker on the Pi

n8n runs as a Docker container, listening only on localhost, with basic auth and volumes mounted for vault and Whisper access.

```bash
mkdir -p ~/n8n && cd ~/n8n
```

**`docker-compose.yml`:**

```yaml
services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "127.0.0.1:5678:5678"   # local only, not public
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${N8N_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_PASS}
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - GENERIC_TIMEZONE=<your-tz, e.g. Europe/Berlin>
      - TZ=<your-tz>
      - N8N_RUNNERS_ENABLED=true
      - N8N_DIAGNOSTICS_ENABLED=false
    volumes:
      - n8n_data:/home/node/.n8n
      - /home/<user>/sunday:/vault            # vault access
      - /home/<user>/.npm-global:/claude-bin:ro
      - /home/<user>/.claude:/claude-config:ro
      - /home/<user>/whisper.cpp:/whisper:ro

volumes:
  n8n_data:
```

**`.env`** (chmod 600):

```
N8N_USER=<your-n8n-username>
N8N_PASS=<strong-generated-password>
```

Start:

```bash
docker compose up -d
docker ps --filter name=n8n
# should show "Up" on port 127.0.0.1:5678
```

---

## 3a. SSH bridge: n8n container → Pi host (for `claude` and `whisper`)

`claude` runs on the Pi host (your Pro/Max login lives there), not inside the n8n container. Calling it from inside the container directly fails (architecture mismatch + login state is host-only). Clean solution: **SSH bridge** — the container shells back into the host via an SSH alias.

```bash
# 1) Generate an ed25519 key inside the container:
docker exec -u node n8n sh -c \
  'mkdir -p /home/node/.ssh && chmod 700 /home/node/.ssh && \
   ssh-keygen -t ed25519 -f /home/node/.ssh/id_ed25519 -N "" -C "n8n-container@<host>"'

# 2) Append the container's public key to host authorized_keys:
CONTAINER_PUB=$(docker exec -u node n8n cat /home/node/.ssh/id_ed25519.pub)
grep -qF "$CONTAINER_PUB" ~/.ssh/authorized_keys || echo "$CONTAINER_PUB" >> ~/.ssh/authorized_keys

# 3) ssh-config inside the container — host alias `claude-host`:
docker exec -u node n8n sh -c 'cat > /home/node/.ssh/config <<EOF
Host claude-host
  HostName 172.20.0.1
  User <pi-user>
  IdentityFile /home/node/.ssh/id_ed25519
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF
chmod 600 /home/node/.ssh/config'

# 4) Test:
docker exec -u node n8n sh -c 'ssh claude-host hostname'
# → should print the Pi hostname

docker exec -u node n8n sh -c \
  'ssh claude-host /home/<pi-user>/.npm-global/bin/claude --print "Test"'
# → should print a Claude reply
```

**Gateway IP `172.20.0.1`**: default Docker bridge gateway for the `n8n_default` network. If yours differs: `docker exec n8n ip route | grep default | awk '{print $3}'` shows the right one.

`StrictHostKeyChecking no` + `UserKnownHostsFile /dev/null`: the bridge gateway IP is stable but persistent known-hosts inside the container volume is finicky. On a LAN no risk — nobody else can impersonate `172.20.0.1`.

Inside the workflow's Execute Command node later: `ssh claude-host /home/<pi-user>/.npm-global/bin/claude --print "{{ $json.message }}"`.

---

## 4. Reach the n8n UI from your PC (SSH tunnel)

n8n listens only on `127.0.0.1:5678` (for safety). Tunnel from your PC:

```powershell
# PowerShell or bash:
ssh -L 5678:localhost:5678 <user>@<pi-ip-or-tailscale-host>
```

While this SSH session is open, point your browser at `http://localhost:5678` → n8n login with the basic-auth credentials.

> Alternative: Tailscale Funnel for direct public access — overkill if the SSH tunnel is enough.

---

## 5. Install whisper.cpp (voice branch)

```bash
sudo apt install -y cmake ffmpeg

git clone https://github.com/ggerganov/whisper.cpp.git ~/whisper.cpp
cd ~/whisper.cpp
cmake -B build
cmake --build build --config Release -j4
# ~3–5 min on Pi 5

bash ./models/download-ggml-model.sh small
# ~466 MB download
```

**Model choice:**

| Model | Size | Speed on Pi 5 | Accuracy |
|---|---|---|---|
| `tiny` | 75 MB | very fast (0.3× RT) | mediocre |
| `base` | 142 MB | fast (0.5× RT) | OK |
| **`small`** | 466 MB | **acceptable (~1.3× RT)** | **good — default** |
| `medium` | 1.5 GB | slow (~3× RT) | very good |
| `large-v3-turbo` | 1.6 GB | slow but solid | best multilingual |

Quick test:

```bash
~/whisper.cpp/build/bin/whisper-cli \
  --model ~/whisper.cpp/models/ggml-small.bin \
  --language <your-lang> \
  --threads 4 \
  ~/whisper.cpp/samples/jfk.wav
```

---

## 6. Import the n8n workflow

Sunday ships a ready-to-import workflow: `docs/setup/n8n-telegram-workflow.json`.

In the n8n UI: Workflows → New → "…" (three dots) → Import from File → pick the JSON → Import.

**Before activating, configure:**

1. **Telegram Trigger node** → Credentials → New → Telegram API → paste the bot token.
2. **IF "Whitelisted User" node** → set the `rightValue` to your Telegram user ID from step 2.
3. **SSH nodes** → Credentials → New → SSH (password or private-key) → point at the Pi host (`claude-host` alias).
4. **Set System Prompt node** (or the equivalent — see `scripts/claude-respond.sh`) → adjust the prompt template at the end of this guide if you want.

Activate the workflow (toggle in the top right).

---

## 7. Smoke test

1. Open Telegram → find your bot by username.
2. Send `/start` → the bot should respond (or n8n's default reply).
3. Text: "What's on my to-do list today?" → the assistant should answer from the vault.
4. Voice note: record 5 s "test, can you hear me?" → Whisper transcribes → assistant replies.

Latency expectation:
- Text → reply: 5–15 s.
- Voice (10 s audio) → reply: 15–30 s.

---

## 8. System-prompt template for Telegram mode

This goes into the `--append-system-prompt` argument (or into your `scripts/claude-respond.sh` if you use the script):

```
You are the user's personal-assistant agent on a Raspberry Pi, being addressed via Telegram.
You work in their vault — see ./CLAUDE.md for schema and workflows (read it before you answer or edit anything).
You have full permissions: vault edits, Calendar MCP, Mail MCP, every configured MCP tool. Use them without asking.

Current Telegram chat ID: {{ chat-id }}

Behaviour for Telegram mode:
- A QUESTION → short answer (max 4 sentences, fits a Telegram message), no vault edits.
- A NOTE / TODO / CALENDAR ITEM → triage per CLAUDE.md, commit + push, then a short confirmation of what you did.
- A REMINDER ("remind me at X", "ping me tomorrow at 9"):
  use the schedule-reminder.sh helper (see scripts/) with at-syntax time.
  Default: Telegram reminder only. Calendar event only if explicitly requested.
- Ambiguous → ask one quick clarifying question instead of guessing.

Response format:
- Plain text, ≤ 500 characters.
- No markdown headers, no code blocks (unless explicitly requested).
- Match the user's language.

On vault edits:
- explicit paths for git add (NEVER git add -A)
- meaningful commit message
- push at the end
```

---

## 9. Auto-start n8n on boot (optional)

Docker `restart: unless-stopped` is usually enough — the container starts with the Docker daemon. If you want an explicit systemd wrapper (for instance to control ordering with other services):

```ini
# /etc/systemd/system/n8n.service
[Unit]
Description=n8n for Sunday
Requires=docker.service
After=docker.service network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/<user>/n8n
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down

[Install]
WantedBy=multi-user.target
```

---

## 10. Cheat-sheet — daily operation

| What | Command |
|---|---|
| n8n status | `docker ps --filter name=n8n` |
| n8n logs | `docker logs -f n8n` |
| n8n restart | `cd ~/n8n && docker compose restart` |
| n8n update | `cd ~/n8n && docker compose pull && docker compose up -d` |
| Whisper test (local) | `~/whisper.cpp/build/bin/whisper-cli -m ~/whisper.cpp/models/ggml-small.bin -l <lang> -t 4 <audio.wav>` |
| Tunnel from PC | `ssh -L 5678:localhost:5678 <user>@<pi>` |

---

## 11. Troubleshooting

**Telegram trigger doesn't fire:**
- Bot token correct? Check the n8n credentials.
- Polling active? The trigger node must be enabled and the workflow must be activated.
- Bot blocked you? Telegram → bot profile → restart.

**Voice branch: ffmpeg error:**
- `ffmpeg -version` ≥ 4.x.
- Telegram sends audio as `.oga` (OGG / Opus); `whisper-cli` typically wants `.wav`. The workflow converts via `ffmpeg -i input.oga -ar 16000 -ac 1 output.wav`.

**Claude output empty / "not authenticated":**
- Is `~/.claude` correctly mounted into n8n? `docker exec -it n8n ls /claude-config`.
- Auth may have expired → `ssh <user>@<pi>` and run `claude /login` again.

**Whisper very slow:**
- Try `tiny` or `base` (see the speed/model table above).
- Bump threads (`--threads 6`) if the Pi 5 has headroom.
- Fallback: OpenAI Whisper API (~$0.006/min, faster, but leaves the Pi).

**Webhook variant (if you switch from polling):**
- Telegram needs public HTTPS. Options: Tailscale Funnel (`tailscale funnel 5678 on`), ngrok, Cloudflare Tunnel.
- Set `WEBHOOK_URL` in `docker-compose.yml`, restart the container.

---

## 12. What comes next

- **Memory-aware conversations**: right now every Telegram message is a fresh Claude conversation (context comes from the vault, not chat history). For follow-up questions, use `--resume <session-id>` keyed by Telegram chat ID. `scripts/claude-respond.sh` already implements a 30-minute sliding window — extend if you want longer continuity.
- **WhatsApp in parallel**: WhatsApp Cloud API as a second trigger, same rest of the workflow. A little more onboarding because of Meta.
- **OpenAI Whisper fallback**: a second whisper branch that switches to the API on timeout / error.
- **Email inbound**: IMAP polling or Mailgun webhook as a third trigger.

---

## 13. Security notes

- **The bot token is the key to your bot.** If it leaks, anyone can impersonate the bot. Keep it in the n8n credentials store, **never** commit it to git, `chmod 600` any file containing it on disk.
- **The allowed-user-ID filter is mandatory.** Without it, anyone who finds the bot username can query your vault.
- **n8n must listen on `127.0.0.1` only.** Web UI via SSH tunnel or Tailscale.
- **Mount `~/.claude` read-only** (`:ro`) — n8n shouldn't be able to mutate the Claude login state.
- **Vault mount is RW on purpose** — the assistant has to write + commit. But: enforce explicit-path `git add` in the system prompt; never `git add -A`.
