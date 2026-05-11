---
typ: topic
status: active
sources-count: 0
last-updated: <YYYY-MM-DD>
tags: []
---

# <Topic>

## What this is about

<2–3 sentences defining the topic and what it does *not* cover (so future ingests stay on-topic).>

## Core ideas

- <central claim 1>
- <central claim 2>

## Open questions

- <not yet answered>

## Contradictions across sources

> [!warning] Source A says X, source B says Y — open question, see [[sources/...]] and [[sources/...]]

## Sources

```dataview
TABLE source-type, author, published
FROM "sources"
WHERE contains(topics, this.file.link)
SORT published DESC
```

## Related topics

- [[topics/<related>]]
- [[topics/<related>]]
