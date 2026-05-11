---
typ: project
area: <clients | work | personal | side-projects | ...>
client: "[[people/<firstname-lastname>]]"
status: active
deadline: <YYYY-MM-DD>
next-step: "<one concrete action that moves this forward>"
tags: []
---

# <Project title>

## Goal

<What does "done" look like? One paragraph.>

## Status

<Where are we right now?>

## Stakeholders

- Client / sponsor: [[people/<firstname-lastname>]]
- Others involved: …

## Tasks

```dataview
TABLE status, due, priority
FROM "tasks"
WHERE project = this.file.link
SORT priority ASC, due ASC
```

## Decisions log

- <YYYY-MM-DD> — <decision>, because <reason>

## Open questions

- <still unresolved>

## Notes

<Discussion, risks, links to assets, anything else worth keeping.>
