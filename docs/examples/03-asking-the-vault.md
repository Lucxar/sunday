# Walkthrough: asking the vault

Maya has been working in Sunday for three months. Her vault now has ~40 sources, ~80 wiki pages. She's writing chapter 3 of her thesis and needs to figure out what her own vault thinks about a specific question.

This walkthrough shows the **query workflow** — how the assistant searches, how citations look, and the decision point where a good answer gets saved back into the wiki as a new page.

---

## The question

**Maya:** Across everything I've read, what's the strongest case for / against device-class breakpoints in accessible typography? I need this for chapter 3.

---

## Step 1 — Find candidate pages via `index.md`

The assistant reads `index.md` first and identifies likely-relevant pages:

- `topics/typography` — the main topic node
- `topics/low-vision` — the audience-specific topic
- `topics/web-standards` — newer, contains the spec story
- `sources/videos/2025-09-14-variable-fonts-accessibility` — Whitman, has a strong anti-breakpoints stance
- `sources/articles/2024-03-responsive-typography-best-practices` — pro-breakpoints incumbent advice
- `sources/articles/2024-11-context-not-class` — newer article that may bear on this

Six pages. The assistant reads them.

---

## Step 2 — The answer (in the chat)

**Assistant:**

Short version: **your vault leans anti-breakpoints for accessibility, but the strongest pro-breakpoints argument is performance, not legibility.** Here's how the case breaks down.

**For device-class breakpoints (performance angle):**
- Smaller bundle sizes per device class. Mobile users don't ship the desktop font weights. See [[sources/articles/2024-03-responsive-typography-best-practices]] §4 — claims 20–30 % bundle reduction at the cost of one extra request.
- Predictable rendering. Designers can review three layouts (mobile / tablet / desktop) instead of N permutations. This is a *workflow* argument, not a *user* argument — worth noting in your chapter.

**Against (accessibility angle, which is the one your vault accumulates):**
- **No device class predicts visual ability.** This is Whitman's headline claim — [[sources/videos/2025-09-14-variable-fonts-accessibility]] line 587. A 65-year-old on a flagship phone needs the same tuning options as a teenager on a budget laptop.
- **Variable fonts dissolve the "ship N font files" problem** that motivated breakpoints in the first place. Same source, different argument: claims 1 and 4.
- **Context-not-class** — [[sources/articles/2024-11-context-not-class]] reframes the problem: don't classify the *device*, classify the *reading context* (driving / focused / glance). Stronger predictive power for accessibility outcomes.
- Your topic page [[topics/low-vision]] already notes that prescribed defaults consistently underperform user-controlled axes (Carter 2023, Whitman 2025, two more I see in the page).

**What's missing in your vault:**
- A quantitative comparison of bundle-size vs. user-tuning latency. The pro-breakpoints camp's strongest empirical claim is performance; you have no source that measures whether variable-font axes actually cause perceived latency on low-end devices. **This is a research gap.** Worth filling before chapter 3 final draft.

---

## Step 3 — The decision point

**Assistant:** This synthesis is reusable for your chapter and may come up again. Should I save it as a wiki page?

**Maya:** ja — save as a comparison page under topics.

---

## Step 4 — The new page

> Writes `topics/typography/breakpoints-vs-axes.md` (note the sub-page convention — the parent topic exists, this is an extension):

```yaml
---
typ: topic
status: active
sources-count: 3
last-updated: 2026-05-04
tags: [typography, accessibility, comparison, chapter-3]
---

# Device-class breakpoints vs. user-controlled axes (accessibility lens)

A comparison synthesised from three sources in this vault, written for chapter 3 of the thesis.

## The question

When designing accessible typography for the web, should we (a) ship per-device-class font files behind responsive breakpoints, or (b) ship a single variable font and let the user tune it?

## The case for breakpoints

[Body lifted from the answer above, ~3 paragraphs.]

## The case against

[Body lifted from the answer above, ~3 paragraphs.]

## Open gaps in this vault

- **Quantitative comparison of bundle-size vs. user-tuning latency.** No source measures perceived latency on low-end devices. Research gap to fill before final draft.

## Sources used in this synthesis

- [[sources/articles/2024-03-responsive-typography-best-practices]]
- [[sources/videos/2025-09-14-variable-fonts-accessibility]]
- [[sources/articles/2024-11-context-not-class]]

## Related

- [[topics/typography]]
- [[topics/low-vision]]
- [[topics/web-standards]]
```

---

## Step 5 — Index + log

> Adds under "Topics" in `index.md`:
> ```
> - [[topics/typography/breakpoints-vs-axes]] — comparison for chapter 3 of the thesis
> ```
>
> Appends to `log.md`:
> ```
> ## [2026-05-04 17:08] query | "case for/against device-class breakpoints in accessible typography"
>
> Sources consulted: 3. New synthesis saved as topics/typography/breakpoints-vs-axes.md.
> Identified one research gap: quantitative bundle-vs-tuning-latency comparison.
> Filed as task tasks/research/measure-variable-font-latency-low-end.md (priority medium).
> ```
>
> Also creates the follow-up task automatically since the gap was specific.

---

## What you should take from this

1. **Index-first search beats grep.** The assistant read 6 candidate pages by following `index.md`, not by grepping the whole vault. At ~80 pages this is faster *and* more accurate (catches semantically related pages that a literal grep would miss).
2. **Citations use wikilinks, not URLs.** Quoting `[[sources/articles/2024-11-context-not-class]]` is durable; quoting a URL is not. Click-throughs go to your vault page first; from there the URL is one click away in the frontmatter.
3. **Reusable answers become pages.** A one-off question stays in the chat. A synthesis that you'll cite in a thesis chapter becomes `topics/typography/breakpoints-vs-axes.md`. The assistant asks before saving — never write to the wiki silently in a query workflow.
4. **Gaps surface as tasks.** "What's missing in your vault" isn't an academic observation — it's a research lead. The assistant filed it as a task so it doesn't get lost.
