# Index

Catalogue of every wiki page. Updated on every ingest and every triage. Grows with the vault.

The top of this file is **dynamic** — Dataview re-runs the queries on every Obsidian open. The bottom is **handwritten** sections per category for things Dataview can't easily express. Both layers are useful.

> **Note for the assistant:** this file is the first thing you read on a query workflow. Find the candidate pages here, then drill in.

---

## Quick links — dynamic (Dataview)

### Open tasks (any area)

```dataview
TABLE area, status, due, priority
FROM "tasks"
WHERE typ = "task" AND status != "done" AND status != "dropped"
SORT priority ASC, due ASC
```

### Active projects

```dataview
TABLE area, status, deadline, next-step AS "Next step"
FROM "projects"
WHERE typ = "project" AND status = "active"
SORT deadline ASC
```

### Ideas waiting on a decision

```dataview
TABLE area, rating, created
FROM "ideas"
WHERE typ = "idea" AND status = "open"
SORT rating ASC, created DESC
```

### Recently ingested sources

```dataview
TABLE source-type, author, ingested
FROM "sources"
WHERE typ = "source"
SORT ingested DESC
LIMIT 15
```

### People with active projects

```dataview
TABLE role, area, length(filter(file.inlinks, (f) => f.typ = "project" AND f.status = "active")) AS "Active projects"
FROM "people"
WHERE typ = "person"
SORT file.name ASC
```

### Hottest topics (by source count)

```dataview
TABLE sources-count, last-updated, status
FROM "topics"
WHERE typ = "topic"
SORT sources-count DESC
LIMIT 10
```

---

## Manual catalogue

The sections below are kept by hand. Each entry: `- [[path/to/page]] — one-line description`. The assistant updates this on every triage and ingest. Empty sections are fine — they just mean you haven't put anything there yet.

### Ideas

_(empty)_

### Projects

_(empty)_

### Standalone tasks (no project)

_(empty)_

### Topics

_(empty)_

### People

_(empty)_

### Sources

#### Videos
_(empty)_

#### Articles
_(empty)_

#### Podcasts
_(empty)_

#### Books
_(empty)_

### Setup guides

- [[docs/setup/raspberry-pi]] — run Sunday on a Pi 5 as a 24/7 Claude Code host (optional)
- [[docs/setup/telegram-voice]] — talk to Sunday from your phone via Telegram, voice or text (optional)
- [[docs/setup/pi-handoff-prompt]] — reusable prompt to delegate the Pi setup to another agent

### Pattern doc

- [[docs/llm-wiki-pattern]] — the LLM Wiki pattern (Geoffrey Litt) that Sunday implements

### Journal

_(populated automatically by file listing in Obsidian)_
