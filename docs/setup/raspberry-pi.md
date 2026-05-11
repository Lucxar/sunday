# Raspberry Pi Setup for Sunday

Step-by-step guide to turning a **Raspberry Pi 5** into a 24/7 server for Sunday. The result: a Pi running Claude Code on your Pro/Max plan, reachable from anywhere via the Anthropic mobile app, hosting your vault as a git repo.

**Setup time:** ~2–4 hours, mostly waiting on system updates.
**Prerequisite:** a machine you can SSH from (Windows: PowerShell or PuTTY; macOS / Linux: terminal), and your Sunday fork already lives in a git repo (e.g. GitHub).

> Anything in **`<placeholder>`** you replace with your own value. Grep for `<` once you're done to make sure you didn't miss one.

---

## 0. Hardware

| Part | Recommendation | Why | ca. price |
|---|---|---|---|
| Pi 5, 8 GB | official | Enough RAM for Claude + a Docker stack | €90 |
| SSD 256 GB + USB3 adapter | Kingston / SanDisk + official Pi USB-boot stick | Much more durable than SD under 24/7 load | €40 |
| Official Pi 5 PSU | 27 W USB-C PD | Pi 5 is fussy with cheap PSUs | €15 |
| Ethernet cable | Cat.6 1 m | Ethernet > WiFi for stability | €5 |
| Case with cooling | Pi 5 Active Cooler or Argon ONE | Pi 5 throttles without cooling | €15 |

**Total ~€165.** A microSD card as boot backup is optional (~€10).

---

## 1. Flash the OS image

1. Download **Raspberry Pi Imager**: <https://www.raspberrypi.com/software/>
2. Open Imager. Click: **Raspberry Pi 5** → **Raspberry Pi OS Lite (64-bit)** → **SSD / SD**.
3. Before writing: click the **gear icon** (OS customisation) and set:

| Field | Value |
|---|---|
| Hostname | `sunday-pi` (or your choice) |
| Username | `<your-username>` |
| Password | strong password, save it somewhere safe |
| WiFi | skip if you're using Ethernet (recommended) |
| Locale | your timezone, UTF-8 |
| **Enable SSH** | **yes**, public-key auth if you have one, otherwise password |

4. Click **Write** (10–15 min).
5. Plug SSD / SD into the Pi, connect PSU and Ethernet, power on.

---

## 2. First SSH connection

The Pi takes ~1 minute to boot the first time. Then, from your PC:

```powershell
ssh <your-username>@sunday-pi.local
# or by IP if mDNS doesn't resolve:
# ssh <your-username>@<pi-ip>
```

Find the Pi's IP in your router admin UI or via `ping sunday-pi.local`.

First connection: accept the fingerprint, type the password.

You're in when the prompt shows `<your-username>@sunday-pi:~ $`.

---

## 3. System update + basics

```bash
sudo apt update
# Fresh Pi: sudo apt upgrade -y
# Pi already hosting other services: apt upgrade can break other stacks.
# Skip the blanket upgrade and only install what you need:
sudo apt install -y curl git tmux htop nano build-essential
```

`htop` and `nano` are optional but convenient. `tmux` is required later for the persistent Claude session.

On **Pi OS Lite 64-bit** (Debian 13 / trixie at time of writing), the user created at install gets passwordless `sudo` (`/etc/sudoers.d/010_pi-nopasswd`). No extra setup needed.

---

## 4. Tailscale (remote access from anywhere)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

`tailscale up` prints a URL. Open it in your browser, log in with your Tailscale account, authorise the Pi.

Then:

```bash
tailscale ip -4
# prints the Pi's Tailscale IP, e.g. 100.64.123.45
```

From now on, every device on your Tailscale net reaches the Pi at this IP — anywhere on the planet, no port forwarding, no DDNS.

On your phone: install the **Tailscale app**, same account → done.

---

## 5. Node.js (for Claude Code)

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

node --version    # should be v20+
npm --version
```

So `npm install -g` works without `sudo` (best practice):

```bash
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

---

## 6. Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

Should show `2.x` or higher — if not: `npm update -g @anthropic-ai/claude-code`.

---

## 7. Headless Claude login

```bash
claude
```

On first start Claude prints a URL like `https://claude.ai/code/auth?...` and asks for an auth code.

1. Open the URL on a device with a browser (your PC or phone).
2. Log in with your Claude account (Pro / Max).
3. Copy the **auth code** shown.
4. Paste into the Pi terminal + Enter.

Verify:

```bash
# inside the claude REPL:
/status
# should show your account and Pro/Max plan
/exit
```

---

## 8. Git config + clone your Sunday vault

```bash
git config --global user.name "<Your Name>"
git config --global user.email "<your-email>"

# SSH key for GitHub (if you use SSH to GitHub):
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_sunday -N '' -C "sunday-pi-deploy"

cat ~/.ssh/id_ed25519_sunday.pub
# Copy the output → GitHub Repo Settings → Deploy keys → Add deploy key
# (NOT under your personal account-wide SSH keys, that would be too broad)
# Title: "Sunday Pi deploy"
# Key: paste → check "Allow write access" → Add

# ssh-config alias so only this key is used for the Sunday repo
# (important if the Pi already hosts other repos with their own deploy keys):
cat >> ~/.ssh/config <<'EOF'

Host github-sunday
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_sunday
  IdentitiesOnly yes
EOF

# Test:
ssh -T git@github-sunday
# should say "Hi <user>/<repo>! You've successfully authenticated"

# Clone (using the ssh-config alias as host):
cd ~
git clone git@github-sunday:<your-github-user>/<your-repo>.git sunday
cd sunday
ls -la
# should show CLAUDE.md, README.md, etc.
```

> **Why a deploy key + ssh-config alias instead of an account-wide key?**
> - **Repo isolation**: this key can only access this one repo. If the Pi is ever compromised, your GitHub account stays safe.
> - **Coexistence**: when the Pi already hosts other repos with their own deploy keys, an account-wide key wouldn't replace them — separate deploy keys + ssh-config aliases make the mapping explicit.
> - **Write access** is required for the assistant to commit + push from the Pi (the standard workflow).

---

## 9. tmux + persistent Claude session

`claude --remote-control` has to **stay running** so the mobile app can attach. `tmux` gives you a session that survives disconnects.

```bash
cd ~/sunday
tmux new -s claude-main
# you're now inside a tmux session

claude --remote-control
# Claude Code starts in remote-control mode
# this session is now addressable from the mobile app
```

Important tmux shortcuts:

| Action | Keys |
|---|---|
| **Detach** (session keeps running, you leave it) | `Ctrl+B` then `D` |
| **Reattach** | `tmux attach -t claude-main` |
| List sessions | `tmux ls` |
| Kill session | `tmux kill-session -t claude-main` |

Detach now (`Ctrl+B`, `D`). You can close the SSH connection — the tmux session and Claude both keep running.

---

## 10. Mobile app verification

1. On your phone: open the **Claude app** (same account as on the Pi).
2. In the menu: find **Coding** / **Claude Code**.
3. Open the **Active sessions** list.
4. You should see **`sunday-pi`** with session `claude-main`.
5. Tap it → message field → send a test: `say hello`.
6. SSH back in + `tmux attach -t claude-main` → you should see the message and Claude's reply.

If that works, the bridge is live.

---

## 11. Auto-start on boot (systemd)

So that after a Pi reboot the Claude session comes back automatically:

```bash
sudo nano /etc/systemd/system/claude-remote.service
```

Paste (replace user + paths):

```ini
[Unit]
Description=Claude Code Remote Control Session
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
User=<your-username>
WorkingDirectory=/home/<your-username>/sunday
Environment=PATH=/home/<your-username>/.npm-global/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=/usr/bin/tmux new-session -d -s claude-main '/home/<your-username>/.npm-global/bin/claude --remote-control'
ExecStop=/usr/bin/tmux kill-session -t claude-main
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Save (`Ctrl+O`, Enter, `Ctrl+X`), then:

```bash
sudo systemctl daemon-reload
sudo systemctl enable claude-remote.service
sudo systemctl start claude-remote.service
sudo systemctl status claude-remote.service
# should show "active (running)"
```

Test: `sudo reboot`. Wait ~1 minute, then check that the session shows up in the mobile app again.

---

## 12. Auto-sync with GitHub (optional, recommended)

So vault changes from your PC and the Pi stay in sync, a cron job for `git pull`:

```bash
crontab -e
```

If asked to pick an editor: `1` for nano. Add this line:

```
*/5 * * * * cd /home/<your-username>/sunday && git pull --quiet 2>&1 | logger -t vault-sync
```

That's a `git pull` every 5 minutes. Logs land in `/var/log/syslog` (`grep vault-sync /var/log/syslog`).

**Watch out — conflicts:** if the Pi has uncommitted changes, `git pull` fails. Convention: whatever Claude writes on the Pi gets **committed + pushed immediately**. `CLAUDE.md` codifies that implicitly already.

---

## 13. Cheat-sheet — daily operation

| What | Command |
|---|---|
| SSH to Pi | `ssh <user>@<tailscale-ip>` or `ssh <user>@sunday-pi.local` |
| List tmux sessions | `tmux ls` |
| Reattach to Claude session | `tmux attach -t claude-main` |
| Detach from tmux | `Ctrl+B` then `D` |
| Restart Claude session | `sudo systemctl restart claude-remote.service` |
| Service status | `sudo systemctl status claude-remote.service` |
| Pi logs (Claude) | `journalctl -u claude-remote.service -f` |
| Manual vault pull | `cd ~/sunday && git pull` |
| Reboot Pi | `sudo reboot` |
| Shut Pi down | `sudo shutdown now` |

---

## 14. Troubleshooting

**Mobile app doesn't show the Pi session:**
- Same Claude account on both? (`/status` inside Pi-Claude.)
- Is Claude actually running with `--remote-control`? (`tmux attach`, check.)
- Is the Pi online? (`tailscale ping <other-device>`.)
- Last resort: `sudo systemctl restart claude-remote.service`.

**Session times out after a network drop:**
- After ~10 minutes offline Anthropic terminates the remote session.
- systemd restarts it, but the context is lost.
- Mitigation: Ethernet (not WiFi), and a small UPS for longer outages.

**Auth code rejected:**
- Codes are single-use; old ones expire.
- `claude /login` produces a new one.

**`npm install -g` asks for sudo:**
- npm prefix not set up (step 5).
- `npm config get prefix` should show `/home/<user>/.npm-global`.

**`tailscale up` doesn't print a URL:**
- `sudo tailscale logout`, then `sudo tailscale up` again.
- If still stuck: use `--auth-key` with a pre-generated key from the Tailscale dashboard.

---

## 15. What comes next (Phase 2)

This guide covers only **Pi + Claude Code remote control**. Companion guides:

- **Telegram + voice pipeline** → `docs/setup/telegram-voice.md`
- **Calendar sync** → not yet written; see `docs/phase-2-conventions.md` for the framework
- **Weekly reviews** → not yet written; see `docs/phase-2-conventions.md`

See `CLAUDE.md → Phase 2` for the wider roadmap.

---

## 16. Security notes

- **Disable SSH password auth** once public-key auth works: `sudo nano /etc/ssh/sshd_config` → `PasswordAuthentication no` → `sudo systemctl restart ssh`.
- **Never expose the Pi directly to the open internet** — that's exactly what Tailscale is for.
- **`claude --remote-control` sessions are only accessible to your logged-in account** — no extra firewall rules needed.
- **The vault is plaintext on the Pi.** Anyone with physical access to the SSD has access to everything. Consider LUKS disk encryption if the Pi sits in a non-private location.
