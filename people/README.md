# People

Clients, colleagues, friends, family, service providers, co-founders, creators you follow.

Path: `people/<firstname-lastname>.md`

If the surname is unknown, use a working slug like `people/<firstname-context-tbd>.md` with a `#name-missing` tag. The lint pass will surface these for you to fix.

Frontmatter and body skeleton: see `docs/templates/person.md`. Format reference: `CLAUDE.md → Frontmatter conventions → Person`.

People pages auto-populate a "their projects" Dataview block from the `client` field on project pages — you don't need to hand-maintain the list.
