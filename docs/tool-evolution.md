# Tool Evolution

**Public stream** of Sunday improvements. This is the file where **generic** patterns, architecture decisions, workflow refinements, and tool-limitation findings land — anything that would help any other Sunday user. If you fork Sunday and decide to publish your fork, this file ships with it.

**Does NOT belong here:** user-specific preferences, personal data, individual people/projects/appointments. That goes in `docs/personal-preferences.md` (gitignored).

## Entry format

```
## [YYYY-MM-DD HH:MM] <type> | <title>
**Tags:** #tag1 #tag2

### Problem / observation
<Generic problem in the tool, workflow, or schema. Free of user-specific details.>

### Approach / hypothesis
<Pattern or convention. Also generic.>

### Change
<Which files were improved generically.>

### Effect
<Observed effect after use.>

### Follow-up / open
<Open questions, further pattern ideas.>

---
```

**Types:** `problem | improvement | decision | effect | pattern | meta-init`

**Tags:** generic tool aspects — `#schema`, `#frontmatter`, `#dataview`, `#workflow`, `#triage`, `#ingest`, `#lint`, `#tooling`, `#mcp`, `#capture`, `#performance`, `#ux`, `#publish`, `#phase-2`, `#setup`.

## When does an entry land here

- A new schema pattern was introduced (e.g. "forward-looking conventions need their own file").
- A tool limitation was discovered (e.g. "Figma MCP rate-limit error message is misleading on Starter tier").
- A workflow refinement that affects all users (e.g. "the triage step should explicitly verify wikilink targets before writing").
- A convention for an external integration (e.g. "frontmatter fields for Google Calendar sync").
- A cross-stream observation: a pattern that shows up in multiple personal applications and reveals a generic user need.

**When an entry is both** (pattern + specific application): the pattern goes here, the specifics go in `docs/personal-preferences.md`, cross-reference both ways with wikilinks.

## What is NOT a tool-evolution entry

- Vault content problems → those belong in the next lint report.
- Routine operations → those belong in `log.md`.
- Concrete user tasks → those belong in `tasks/`.

---

## Entries

_(empty — write your own as Sunday teaches you things)_
