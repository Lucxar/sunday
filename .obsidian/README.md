# .obsidian

Minimal Obsidian config shipped with Sunday.

## What's committed

- `core-plugins.json` — built-in Obsidian plugins enabled by default. Sensible defaults (file explorer, graph view, backlinks, properties, tag pane, daily notes, templates).
- `community-plugins.json` — community plugins that should be enabled once installed. Currently just `dataview`.
- `app.json` — empty placeholder so Obsidian recognises the folder as configured.

## What is NOT committed

Per `.gitignore` at the repo root:

- `workspace.json`, `workspace-mobile.json` — per-machine pane layout. Regenerated when you open the vault.
- `graph.json` — graph-view visual state. Regenerated.
- `cache` — Obsidian's per-machine cache.

The graph view (`graph.json`) is regenerated automatically by Obsidian on first open — there's nothing to commit.

## First-time setup

1. Open this folder as an Obsidian vault.
2. Obsidian will say "this vault uses community plugins" — accept.
3. Settings → Community plugins → Browse → search "Dataview" → Install → Enable.
4. Reload (`Ctrl+R`) — Dataview blocks in `index.md` and topic pages should now render.
