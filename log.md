# Log

Append-only operations log for this vault.

Every workflow run writes an entry here. Format:

```
## [YYYY-MM-DD HH:MM] <type> | <short description>
<2–3 lines of detail: affected files, ggf. open question>
```

`<type>` ∈ `{capture, triage, ingest, query, lint, refactor, init}`.

Greppable: real entries all start with `## [2` (year prefix), so `grep "^## \[2" log.md | tail -10` shows the last 10 operations.

**When to write an entry:**

- Every **triage** run (one entry, listing the inbox items handled).
- Every **ingest** (one entry per source).
- Every **lint** report (one entry referencing the lint file).
- Every **refactor** (one entry listing renamed / moved paths).
- A **query** only when the answer was saved back into the wiki as a new page.
- `init` is for the very first commit when the vault is brand new.

**Do NOT write here:**

- Generic schema lessons → those go in `docs/tool-evolution.md`.
- User-specific preferences → those go in `docs/personal-preferences.md`.
- Vault content problems → those go in the next lint report.

---

## [YYYY-MM-DD HH:MM] init | Sunday template initialised

Example entry showing the format. Replace this with your first real entry once you start using the vault.
