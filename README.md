# Sunday - Your Personal AI Assistant who never forgets

You have a thousand thoughts a day. Ideas for a side-business while you're walking the dog. A name a friend mentioned that you wanted to look up. Three errands. A book recommendation. A vague worry. A todo for tomorrow that you'll forget by tonight.

Notes apps lose them. Chatbots reset every session. Your brain holds maybe seven.

**Sunday is different.** It's a personal second brain that an AI agent maintains for you — todos, ideas, projects, people, what you read, what you watched, what you decided three months ago and why. You don't file anything yourself. You dump thoughts in; Sunday sorts them. You ask later; Sunday answers, with receipts.

It works for your job, your business, your studies, your hobbies, your shopping list. Same vault. Same assistant. The longer you use it, the more useful it gets — because nothing is ever rediscovered from scratch.

---

## Runs on your AI subscription — zero API tokens

Sunday is built on top of **Claude Code** and uses **your existing AI subscription** (Claude Pro, Max, Team — or any other LLM you wire up: GPT, Gemini, local Llama, OpenRouter, all fair game). **No API tokens. No per-call billing. No surprise invoices.** You pay the flat €20–€100/month plan you probably already have, and Sunday uses it as much as you want.

That changes the maths. With token-billed APIs a serious second brain — daily ingests, voice messages, recurring lints, long synthesis chats — racks up real money fast. With a subscription, the marginal cost of one more thought, one more transcript, one more late-night question is **zero**. Use it like a person, not like a meter.

---

## The killer feature: chat with Sunday from anywhere via Telegram

Sunday's most addictive form is a **private Telegram bot** wired to a **Raspberry Pi** (or any always-on machine — an old laptop, a mini-PC, a home server). Once it's running:

1. **You text or voice-message** your private Telegram bot — from the bus, the kitchen, a walk, the shower.
2. **The Pi receives it**, transcribes the voice locally with `whisper.cpp` (no audio ever leaves your house), and hands the message to Claude Code inside your vault.
3. **Claude triages it**, files it into the right folder, cross-links the right people / projects / topics, updates the wiki — and **replies in the same Telegram chat** to confirm or ask a follow-up.
4. **It can take real action.** With your Google Calendar connected, it schedules events directly (*"Remind me Friday 3pm to call Heinrich about the audit."*). With Gmail connected, it drafts and sends mails on your behalf (*"Reply to mum's last mail — yes, I'll be there Sunday."*). With GitHub or Drive connected, the surface widens further.

You stop sitting at a keyboard to "use" your assistant. It becomes a chat partner that *does things* — files notes, sets reminders, sends messages, looks up what you said three months ago — all backed by a markdown vault that grows with you and that you own end-to-end.

> **Cost:** ~€165 one-time for a Raspberry Pi 5. **Recurring:** €0 — it just talks to your existing Claude subscription. No cloud middleware, no n8n, no Docker, no public endpoint.

**Setup, in order:**
- 📡 [`docs/setup/raspberry-pi.md`](docs/setup/raspberry-pi.md) — turn a Pi 5 into a 24/7 Claude Code host, reachable from anywhere via Tailscale.
- 💬 [`docs/setup/telegram-voice.md`](docs/setup/telegram-voice.md) — wire a Telegram bot to the Pi with bash + systemd. Text + voice both work.
- 🤖 [`docs/setup/pi-handoff-prompt.md`](docs/setup/pi-handoff-prompt.md) — a reusable prompt you can hand to another agent (or a friend with SSH) to do the whole Pi setup *for* you. Comes back done.

Don't have a Pi? Sunday also works as a plain Obsidian vault you talk to via `claude` in your terminal — see the [Quick start](#quick-start-5-minutes) below.

---

## What you can do with Sunday on day one

- **Dump a thought, any thought** — text, voice, a link, a half-sentence — and forget about it.
  > *"Heinrich from Brand Studio wants a quote for an accessibility audit, follow up."*

  Sunday files it as a high-priority task, creates a contact card for Heinrich, links the two, and reminds you when it ages.

- **Ask anything you've ever told it.**
  > *"What did I want to do about my workshop slides again?"*

  Sunday reads the relevant pages and answers with links you can click through to the source.

- **Send a voice note from the bus.**
  Sunday transcribes it on your own Pi (no cloud), files it, replies. By the time you're home, the todo is already in your inbox and on your calendar.

- **Track everything you watch and read.**
  Drop in a YouTube link or an article URL. Sunday downloads the transcript, writes a one-page summary, integrates the new findings into your existing topic pages, flags contradictions to what you read last month.

- **Schedule directly into your calendar.**
  > *"Block 90 minutes Friday afternoon for the workshop prep, and book the dentist sometime in the next two weeks."*

  With Google Calendar connected, Sunday creates the event, picks a free slot, and confirms.

- **Have Sunday write the email for you.**
  > *"Reply to Heinrich saying the audit quote is coming Tuesday, polite but short."*

  With Gmail connected, Sunday drafts in your voice, you approve, it sends.

- **Don't worry about structure.** Sunday has six well-defined workflows (capture, triage, ingest, query, lint, refactor) baked into a schema the AI follows on every action. You don't think about taxonomy; the assistant does.

---

## The pitch in 30 seconds

Most AI tools forget. RAG retrieves the same chunks every time. ChatGPT loses context the moment you close the tab. Notes apps require *you* to file, link, and tidy — and you don't, so the notes app rots.

Sunday flips it. Your notes are **markdown files in a folder**. An LLM agent **builds and maintains them** — files them by type, cross-links to related pages, updates topic summaries when a new source contradicts an old one, drops a daily log, never gets bored, never forgets. The wiki is the artefact, not the chat.

You bring curiosity and raw material. The assistant does the bookkeeping. Over months, the wiki **compounds**. Year-two-you has access to year-one-you, fully indexed, fully synthesised, fully yours.

The pattern is by Andrej Karpathy ([original gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f), April 2026). Sunday is one opinionated instantiation, ready to fork.

---

## What's in the box

| Folder | What lives there |
|---|---|
| `inbox/` | Quick-capture. Dump anything. The assistant sorts it on `triage`. |
| `ideas/` | Ideas of any kind. Business, personal, half-baked. |
| `projects/` | Active undertakings. Have a `next-step` field so the assistant can tell you what to do. |
| `tasks/` | Todos with metadata — due date, priority, project link, area. |
| `topics/` | Knowledge nodes. Where everything you've read compounds. |
| `people/` | Clients, friends, family, mentors, creators you follow. |
| `journal/` | Daily entries. Optional. |
| `sources/` | One page per video / article / podcast / book you've ingested. Summary + crosslinks. |
| `raw/` | Immutable originals — transcripts, full-text articles. The receipts. |
| `docs/` | The meta layer — schema, templates, cookbook, optional setup guides. |
| `scripts/` | Optional shell helpers for the Pi + Telegram setup. |

The schema, conventions, and workflows live in [`CLAUDE.md`](CLAUDE.md). Read it once — it's the contract between you and the assistant.

---

## Quick start (5 minutes)

```bash
# 1. Fork or clone Sunday into your vault folder
git clone https://github.com/Lucxar/sunday.git my-vault
cd my-vault

# 2. Open as an Obsidian vault
#    Obsidian → "Open folder as vault" → pick my-vault/

# 3. Enable the Dataview plugin
#    Settings → Community plugins → Browse → "Dataview" → Install + Enable

# 4. Talk to Claude Code in the repo
claude
> Hi. Read CLAUDE.md and tell me how you understand your role.
```

That's it. Drop a note into `inbox/`, say "triage", watch it land in the right place.

Want concrete examples of what good runs look like? [`docs/examples/`](docs/examples/) has four cookbook walkthroughs — your first triage, ingesting a video, asking the vault, running a lint pass.

---

## Make it yours

Sunday's defaults are opinionated examples. You are expected to adapt them.

- **Areas** — the top-level groupings (`work | personal | learning | …`). Replace with whatever fits your life. Homeschool, band, PhD thesis, MTG collection. The schema is open.
- **Language** — schema words (`typ: idea`, `status: open`) stay in English so Dataview queries stay stable. The **body** of any page can be in any language. Tell Claude in your first session what language you want; it writes that way.
- **Workflows** — if "triage" should always commit + push, or "ingest" should always ping you for confirmation, write that down in `CLAUDE.md`. The assistant follows what's there.
- **Personal preferences** — your own colour codes, naming conventions, area extensions go in `docs/personal-preferences.md`. This file is gitignored in the public template so your prefs never leak. When you fork Sunday, remove that line from `.gitignore` so your prefs get tracked in *your* fork.

---

## Power-ups (optional)

The full **Pi + Telegram + Whisper** stack is the killer setup — see [the section above](#the-killer-feature-chat-with-sunday-from-anywhere-via-telegram) for the pitch and the three setup docs.

Other integrations worth turning on once your vault is alive:

- **Google Calendar** (via the official MCP server) — Sunday creates, moves, and answers about events directly.
- **Gmail** (via the official MCP server) — Sunday drafts replies in your voice, you approve, it sends.
- **Google Drive / GitHub / Figma / Supabase** — context for documents, code, designs, and databases the assistant should know about.

Combined real-world flow: walk somewhere, say *"remind me at 3pm to call Heinrich about the audit"* into Telegram. Sunday transcribes locally on your Pi, schedules the calendar event, files the call agenda in `tasks/clients/heinrich-audit-call.md`, wikilinks it from Heinrich's person page, and pings you at 3pm. Nothing forgotten, no tab to keep open.

---

## What this is not

- **Not a SaaS.** Sunday is a folder of markdown files and a few shell scripts. Yours, local, fork-friendly.
- **Not subject-matter-opinionated.** Sunday doesn't care whether your vault is about research, business, parenting, model trains, or all four at once.
- **Not a replacement for thinking.** Sunday is a structured place for your thinking to live and compound — you still bring the curiosity.

---

## Credits

- The underlying **LLM Wiki pattern** is by **Andrej Karpathy** — original gist: <https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f>. All credit for the core idea (raw / wiki / schema architecture, ingest-query-lint operations, "LLM is the librarian, Obsidian is the IDE, the wiki is the codebase" framing) goes to him.
- The **Sunday-specific implementation** — schema in `CLAUDE.md`, workflows, scripts, Pi / Telegram / Whisper integration, templates, cookbook — is by **Luca Wiegand / Wega Studios**, MIT-licensed for anyone to fork and adapt.
- Karpathy's full pattern doc included almost verbatim at [`docs/llm-wiki-pattern.md`](docs/llm-wiki-pattern.md) so every Sunday fork carries the rationale.

---

## Licence

MIT — see [LICENSE](LICENSE). Fork it. Ship it. Make it yours.
