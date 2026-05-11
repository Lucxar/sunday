# Sources

Wiki pages for ingested external material — videos, articles, podcasts, books. The page is a **summary + crosslinks**, not a copy of the source.

Path: `sources/<type>/<YYYY-MM-DD-kebab-title>.md`
- `sources/videos/`
- `sources/articles/`
- `sources/podcasts/`
- `sources/books/` (create on demand)

The raw transcript or article text lives in `raw/<type>/<slug>/` and is immutable. The source wiki page quotes the raw material with line references so you can always trace claims back.

Frontmatter and body skeleton: see `docs/templates/source.md`. Format reference: `CLAUDE.md → Frontmatter conventions → Source`.

Walkthrough: `docs/examples/02-ingesting-a-video.md`.
