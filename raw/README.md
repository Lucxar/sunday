# Raw

**Immutable** original material for everything you ingest.

Structure:
```
raw/
  videos/<slug>/
    transcript.md
    summary.md
    meta.json
  articles/<slug>/
    content.md
    meta.json
  podcasts/<slug>/
    transcript.md
    summary.md
    meta.json
  books/<slug>/
    notes.md
    meta.json
  assets/                  ← downloaded images, PDFs, screenshots
```

`meta.json` typically holds `{url, author, published, ingested, duration?}`.

## Rules

- **Never modify raw files** after they are committed. If a transcript has errors, fix them by adding a footnote in the corresponding `sources/<type>/<slug>.md` wiki page — leave the raw as-is so you preserve a true record of what the source said.
- **Binary media (mp4, mp3, etc.) is gitignored** by default to keep the repo small. If you want to track media, configure Git LFS or move the binaries to external storage and link from `meta.json`.
- **Naming:** `<slug>` matches the wiki page slug exactly, so `sources/videos/2026-04-12-llm-training-explained.md` ↔ `raw/videos/2026-04-12-llm-training-explained/`. The assistant relies on this 1:1 mapping.
