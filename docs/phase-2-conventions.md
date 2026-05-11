# Phase 2 Conventions

Collection of conventions and rules that apply to **Phase 2 features** — defined here **before** the features are implemented, so the implementation decisions can respect them later.

Phase 2 features are listed in `CLAUDE.md → Phase 2`:

- Google Calendar sync for tasks and appointments
- Structured client / customer pipeline with stage transitions
- Weekly reviews via the `/loop` skill
- `qmd`-based search once the vault exceeds ~100 sources
- Mobile quick-capture via Obsidian Mobile (or via the Telegram bot in `docs/setup/telegram-voice.md`)

When the user mentions a convention that only takes effect in Phase 2, it lands here.

---

## Calendar sync

### Colour per appointment type (framework)

Once a calendar MCP is wired up and tasks / appointments are mirrored to the calendar: **whatever you decide for one appointment type applies to every future appointment of that type.**

User-specific colour mappings live in `docs/personal-preferences.md` (private). This file only describes the framework.

### Frontmatter convention for synced items

When a `task` file with the `#appointment` tag is mirrored to a calendar event, the following fields go into the frontmatter:

```yaml
calendar-event-id: <event-id>
calendar-link: <url>
calendar-color: <colorId 1-11 for Google Calendar>
```

Plus the `#calendar-synced` tag.

### Implementation hints

- The Google Calendar API encodes event colours as indices 1–11 (`colorId`). User mapping: see `docs/personal-preferences.md`.
- When syncing a `task` page with the `#appointment` tag to a calendar event, derive the appointment type from the file slug or its tags and map to the user's colour.

---

## Mobile quick-capture

_(no conventions yet — write as they emerge)_

---

## Structured client pipeline

_(no conventions yet — write as they emerge)_

Likely candidates: stage enum (`lead → qualified → proposal-sent → won → lost`), stage-transition log on the project page, per-stage default next-step.

---

## `qmd` search

_(no conventions yet — write as they emerge)_

Likely candidates: which fields to index, which to skip, ranking weight for frontmatter vs. body, where the index lives in the repo (or whether it's gitignored).

---

## Weekly reviews

_(no conventions yet — write as they emerge)_

Likely candidates: weekly review template (`docs/templates/weekly-review.md`), cadence (every Sunday evening?), what to surface (completed tasks, slipped deadlines, untouched projects, ingested sources this week), where the output lives (`journal/YYYY-Www-review.md`?).

---

## How this file grows

- On every capture / triage where the user mentions a Phase 2 convention → add an entry under the relevant feature header.
- When a Phase 2 feature is implemented: carry the conventions into the implementation, then mark each entry "migrated to `<implementation-path>`" — do not delete; the trail matters.
- When an entry becomes contradicted by a later entry: strike the old (`~~text~~`) and add the new with a reference to the superseded one.
