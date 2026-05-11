# Tasks

One file per task that needs structured metadata (due date, priority, project link). Lightweight per-project to-dos can live as checkbox lists inside the project page itself.

Path: `tasks/<area>/<kebab-title>.md`

Standalone tasks (no project link) are allowed and common — "renew passport", "book dentist". Just leave the `project` field out.

Frontmatter and body skeleton: see `docs/templates/task.md`. Format reference: `CLAUDE.md → Frontmatter conventions → Task`.

The Dataview blocks in `index.md` give you "open tasks", "high-priority tasks", "tasks due this week" automatically. You don't maintain those lists by hand.
