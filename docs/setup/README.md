# Setup guides

Optional integrations for Sunday. None of these are required — Sunday works fine as a plain Obsidian vault you talk to via the Claude Code CLI.

## What's here

- **`raspberry-pi.md`** — turn a Pi 5 into a 24/7 Claude Code host, reachable from anywhere via Tailscale and the Anthropic mobile app. About 2–4 hours, mostly waiting on system updates.
- **`telegram-voice.md`** — text or voice messages to a Telegram bot, transcribed locally with `whisper.cpp`, answered by the assistant on the Pi. Builds on the Pi setup. About 1–2 hours.
- **`pi-handoff-prompt.md`** — a reusable prompt you can hand to another agent (or a friend with SSH access) to do the Pi setup for you.
- **`n8n-telegram-workflow.json`** — the importable n8n workflow used by `telegram-voice.md`. You don't need to read it — the guide tells you how to import it.

## Order

Pi → Telegram. The Telegram guide assumes you've finished the Pi guide.

## Why this stack?

The choices here are deliberately conservative:

- **Pi instead of a VPS.** A Pi 5 is one-time hardware (~€165) instead of a recurring cloud bill, runs Claude Code with your existing Pro/Max plan (no API tokens consumed), and your vault never leaves your home network.
- **Tailscale instead of port-forwarding.** Zero-config private mesh. No DDNS, no router rules, works through CGNAT.
- **Local Whisper instead of an API.** Audio stays on your Pi. Latency is acceptable on Pi 5 with the `small` model.
- **n8n instead of a hand-written bot.** Visual workflow editing, easy to extend (WhatsApp, email, etc. — same trigger → same handler).
- **Polling instead of webhooks.** Telegram polling works without a public HTTPS URL, which means you don't need to expose anything.

You can swap any of these — these guides are recipes, not laws.
