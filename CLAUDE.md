# CLAUDE.md — Schema for the Sunday Vault

This file is the constitution for every Claude Code session inside this repo. It describes **how** the vault is structured, **which conventions** apply, and **which workflows** you (the agent) execute.

> Read this file in full at the start of every session. When user instructions and this schema conflict, **the user wins**. When the schema has gaps: ask, then update the schema in the same session.

> **For human readers:** Sunday is the template; this file is the contract between you and Claude. Edit it freely to fit your life — area names, status values, workflow steps. The assistant follows what's written here. If you fork Sunday, this is the first file you should customise.

---

## Mission

The vault is the user's personal **second brain**. It is designed to cover, at minimum:

- **Knowledge aggregation** — videos, articles, podcasts, books, courses.
- **Idea management** — fleeting thoughts, evaluated and graduated to projects when worth it.
- **Project & task management** — active undertakings, with due dates and priorities.
- **People & relationships** — clients, colleagues, friends, family, creators followed.
- **Self-development & journalling** — daily entries, learnings, reflections.
- **Research deep-dives** — topical synthesis across many sources.

**You** are the primary author of all wiki content. **The user** supplies sources, triages inbox items, asks questions, and decides when something is ambiguous. You never write content on your own initiative — every page you create traces back to a user action.

---

## Language

**Schema words stay in English** — type names (`typ: idea`), status values (`status: open`), priority levels (`priority: high`), enum members. This is non-negotiable because Dataview queries depend on stable strings.

**Body content follows the user's preference.** If the user writes to you in German, write the body in German. If they switch mid-session, follow them. Mixed languages within a page are fine.

**Filenames**: always kebab-case, lowercase, ASCII. `farbpalette-vorschlag.md`, not `Farbpalette Vorschlag.md`. No spaces, no capitals, no umlauts in filenames — render umlauts in the body, not the path.

---

## Directory layout

```
/
  CLAUDE.md                ← this file
  README.md                ← human-facing intro
  index.md                 ← catalogue of all wiki pages (Dataview + manual sections)
  log.md                   ← append-only operations log
  LICENSE
  .gitignore
  .gitattributes
  inbox/                   ← unsorted quick-capture
    README.md
  ideas/                   ← ideas, grouped by area
  projects/                ← active undertakings
  tasks/                   ← to-dos with metadata
  topics/                  ← knowledge / research nodes
  people/                  ← clients, colleagues, contacts, creators
  journal/                 ← daily entries YYYY-MM-DD.md
  sources/                 ← wiki pages for ingested sources
    videos/
    articles/
    podcasts/
    books/                 ← optional, create on demand
  raw/                     ← immutable originals
    videos/<slug>/transcript.md, summary.md, meta.json
    articles/, podcasts/, books/, assets/
  scripts/                 ← optional shell helpers (Telegram, reminders, voice)
  docs/                    ← meta: pattern doc, templates, examples, setup guides, improvement logs
    llm-wiki-pattern.md
    tool-evolution.md
    personal-preferences.md   (gitignored — your private layer)
    phase-2-conventions.md
    templates/                ← per-type frontmatter + body skeletons
    examples/                 ← cookbook walkthroughs
    setup/                    ← optional integration guides (Pi, Telegram, …)
  .obsidian/               ← plugin config (Dataview enabled)
```

**What goes where:**

- An idea → `ideas/<area>/<kebab-title>.md`
- A project → `projects/<area>/<kebab-title>.md` (for client work: `projects/<area>/<client-slug>-<project-slug>.md`)
- A task → either single file `tasks/<area>/<kebab-title>.md` OR inline checkbox list in the project page. **Default to a single file** the moment the task needs metadata (due date, priority, tag).
- A topic → `topics/<kebab-topic>.md`, or `topics/<kebab-topic>/index.md` plus sub-pages when the topic is large.
- A person → `people/<firstname-lastname>.md`.
- A journal entry → `journal/YYYY-MM-DD.md`.
- An ingested source → wiki page `sources/<type>/<YYYY-MM-DD-kebab-title>.md` **plus** raw material in `raw/<type>/<YYYY-MM-DD-kebab-title>/`.

---

## Frontmatter conventions

Every wiki page (except `index.md`, `log.md`, `README.md`) **must** have YAML frontmatter. Dataview reads it at query time, so consistent fields = useful queries.

**Templates** with complete frontmatter and body skeletons live in `docs/templates/<type>.md` (`idea`, `project`, `task`, `topic`, `person`, `source`, `journal`). When creating a new page: start from the template, replace placeholders, never invent fields silently.

### Idea

```yaml
---
typ: idea
area: side-projects     # see "Default areas" below
status: open            # open | active | shipped | dropped | parked
rating: good            # good | medium | bad | unrated
created: 2026-05-03
tags: [business, podcast]
---
```

`status: parked` is for ideas you want to keep but don't intend to work on soon. `shipped` is for ideas that became real things — keep the wikilink to the resulting project page.

### Project

```yaml
---
typ: project
area: clients
client: "[[people/firstname-lastname]]"   # optional
status: active          # active | paused | done | abandoned
deadline: 2026-06-15    # optional
next-step: "Send the colour palette draft"
tags: [website, client]
---
```

The `next-step` field is mandatory for `status: active` projects. The assistant uses it to answer "what should I work on?". When you finish the next step, update the field — don't leave it stale.

### Task

```yaml
---
typ: task
project: "[[projects/clients/firstname-lastname-website]]"   # optional — omit for standalone tasks
area: clients
status: open            # open | in-progress | done | dropped
due: 2026-05-10         # optional
priority: high          # high | medium | low
created: 2026-05-03
tags: [design]
---
```

A **standalone task** (no project link) is normal — "renew passport", "book dentist", "file taxes". Leave the `project` field out. The Dataview in `index.md` lists both kinds.

### Topic

```yaml
---
typ: topic
status: active          # active | dormant
sources-count: 0
last-updated: 2026-05-03
tags: [ai, generative]
---
```

`sources-count` is bumped by you on every source ingest that touches this topic. `last-updated` likewise.

### Person

```yaml
---
typ: person
role: client            # client | colleague | friend | family | service-provider | co-founder | creator | mentor | other
area: clients
projects: ["[[projects/clients/firstname-lastname-website]]"]
tags: []
---
```

- `creator` — external content creators (YouTubers, podcasters, authors) whose material feeds the wiki.
- `co-founder` — business partners on joint ventures.
- `mentor` / `service-provider` — accountants, doctors, advisors. Adapt freely.

### Source

```yaml
---
typ: source
source-type: video      # video | article | podcast | book | course | talk
url: https://www.youtube.com/watch?v=...
author: "Author Name"
published: 2026-04-12
ingested: 2026-05-03
topics: ["[[topics/ai]]", "[[topics/llm-training]]"]
tags: []
---
```

### Journal

```yaml
---
typ: journal
date: 2026-05-03
tags: []
---
```

---

## Default areas

Areas are the top-level groupings used by `area` fields throughout the schema. The default list below is grouped by use-case so you can pick the slice that matches your life. **Extend or replace freely** — declare new areas in `docs/personal-preferences.md` so future sessions stay consistent.

**Work / business**
- `work` — your day job / main business
- `clients` — client engagements
- `finance` — books, taxes, banking, invoicing
- `side-business` — second venture, joint ventures
- `marketing` — content, ads, audience growth

**Personal**
- `personal` — catch-all for self-related items that don't fit elsewhere
- `health` — fitness, medical, sleep, nutrition
- `family` — partner, kids, parents
- `home` — household, repairs, gardening
- `hobbies` — leisure, sports, games

**Knowledge / growth**
- `learning` — courses, books, deliberate practice
- `research` — deep-dives, topical investigation
- `tech` — technical knowledge, tools, libraries you follow
- `study` — formal education (school, university, certifications)

**Catch-all**
- `other` — used sparingly. If it lands here three times, ask whether a new area is warranted.

Pick the ones you'll use; ignore the rest. The schema does not validate against this list — Dataview groups by whatever string you put in the `area` field, so consistency is **your** discipline, not the schema's.

---

## index.md

Content-oriented catalogue. Organised by top-level category. Each entry is one line: `- [[path/to/page]] — one-line description`.

**The assistant updates `index.md` on every ingest and every triage.** No exception.

The top of `index.md` holds **Dataview quick-link blocks** — "active client projects", "open high-priority tasks", "ideas waiting on user decision". These are dynamic and re-render on every Obsidian open. The bottom of `index.md` is **handwritten** sections per category for things Dataview can't easily express ("recommended reading", "setup guides", "long-running threads").

Don't put long-form content into `index.md`. It is a catalogue, not a memory.

---

## log.md

Append-only log. Every entry follows this format:

```
## [YYYY-MM-DD HH:MM] <type> | <short description>
<2–3 lines of detail, affected files, optionally an open question>
```

`<type>` ∈ `{capture, triage, ingest, query, lint, refactor, init}`.

The format is greppable — real entries all start with `## [2` (year prefix), so `grep "^## \[2" log.md | tail -10` shows the last 10 operations.

**Write a log entry on every workflow run** (triage, ingest, lint, refactor). For queries: only log when the answer was saved back into the wiki as a new page.

---

## Workflows

### 1. Capture (user → `inbox/`)

The user drops raw thoughts / links / transcripts as markdown files into `inbox/`. No structure required. You do nothing here — you wait for the user to say "triage".

### 2. Triage (user: "triage" → you)

1. List every file in `inbox/`.
2. Read them in order. For each file:
   - Determine the type (idea / project / task / topic / person / source / journal).
   - Determine area, status, rating/priority, tags.
   - **When ambiguous: ask the user.** Better to ask than to guess — mis-filed pages are hard to find later.
   - Write the target page with complete frontmatter and wikilinks.
   - Update `index.md`.
   - Delete the inbox file.
3. Append a `triage` entry to `log.md`.

### 3. Ingest source (user: URL / file → you)

1. Use the `video-fetch-and-summarize` skill (YouTube / TikTok / etc.) or direct download (article → markdown via web fetch) or the `link-download` skill for other platforms.
2. Place raw material under `raw/<type>/<YYYY-MM-DD-kebab-title>/`: at minimum `transcript.md` (or `content.md` for articles), `summary.md`, and `meta.json` with `{url, author, published, ingested, duration?}`.
3. Write the wiki page `sources/<type>/<slug>.md` with full frontmatter, key claims, quotes with line references back to `raw/`, and crosslinks to all relevant `topics/` and `ideas/`.
4. Update **every** affected `topics/` page: integrate new findings, flag contradictions to prior claims explicitly (`> [!warning] Contradicts [[sources/...]] on X`), bump `sources-count`, set `last-updated` in the frontmatter.
5. Update `index.md` (new source entry, new topic stubs if needed).
6. Append an `ingest` entry to `log.md`.

Rule of thumb: **a single source touches 5–15 wiki pages.** If you touched fewer, double-check you didn't miss a topic.

### 4. Query (user asks → you)

1. Read `index.md` first, identify candidate pages.
2. Read the relevant pages.
3. Answer with citations as wikilinks (e.g. "According to [[sources/videos/2026-04-12-llm-training]], …").
4. If the answer is **reusable** (a synthesis, a comparison, a new insight): explicitly ask "Should I save this as a wiki page?". On confirmation → write under the appropriate top-level folder + update `index.md` + log it.

### 5. Lint (user: "lint" — or periodically → you)

Produce `docs/lint-YYYY-MM-DD.md` with these sections:

1. **Structure review** — is the top-level layout still healthy? Which areas have grown enough to warrant splitting?
2. **Contradictions** — pages that contradict each other.
3. **Orphans** — wiki pages with no inbound wikilinks.
4. **Stale claims** — statements that newer sources have superseded.
5. **Missing topic pages** — concepts referenced ≥3 times that don't have their own page.
6. **Missing crosslinks** — places where a link should exist.
7. **Data gaps** — topics that targeted web research could fill.
8. **Naming oddities** — placeholder names (`<thing>-tbd`, `#name-missing`), inconsistent casing, dangling client links.

Lint is **read-only**. Implementation passes happen separately, one suggestion at a time, with user approval. Append a `lint` entry to `log.md`.

### 6. Refactor (planned structural changes)

Expected every few weeks. Triggered by a lint finding or a direct user request.

1. Propose the layout change with the reasoning.
2. On approval: migrate pages **and update every affected wikilink** (Glob + Grep across the whole vault — do not stop at "the obvious ones").
3. Update `index.md`.
4. Append a `refactor` entry to `log.md` listing every renamed / moved path.

---

## Tooling

- **Skills:** `video-fetch-and-summarize` (primary for video ingest), `link-download` (fallback / non-video platforms), `find-skills` (when a new source type or platform appears).
- **MCP servers** (when configured): Gmail, Google Calendar, Google Drive, GitHub, Figma. Calendar is Phase-2-relevant for task sync.
- **Dataview plugin** must be enabled in Obsidian. You use it to generate dynamic lists in `index.md`, topic pages, project pages, and person pages.
- **Git**: every workflow that mutates the vault ends with an explicit-path `git add` (never `git add -A` or `git add .` — they accidentally pull in `.claude/`, `.obsidian/workspace.json`, raw media, secrets), a meaningful commit message, and a push.

---

## Anti-patterns (do NOT do)

- Write content directly into `index.md`. The index is a catalogue, not memory.
- Modify files under `raw/`. They are immutable.
- Create wiki pages without frontmatter.
- File inbox items into the wiki without triage. (No silent placement.)
- Guess at wikilinks. When unsure, `ls` or Glob first.
- Guess instead of asking when an item is ambiguous.
- Use spaces or capital letters in filenames. Always kebab-case.
- Make structural changes without writing a `refactor` entry in `log.md`.
- Run `git add -A` / `git add .`. Always explicit paths.
- Write to `docs/personal-preferences.md` thinking it's the public stream. It is gitignored in this template; if you fork Sunday and want your prefs tracked privately, remove the line from `.gitignore`.

---

## Phase 2 (out of current scope)

Planned extensions — **do not implement without an explicit user request**:

- Google Calendar sync for tasks and appointments.
- Structured client / customer pipeline with stage transitions.
- Weekly reviews via the `/loop` skill (automated lint + retrospective).
- `qmd`-based search once the vault exceeds ~100 sources.
- Mobile quick-capture via Obsidian Mobile (or via the Telegram bot in `docs/setup/telegram-voice.md`).

**Conventions for Phase 2** are collected in `docs/phase-2-conventions.md`. When the user mentions a rule that applies to a not-yet-built feature ("hair appointments should always be red in the calendar"), record it there — **not** in this file. Keeps the schema focused. When Phase 2 actually gets built: walk that file end-to-end first.

---

## Improvement logs (tool vs. personal split)

When you learn something that should outlive this session, it goes into one of two logs:

### Tool stream (public, forkable)
File: **`docs/tool-evolution.md`**
For **generic** patterns — schema improvements, workflow refinements, tool limitations, conventions for external integrations. Anything another Sunday user would benefit from.

### Personal stream (private, never published)
File: **`docs/personal-preferences.md`** (gitignored)
For **user-specific** preferences — colour choices, area-name additions, person/project facts, individual corrections.

### Trigger — which stream gets the entry

**Tool stream triggers:**
- You changed `CLAUDE.md` with general effect → type `decision` or `improvement`.
- You hit a tool limit or workflow friction that every user would hit → type `problem`.
- A lint pass surfaced a recurring pattern → type `pattern`.
- An external integration established a frontmatter convention.

**Personal stream triggers:**
- The user made a user-specific decision (an area name, a colour, a workflow preference).
- The user corrected you with a personal reasoning ("my preferred format is X").
- A concrete person- or project-fact that affects structure ("client X has no last name yet, working around with slug Y").

**When an entry is both** (pattern + specific application):
- Pattern → tool stream.
- Specific instance → personal stream.
- Cross-reference each direction with wikilinks.

### What does NOT belong in either log

- Vault content problems → those go in the next lint report.
- Routine operations → those go in `log.md`.
- Concrete daily tasks → those go in `tasks/`.

Better one entry too many than too few — but always in the **right** stream.

---

## Schema evolution

This schema is a **starting point**, not a final state. Review it every few weeks. When you (the agent) notice a convention isn't working, **record it in the right stream** (`tool-evolution.md` for generic lessons, `personal-preferences.md` for personal preferences — see the previous section) and **flag it in the next lint report**. Do not change the schema on your own — the user approves changes.

---

## A note on autonomy

You have broad permissions in this repo (the user has accepted that). That makes precision more important, not less. Defaults:

- Read freely.
- Write to the wiki whenever a workflow calls for it.
- Run shell commands for legitimate vault operations (Git, Glob, Grep, file ops).
- Use configured MCP tools (Calendar, Mail, etc.) when the user's request implies them.

But:

- Never push to a remote you weren't told to push to.
- Never run destructive Git operations (`reset --hard`, `push --force`, branch deletes) without explicit confirmation.
- Never modify `raw/`.
- Never silently change schema, file naming conventions, or the workflow steps in this file.

When in doubt, ask. The cost of a quick clarifying question is much lower than the cost of an unwanted action.
