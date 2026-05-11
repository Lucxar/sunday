# Walkthrough: ingesting a video

Maya has been keeping up with talks from the *Web Accessibility Day 2025* conference. She wants to ingest a 28-minute keynote: "Variable Fonts as an Accessibility Tool" by Dr. Sara Whitman.

This walkthrough shows the **full ingest** — download, summary, source page, every topic touched, the log entry, the commit. Pay attention to how many pages the single ingest updates (rule of thumb: 5–15 pages).

---

## Step 0 — Maya hands the URL over

**Maya:** ingest https://www.youtube.com/watch?v=EXAMPLE-VIDEO-ID

**Assistant:** OK. Running the `video-fetch-and-summarize` skill. Will report back when raw material is in place.

---

## Step 1 — Raw material on disk

After ~4 minutes (download + Whisper transcription + first-pass summary):

```
raw/videos/2025-09-14-variable-fonts-accessibility/
  transcript.md         ← full transcript, line-numbered
  summary.md            ← 1-page summary from the skill
  meta.json             ← {url, author, published, ingested, duration}
```

**`meta.json`:**
```json
{
  "url": "https://www.youtube.com/watch?v=EXAMPLE-VIDEO-ID",
  "author": "Dr. Sara Whitman",
  "published": "2025-09-14",
  "ingested": "2026-05-04",
  "duration": "00:28:14",
  "venue": "Web Accessibility Day 2025"
}
```

**Assistant:** Raw material is in place. Reading the transcript and identifying the key claims now. I see roughly 5 main claims and references to 3 prior topics in the vault: `typography`, `low-vision`, and `web-standards`. Two of those already exist; `web-standards` doesn't. Should I create the new topic page during this ingest, or want to defer it?

**Maya:** create it.

---

## Step 2 — The source page

> Writes `sources/videos/2025-09-14-variable-fonts-accessibility.md`:

```yaml
---
typ: source
source-type: video
url: https://www.youtube.com/watch?v=EXAMPLE-VIDEO-ID
author: "Dr. Sara Whitman"
published: 2025-09-14
ingested: 2026-05-04
topics: ["[[topics/typography]]", "[[topics/low-vision]]", "[[topics/web-standards]]"]
tags: [variable-fonts, conference-talk, accessibility-day]
---

# Variable Fonts as an Accessibility Tool

## TL;DR

- Variable fonts give designers a single resource that can be tuned (weight, optical size, x-height) per user preference instead of shipping multiple static fonts.
- Browser support reached "production-grade" in late 2023; the remaining gap is design tooling, not runtime.
- User-controlled font axes (via CSS custom properties) outperform server-side device detection because no device class predicts visual ability.
- Optical-size axes specifically help low-vision readers more than weight axes do.
- The case study (a German news site) saw 8% longer reading sessions after enabling per-reader font tuning.

## Why this matters

Most current accessibility tooling in CSS treats text as static. Whitman's argument is that variable fonts shift the locus of control from designer to reader, which aligns with the rest of accessibility doctrine (user agency > prescribed defaults). This is a structural argument, not just a feature pitch — relevant for chapter 3 of the thesis where I'm making the same point about colour.

## Key claims

### Claim 1: Optical-size axes matter more than weight axes for low-vision readers

> "We thought boosting weight would carry the load. Two studies later — it was optical size that mattered, by a wide margin." (`raw/videos/.../transcript.md` line 412.)

### Claim 2: User-controlled axes beat device-class detection

> "There is no device class that predicts visual ability. A 65-year-old on a flagship phone needs the same tuning options as a teenager on a budget laptop." (line 587)

This **contradicts** the conventional advice in [[sources/articles/2024-03-responsive-typography-best-practices]] which still recommends device-class breakpoints. Flagged below.

### Claim 3: The German news case study

> "Reading session length up 8 % over 6 weeks. Bounce rate down 3 %." (line 932)

I'm including this because Maya's thesis chapter 4 needs a quantitative anchor — this study is a candidate.

### Claim 4: Browser support is no longer the bottleneck

(See line 1104 — CanIUse-style breakdown by browser version. Not reproducing here; raw is the source of truth.)

### Claim 5: Design tooling lags

> "The hard part now is convincing Figma and Sketch to make variable axes first-class." (line 1233)

## Bearing on topics

- [[topics/typography]] — adds variable fonts as a recognised "accessibility lever" alongside contrast, spacing, x-height. New synthesis paragraph added there.
- [[topics/low-vision]] — adds the optical-size-over-weight finding. Updates the "what helps" list.
- [[topics/web-standards]] — new topic. Variable-font CSS spec landed in 2023; current adoption status.

## Contradictions / controversy

> [!warning] Contradicts [[sources/articles/2024-03-responsive-typography-best-practices]] on device-class breakpoints — Whitman argues no device class predicts visual ability; the older article still recommends them. Open question for chapter 3.

## My take

Credible — the case study is small but the methodology is reproducible (logs + opt-in surveys). I want to cite claims 1 and 3 directly in chapter 3 and 4 respectively. Worth following up with Whitman if she'll share the raw data behind the case study.

## Raw

- Transcript: `raw/videos/2025-09-14-variable-fonts-accessibility/transcript.md`
- Summary: `raw/videos/2025-09-14-variable-fonts-accessibility/summary.md`
- Meta: `raw/videos/2025-09-14-variable-fonts-accessibility/meta.json`
```

---

## Step 3 — Updating affected topics

### `topics/typography.md`

> Was at `sources-count: 11`. The assistant adds a new paragraph in "Core ideas":
>
> > Variable fonts (since ~2018, browser-supported since 2023) shift type tuning from designer to reader. Optical-size axes specifically benefit low-vision readers more than weight axes do — see [[sources/videos/2025-09-14-variable-fonts-accessibility]].
>
> Bumps `sources-count: 12`, `last-updated: 2026-05-04`.

### `topics/low-vision.md`

> Adds a bullet to "What helps":
>
> > - Optical-size axes in variable fonts (Whitman 2025, [[sources/videos/2025-09-14-variable-fonts-accessibility]]). Stronger effect than weight axes.
>
> Bumps `sources-count` from 7 to 8, `last-updated: 2026-05-04`.
>
> Adds a contradiction callout:
>
> > [!warning] Open: [[sources/videos/2025-09-14-variable-fonts-accessibility]] says no device class predicts visual ability — contradicts [[sources/articles/2024-03-responsive-typography-best-practices]] on responsive-breakpoint best practice. Decide before chapter 3 final draft.

### `topics/web-standards.md` (new)

> Writes a new topic page with frontmatter (`status: active`, `sources-count: 1`, `last-updated: 2026-05-04`) and a first paragraph setting scope: "the standards / spec process for typography, accessibility, layout".

---

## Step 4 — Index updates

> Edits `index.md`:
> - Adds the new video under "Sources → Videos".
> - Adds `[[topics/web-standards]]` under "Topics" (with a one-liner: "Standards & spec processes for typography, accessibility, layout").
> - Re-runs the "Hottest topics" Dataview block in the editor — `typography` is now at 12 sources, surfaces higher.

---

## Step 5 — Log entry

> Appends to `log.md`:

```
## [2026-05-04 14:22] ingest | Whitman: Variable Fonts as an Accessibility Tool (video, 28 min)

Source page: sources/videos/2025-09-14-variable-fonts-accessibility.md
Topics updated: topics/typography (now 12 sources), topics/low-vision (now 8)
New topic: topics/web-standards (first source)
Contradiction flagged: device-class typography breakpoints (Whitman vs. responsive-typography-best-practices). Surface in next lint.
Index updated. 7 wiki pages touched in total.
```

---

## Step 6 — Commit

> Stages explicit paths only:
>
> ```
> git add sources/videos/2025-09-14-variable-fonts-accessibility.md
> git add topics/typography.md topics/low-vision.md topics/web-standards.md
> git add index.md log.md
> git add raw/videos/2025-09-14-variable-fonts-accessibility/
> git commit -m "ingest: Whitman, Variable Fonts as an Accessibility Tool (2025-09-14)"
> git push
> ```

---

## What you should take from this

1. **One ingest touched 7 wiki pages** (1 new source + 3 topics + index + log + 1 task carry-over not shown). That's normal — if you ingest something and only one page changes, you almost certainly missed a topic crosslink.
2. **Contradictions are flagged inline, not silently merged.** The Whitman ↔ responsive-typography-best-practices conflict goes into the topic page as a `> [!warning]` callout AND into the next lint report. Both signals exist so the contradiction doesn't disappear.
3. **The raw transcript is the citation anchor.** Every claim in the source page has a `transcript.md line XXX` reference. If you later doubt a claim, you can verify in seconds.
4. **`git add -A` would have included `.claude/` and `.obsidian/workspace.json`.** That's why the explicit-path discipline matters — the staging command lists 6 paths, no more, no less.
