# Walkthrough: your first triage

**Persona for this example:** Maya Liu, PhD researcher on typography legibility for low-vision readers. She just installed Sunday and has been dumping things into `inbox/` for two days. Now she says "triage".

This walkthrough shows what the assistant does step-by-step — including the clarifying questions, where the resulting pages end up, and what the log entry looks like at the end.

---

## The inbox before

```
inbox/
  2026-05-03-1410-typeface-paper.md
  2026-05-03-1855-scratch.md
  2026-05-04-0930-jonas-followup.md
```

**`2026-05-03-1410-typeface-paper.md`:**
```
Found this: https://www.example-journal.org/papers/2024-12-perpetua-readability
Strong claim that serif > sans-serif for low-vision readers at small sizes.
Want to read carefully. Save for later — connects to my chapter 3.
```

**`2026-05-03-1855-scratch.md`:**
```
- ping Prof. Voss about defence date
- workshop slides for Oslo conf — need outline before May 20
- idea: short video series for accessible web typography? "5 things designers get wrong"
- buy new printer ink
- Heinrich from Bjorn Studio wants quote for accessibility audit
```

**`2026-05-04-0930-jonas-followup.md`:**
```
Met Jonas (designer, freelance) at Oslo prep meeting. He's keen on the workshop.
Could co-present? Slack: @jonas-vee
```

---

## The triage session

**Maya:** triage

**Assistant:** Found 3 files in `inbox/`. Going through them in order.

### File 1: `2026-05-03-1410-typeface-paper.md`

This looks like an article you want to ingest. Two questions:

1. Should I ingest it now (download, summary, source page) or only file the link as a "to-read" idea?
2. Which area? Looks like `research` based on your chapter-3 reference, but could be `learning` if you mean it more loosely.

**Maya:** ingest it later, just file the link for now. area research.

**Assistant:** OK. Filing as a `task` in `tasks/research/`, type "read this paper", priority medium, no due date. Adding a `read-later` tag so we can find these together later.

> Writes `tasks/research/read-perpetua-low-vision-readability.md`:
> ```yaml
> ---
> typ: task
> area: research
> status: open
> priority: medium
> created: 2026-05-03
> tags: [read-later, typography, low-vision]
> ---
>
> # Read: Perpetua-style serif vs sans-serif for low-vision readers
>
> ## What to do
>
> Read https://www.example-journal.org/papers/2024-12-perpetua-readability and decide whether to ingest as a source.
>
> ## Acceptance criterion
>
> Either: ingested as `sources/articles/2024-12-perpetua-readability.md` with topic crosslinks, or: closed as "skim showed it's not relevant".
>
> ## Context
>
> Strong claim that serif > sans-serif for low-vision readers at small sizes — connects to my chapter 3.
> ```

### File 2: `2026-05-03-1855-scratch.md`

Five items in one note. Splitting them.

- **"ping Prof. Voss about defence date"** → standalone task, area `study`, priority high (defence date is structural).
- **"workshop slides for Oslo conf — need outline before May 20"** → looks like a task on an existing project. Do you have an Oslo workshop project, or should I create one?

**Maya:** create the project, area is `work`, deadline May 28.

**Assistant:** Creating `projects/work/oslo-accessibility-workshop.md` with deadline 2026-05-28, status active, next-step "draft outline". The slides task becomes a sub-task linked to that project, due 2026-05-20.

- **"idea: short video series for accessible web typography? '5 things designers get wrong'"** → idea, area `side-projects` (or `marketing`?). Which?

**Maya:** marketing, rating "good"

**Assistant:** Filing as `ideas/marketing/short-video-series-typography.md`, rating good, status open.

- **"buy new printer ink"** → standalone task, area `home`, priority low. No due date. OK to just file it?

**Maya:** ja

**Assistant:** Filed.

- **"Heinrich from Bjorn Studio wants quote for accessibility audit"** → looks like a potential client engagement. Two things:
  1. Should I create a person page for Heinrich? Full name?
  2. Is this a project (active) or an idea (still negotiating)?

**Maya:** person yes — Heinrich Brandt. it's still a lead, treat as a task to follow up.

**Assistant:** Creating `people/heinrich-brandt.md` (role: client, area: clients). Filing a standalone task `tasks/clients/heinrich-brandt-audit-quote.md` with the person wikilinked and priority high (lead is fresh).

### File 3: `2026-05-04-0930-jonas-followup.md`

Person + workshop context.

- Creating `people/jonas-vee.md`, role `co-presenter`. (Is "co-presenter" the right enum value, or should this be `collaborator`?)

**Maya:** use `co-presenter`, add it to my schema.

**Assistant:** Adding `co-presenter` to the role enum in `docs/personal-preferences.md` (this is a user-specific extension), cross-referenced into `docs/tool-evolution.md` since "role enum is open" is a generic pattern others would benefit from.

- Adding Jonas as a collaborator on the Oslo workshop project page. Adding "decide whether to co-present" to its decision log so the question doesn't get lost.

### Summary

| File | Outcome |
|---|---|
| `typeface-paper.md` | → `tasks/research/read-perpetua-low-vision-readability.md` |
| `scratch.md` | → 5 pages: 1 project, 3 tasks, 1 idea, plus 1 person |
| `jonas-followup.md` | → `people/jonas-vee.md` + edit to Oslo workshop project |

All inbox files deleted. `index.md` updated. `log.md` entry appended. Three new wikilinks need targets (a `topics/typography` page is referenced but doesn't exist yet — I'll flag that in the next lint).

---

## What ended up in `log.md`

```
## [2026-05-04 09:48] triage | 3 inbox files → 1 project, 4 tasks, 1 idea, 2 people, 1 schema extension

Files handled:
- 2026-05-03-1410-typeface-paper.md → tasks/research/read-perpetua-low-vision-readability.md
- 2026-05-03-1855-scratch.md → projects/work/oslo-accessibility-workshop.md +
  tasks/study/voss-defence-date-ping.md + tasks/work/oslo-workshop-slide-outline.md +
  tasks/home/printer-ink.md + ideas/marketing/short-video-series-typography.md +
  tasks/clients/heinrich-brandt-audit-quote.md + people/heinrich-brandt.md
- 2026-05-04-0930-jonas-followup.md → people/jonas-vee.md + edited
  projects/work/oslo-accessibility-workshop.md

Schema change: `role` enum extended with `co-presenter`
  (docs/personal-preferences.md + docs/tool-evolution.md cross-ref).

Open: topics/typography referenced but not yet created — surface in next lint.
```

---

## What you should take from this

1. **Asking is the default.** The assistant asked you about area, ingest-now-vs-later, project-vs-task, role enum extension. Don't expect the agent to silently guess — wrong filing is much harder to recover from later.
2. **One inbox file can produce many wiki pages.** The scratch file became 7 outputs. That's normal — the inbox is unstructured, the wiki is.
3. **Schema additions get logged in two streams.** A new role value is a generic-enough pattern that goes to `tool-evolution`, and the specific user choice goes to `personal-preferences`. The cross-reference makes the trail durable.
4. **The log entry is greppable.** `grep "^## \[2" log.md | tail -5` is a one-liner that surfaces the last few operations.
