# Pi-setup handoff prompt

This prompt is meant for **someone with SSH access to your Pi** (another person, or another Claude session) to do the Pi setup from `docs/setup/raspberry-pi.md` for you. Copy the block below, fill in the placeholders, and paste it into the executing agent / human.

> The placeholders inside angle brackets are everything specific to your setup — fill them in before handing the prompt over.

---

```
# Sunday Pi setup — task

I need someone to set up my Raspberry Pi 5 as a 24/7 server for my Sunday vault. You'll work via SSH from my PC, follow the setup playbook in the repo, and ping me whenever a browser step on my side is required.

## Background

I'm running an LLM-maintained second brain — an Obsidian markdown vault that a Claude Code agent maintains and queries. The vault lives in this git repo:

  <your-git-repo-url>     # e.g. git@github.com:you/sunday-vault.git

The repo has:
- CLAUDE.md — the complete schema and instructions for any Claude Code session in here
- six workflows: capture → triage → ingest → query → lint → refactor
- templates, examples, and personal data

End goal: Claude Code runs 24/7 on the Pi inside a `claude --remote-control` session in tmux. From anywhere I can use the Anthropic mobile app to send commands to the Pi. **Critical:** everything runs on my Pro/Max plan, NEVER the paid API. Not a single token should be billed through the API.

## Current state

- Vault: live on GitHub at <your-git-repo-url>
- Pi 5 8 GB: powered on, on Ethernet, Pi OS Lite 64-bit installed
- Tailscale: <set-up | not-yet-set-up>
- Pi reachable via:
  - <tailscale-hostname-or-fqdn>
  - <mdns-hostname, e.g. sunday-pi.local>
  - <lan-ip>

## What you do

Follow the playbook in `docs/setup/raspberry-pi.md` in the repo. It has 16 numbered sections covering everything. Adjust which sections to run based on the "current state" above. Concretely, in order:

1. Establish SSH to the Pi (see "What I need to give you" below).
2. System update (section 3).
3. Tailscale (section 4) — only if not already set up.
4. Node.js + Claude Code (sections 5–6).
5. Headless Claude login — you'll need me briefly (section 7).
6. Git config + SSH key — you'll need me for GitHub settings (section 8).
7. Clone the vault to ~/sunday.
8. tmux + persistent Claude session (section 9).
9. Mobile-app verification (section 10) — I test from my phone.
10. systemd auto-start (section 11).
11. Cron auto-sync (section 12).

After each significant block: commit + push to the vault repo with a meaningful message; add an entry to log.md per the conventions in CLAUDE.md.

## Constraints (important)

- **Plan, not API.** Claude Code must run via my claude.ai login, never with an API key.
- **Language.** Vault content / frontmatter / log entries in the language already used in the repo (read CLAUDE.md). Commit messages and tech terms can be English.
- **Never `git add -A`.** It has pulled in unwanted files (.claude, Obsidian cache) in the past. Always stage explicit paths.
- **The schema in CLAUDE.md is the law.** All actions follow the workflows documented there. On a refactor → log.md entry + docs/tool-evolution.md entry.
- **Ask when ambiguous.** A short clarifying question beats a wrong guess.

## Success criteria

1. `claude --remote-control` runs persistently in the tmux session `claude-main` on the Pi.
2. My mobile app shows the session, I can send commands from outside the LAN.
3. systemd restarts the session automatically after a reboot.
4. The vault is cloned to ~/sunday and the Pi can pull / push from GitHub.
5. cron pulls every 5 minutes cleanly.
6. An entry in log.md (`refactor`) and `docs/tool-evolution.md` (`decision`) documents what you did.
7. `docs/setup/raspberry-pi.md` updated with any corrections you discover (so the next setup is smoother).

## What I'll provide on demand

- **Pi username**: ask me.
- **SSH access**: either a one-time password (you then ssh-copy-id) OR my public key for ~/.ssh/authorized_keys on the Pi.
- **Three browser actions**: approve the Claude login URL, paste the SSH key into GitHub Settings, occasionally a sudo password.

Reply "ready, missing username/auth" when you're about to start, and I'll fill in the gaps.
```
