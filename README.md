# Sunday — A Personal Assistant Vault Template

**Sunday** is a ready-to-fork template for building an LLM-maintained second brain. You bring an [Obsidian](https://obsidian.md) vault, [Claude Code](https://docs.claude.com/en/docs/claude-code) (or any agent that reads `CLAUDE.md` / `AGENTS.md`), and your own raw material. Sunday gives you the **schema**, the **workflows**, the **templates**, and the **integrations** so you can start using the assistant the same day you clone the repo.

Built on the [LLM Wiki pattern](docs/llm-wiki-pattern.md) by **Andrej Karpathy** ([original gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f), April 2026) — Sunday is one opinionated instantiation of that pattern, contributed by Luca Wiegand / Wega Studios.

---

## What you get

- **A complete schema** (`CLAUDE.md`) that turns Claude into a disciplined wiki maintainer — not a generic chatbot.
- **Six well-defined workflows**: Capture → Triage → Ingest → Query → Lint → Refactor.
- **Frontmatter templates** for every page type (idea, project, task, topic, person, source, journal).
- **A cookbook** with full walkthroughs (`docs/examples/`) so you can see what good runs look like before you do your own.
- **Optional integrations** (`docs/setup/`): host your assistant on a Raspberry Pi 24/7, talk to it via Telegram (voice or text), back it with Whisper transcription — all on your Claude Pro/Max plan, no API tokens.
- **An evolution-log pattern** (tool vs. personal split) so your customisations stay tidy and forkable.

---

## What this is not

- Not a SaaS or hosted product. Sunday is a folder of markdown + shell scripts.
- Not opinionated about your subject matter. You decide what your vault is about — research, business, self-development, fan-wiki for a TV show.
- Not a replacement for thinking. Sunday is a structured place for your thinking to live and compound; you still bring the curiosity.

---

## Quick start (5 minutes)

```bash
# 1. Clone Sunday as your vault
git clone https://github.com/YOUR-USERNAME/sunday-vault.git my-vault
cd my-vault

# 2. Open as Obsidian vault
#    Obsidian → "Open folder as vault" → pick my-vault/

# 3. Enable the Dataview plugin
#    Settings → Community plugins → Browse → "Dataview" → Install + Enable
#    (Sunday's index.md and topic pages use Dataview queries.)

# 4. Read CLAUDE.md once, top to bottom.
#    It IS the assistant's constitution — every Claude Code session in this
#    repo will read it first.

# 5. Talk to Claude Code inside the repo
claude
> Hi. Read CLAUDE.md and tell me how you understand your role.
```

That's the whole setup. Drop a note into `inbox/`, say "triage", watch the assistant file it.

---

## Where things live

| Folder        | What it holds                                                                 |
|---------------|-------------------------------------------------------------------------------|
| `inbox/`      | Unstructured quick-capture. Triaged into the rest by the assistant.           |
| `ideas/`      | Ideas of any kind, grouped by area.                                           |
| `projects/`   | Active undertakings, optionally tied to people.                               |
| `tasks/`      | To-dos, with Dataview overviews.                                              |
| `topics/`     | Knowledge / research nodes (e.g. "AI", "investing", "cooking").              |
| `people/`     | Clients, colleagues, contacts, creators you follow.                           |
| `journal/`    | Daily entries (`YYYY-MM-DD.md`).                                              |
| `sources/`    | Wiki pages for ingested videos / articles / podcasts (summary + crosslinks). |
| `raw/`        | Immutable originals (transcripts, full article text, assets).                 |
| `docs/`       | The meta layer — schema docs, templates, the cookbook, setup guides.          |
| `scripts/`    | Optional shell helpers (Telegram, scheduled reminders, voice transcription).  |

---

## The six workflows in one breath

1. **Capture** — you drop raw stuff into `inbox/`. Nothing structured.
2. **Triage** — you say "triage", the assistant sorts everything into the right page with proper frontmatter and crosslinks.
3. **Ingest** — you hand the assistant a URL/file, it downloads, summarises, integrates into topic pages, logs.
4. **Query** — you ask a question, the assistant searches the wiki and answers with citations. Reusable answers get saved as new pages.
5. **Lint** — periodically, the assistant audits the vault for contradictions, orphans, stale claims, missing crosslinks.
6. **Refactor** — schema changes, big reorganisations, mass renames. Always with your approval.

See `CLAUDE.md → Workflows` for the exact steps the assistant follows.

---

## Customising Sunday

Sunday's defaults are opinionated examples — you are expected to adapt them.

- **Areas** (the `area` field on most pages). The defaults are grouped by use-case in `CLAUDE.md` (business / personal / knowledge / catch-all). Replace them with whatever fits your life — `homeschool`, `band`, `phd-thesis`, `mtg-collection`. The schema is open.
- **Language**. Schema words (`typ: idea`, `status: open`) stay in English so Dataview queries are stable. The **body** of any page can be in any language — German, Spanish, Japanese, mixed. Tell Claude in your first session what language you want and it will write that way.
- **Status / priority / role enums**. All listed in `CLAUDE.md` as comments. Extend freely; just document in `docs/personal-preferences.md` so future sessions stay consistent.
- **Workflows**. If "triage" should always commit & push, or "ingest" should never auto-update topics, write that down in `CLAUDE.md`. The assistant follows what's there.

---

## The improvement-log split

When you live in Sunday for a while, you'll learn things — about the tool ("this convention causes friction") and about yourself ("I want haircut appointments coloured red"). Sunday separates these:

- `docs/tool-evolution.md` — **generic** lessons. Forkable. Useful to others.
- `docs/personal-preferences.md` — **your** preferences, colour choices, area names, personal corrections. Gitignored in this template repo so you never accidentally publish them.

When you fork Sunday for your own use, remove `docs/personal-preferences.md` from `.gitignore` so your prefs get tracked in *your* private fork.

---

## Optional: host it on a Pi, talk to it via Telegram

The `docs/setup/` folder has step-by-step guides for:

- **`raspberry-pi.md`** — turn a Pi 5 into a 24/7 Claude Code host, addressable from anywhere via Tailscale and the Anthropic mobile app.
- **`telegram-voice.md`** — text or voice messages to a Telegram bot, transcribed locally with `whisper.cpp`, answered by the assistant on the Pi, all on your Pro/Max plan.
- **`pi-handoff-prompt.md`** — a reusable prompt you can hand to another agent (or human) to do the Pi setup for you.

You don't need any of this to use Sunday. It works fine as a plain Obsidian vault you talk to via the Claude Code CLI.

---

## Contributing

Sunday is intentionally small. PRs welcome for:

- bug fixes in scripts or setup guides
- generic schema improvements that apply to all users
- new setup guides for other hosting / messaging stacks
- translations of `CLAUDE.md` to additional languages

Things that should **not** be in PRs: your personal areas, your personal projects, your journal entries. Keep your fork private for that.

---

## Credits

- The underlying **LLM Wiki pattern** is by **Andrej Karpathy** — see his public gist: <https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f>. All credit for the core idea (raw / wiki / schema three-layer architecture, ingest-query-lint operations, LLM-as-librarian framing) goes to him.
- The **Sunday-specific implementation** (this repo's schema, workflows, scripts, Pi / Telegram / Whisper integration, templates, cookbook) is by **Luca Wiegand / Wega Studios**, released under MIT for anyone to fork and adapt.
- Pattern doc included verbatim-ish at [docs/llm-wiki-pattern.md](docs/llm-wiki-pattern.md) so every Sunday fork carries the rationale.

## Licence

MIT — see [LICENSE](LICENSE).
