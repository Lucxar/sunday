# Inbox

Everything unstructured lands here. No rules for what you can throw in.

## How to use it

- **One note per file:** `YYYY-MM-DD-HHMM-keyword.md` (Obsidian's "New note" hotkey is fast).
- **Or one scratch file:** open `scratch.md` and write freely — the assistant splits it on triage.
- **Bare URLs:** also fine, just paste them as a line in `scratch.md` or a one-line `.md`.
- **Voice notes:** if you run the Telegram-voice setup (`docs/setup/telegram-voice.md`), spoken messages are transcribed and dropped here.

## What happens next

When you say "triage", the assistant walks every file, asks you when something is ambiguous, writes the result to the correct place in the vault with full frontmatter, and deletes the inbox file. See `CLAUDE.md → Workflows → Triage` for the exact steps.

## What doesn't belong here

- Final wiki pages — the assistant writes those directly to their target folder.
- Files with frontmatter — they are already structured, they belong in the wiki.
- Anything you absolutely don't want forgotten — write that into a page or a task; the inbox is for fleeting capture, not memory.
