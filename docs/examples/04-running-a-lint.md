# Walkthrough: running a lint

Maya has been in Sunday for four months. Lint hasn't been run in three weeks. She types "lint".

This walkthrough shows what the lint report looks like, what each section is for, and how Maya decides which findings to act on.

---

## Step 1 — The request

**Maya:** lint

**Assistant:** Running. Will produce `docs/lint-2026-05-04.md`. This is read-only — no edits to the vault, just the report. ~2 minutes for a vault this size.

---

## Step 2 — The lint report

> Writes `docs/lint-2026-05-04.md`:

```markdown
# Lint report — 2026-05-04

Vault snapshot: 78 wiki pages, 41 sources, 14 topics, 19 people, 27 active tasks.

## 1. Structure review

Layout still healthy at this size. Two observations:

- `tasks/research/` has grown to 17 files (most of any tasks subfolder). Consider whether `tasks/research/reading/` and `tasks/research/writing/` would help, or whether tags are enough.
- `topics/typography/` has 4 sub-pages now (parent + 3 children). Healthy.

No urgent restructuring needed. **Re-evaluate in ~2 months** or when `tasks/research/` crosses 30 files.

## 2. Contradictions

Three pages have explicit `> [!warning]` contradiction callouts:

- [[topics/low-vision]] flags Whitman ↔ responsive-typography-best-practices (device classes). **Open since 2026-05-04.** No follow-up yet — flagged for chapter 3.
- [[topics/typography]] flags Carter ↔ Burroughs on x-height vs. weight priority. **Open since 2026-02-18.** Two months old. Should be resolved.
- [[sources/articles/2024-11-context-not-class]] flags Whitman in passing but not symmetrically. Recommend adding a back-reference from Whitman's source page.

**Suggested actions:**
- Resolve the Carter/Burroughs contradiction (it's been open 2 months; either pick a side or write a comparison topic page like you did for breakpoints-vs-axes).
- Make the Context-not-Class ↔ Whitman reference symmetric.

## 3. Orphans

Wiki pages with no inbound wikilinks:

- `tasks/home/printer-ink.md` — standalone task, no project link by design. Acceptable orphan.
- `people/erik-soderberg.md` — created 6 weeks ago, no projects, no journal references. Was this a one-time contact?
- `ideas/marketing/print-zine-typography-quarterly.md` — idea that hasn't been touched since creation. Status still "open". Time to either move forward or `park`?

**Suggested actions:**
- Decide on Erik — keep, archive (move to `people/_archive/`), or delete.
- Decide on the zine idea — `park` or `dropped`.

## 4. Stale claims

Claims in the vault that newer sources may have superseded:

- [[topics/web-standards]] says variable fonts reached "production-grade" support in 2023. CanIUse may have moved on — re-check before citing in chapter 3.
- [[topics/low-vision]] cites Lighthouse audit metrics from 2023. Lighthouse 11 changed the methodology in early 2025 — verify the metric definitions still match.

**Suggested actions:**
- Spot-check the two claims; if accurate, no change. If stale, update the topic pages with `> [!info] Updated 2026-05-04 per current data`.

## 5. Missing topic pages

Concepts referenced ≥3 times that don't have their own page:

- `[[topics/colour-contrast]]` — referenced in 4 sources and 2 topic pages, page doesn't exist. **Worth creating.**
- `[[topics/dyslexia]]` — referenced 3 times. Worth creating if it'll grow; the references are all about a specific font (OpenDyslexic), so a single page may suffice.
- `[[topics/web-typography-history]]` — referenced twice, doesn't yet meet the 3-ref threshold. Watch.

**Suggested actions:**
- Create `topics/colour-contrast.md` (high confidence).
- Create `topics/dyslexia.md` only if the next source you ingest touches it; otherwise let it ride.

## 6. Missing crosslinks

Plausible crosslinks that are absent:

- [[projects/work/oslo-accessibility-workshop]] doesn't link to [[people/jonas-vee]] in its body (only in frontmatter `collaborators`). Add an inline mention in the Stakeholders section.
- [[topics/typography]] doesn't link to [[topics/typography/breakpoints-vs-axes]] from its body. Add it under "Sub-topics".
- [[sources/videos/2025-09-14-variable-fonts-accessibility]] doesn't link to [[topics/web-standards]] from its body despite it being in the frontmatter. Add a sentence under "Bearing on topics".

**Suggested actions:** small edits, no decisions required from you. I can apply these directly on your approval.

## 7. Data gaps (research opportunities)

Topics where targeted web search would likely add value:

- **Variable font latency on low-end devices** — already filed as `tasks/research/measure-variable-font-latency-low-end.md`. Still open. Three weeks old.
- **Dyslexia-specific fonts** — the OpenDyslexic / Lexie Readable / Comic Sans literature. Your vault has fragments, no synthesis. Could ingest a survey article.
- **Reading-aloud screen-reader interaction with variable fonts** — touched in one source, no follow-up. Likely active research area.

## 8. Naming oddities

- `people/heinrich-brandt.md` — surname is `brandt` but the slug has it spelled `brandt` and the body says `Brandt`. Consistent. No action.
- No `<thing>-tbd` placeholders found. Clean.
- `tasks/research/2026-04-12-read-axisway-paper.md` mixes date prefix and topic — inconsistent with the other read-later files which omit the date. Either standardise on date-prefixed names (more searchable chronologically) or strip the date here. Mild.

**Suggested action:** none urgent — pick a convention and update over time.

---

## Summary

3 contradictions (1 fresh, 2 ageing), 3 orphan-ish pages (1 acceptable, 2 needing a decision), 2 stale claims worth re-checking, 1 missing topic worth creating now, 1 missing topic to watch, 3 missing crosslinks (small edits), 3 research opportunities, 1 naming inconsistency.

Nothing on fire. The Carter/Burroughs contradiction is the oldest open item — worth resolving this week.
```

---

## Step 3 — Maya decides what to act on

**Maya:** create the colour-contrast topic page, apply the three crosslink fixes, park the print-zine idea. The carter/burroughs thing I'll handle myself — it needs more thought than a quick lint pass can give.

**Assistant:** OK. Three actions:

1. **Create `topics/colour-contrast.md`** — stub with placeholder body, will fill in as sources accumulate. Adding to `index.md`.
2. **Apply crosslink fixes** — three small edits in three files.
3. **Park the zine idea** — change `status: open` → `status: parked` in `ideas/marketing/print-zine-typography-quarterly.md`. Frontmatter only, no body change.

Doing these now. Each one is small enough that I won't ask again per-step; will summarise at the end.

[Three small edits later.]

Done. Committed as `refactor: lint actions from 2026-05-04 — create colour-contrast topic, apply crosslinks, park zine idea`. Three files written, two edited, one frontmatter change.

> Appends to `log.md`:
> ```
> ## [2026-05-04 19:15] lint | report at docs/lint-2026-05-04.md
> 78 pages, 14 topics. 3 contradictions (1 fresh / 2 ageing), 3 orphan-ish pages,
> 2 stale claims, 1 missing topic worth creating, 3 missing crosslinks, 3 research gaps.
>
> ## [2026-05-04 19:22] refactor | lint actions from 2026-05-04
> Created topics/colour-contrast.md. Applied 3 crosslink fixes
> (projects/work/oslo-accessibility-workshop.md, topics/typography.md,
> sources/videos/2025-09-14-variable-fonts-accessibility.md).
> Parked ideas/marketing/print-zine-typography-quarterly.md.
> ```

---

## What you should take from this

1. **Lint is read-only.** The report does not edit the vault. The follow-up "implementation pass" happens separately with your approval, item by item. This is deliberate — you keep the say over what changes.
2. **Lint findings are not commands.** Some are obvious to act on (apply crosslink fixes), some need your judgement (resolve a contradiction), some are watchful waiting (one more reference and dyslexia becomes a topic). The report names each kind explicitly.
3. **Old contradictions are the most expensive.** A fresh contradiction is just a TODO; a two-month-old one signals the vault is drifting. The lint surfaces both, but **age** is the actionable signal.
4. **Lint surfaces opportunities, not just problems.** Section 7 (research opportunities) is arguably the most valuable for a researcher — it points at things your vault almost-but-doesn't-quite cover.
5. **Run lint every ~3–4 weeks at this size.** More often and it nags; less often and contradictions ossify. The right cadence drifts as the vault grows; adjust.
