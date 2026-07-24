# Redaction Conventions

Exercise and reporting files are meant to be tracked in git. Real evidence
(raw logs, screenshots, pcaps) is never stored in this repo — it lives on an
external path (see `config/data-sources.yaml`) and is referenced by path only.

Even so, curated notes (`scope.md`, `execution-log.md`, reports) can
accidentally pick up real values by hand. Use placeholder tokens from the
start instead of relying on catching them later:

| Sensitive value | Placeholder token |
|---|---|
| Target hostname / IP | `<TARGET-HOST-1>`, `<TARGET-IP-1>` |
| Internal hostname (non-target) | `<INTERNAL-HOST-1>` |
| Account / username used in a test | `<TEST-ACCOUNT-1>` |
| Credential / password / key material | `<REDACTED-CRED>` |
| Client / organization name | `<CLIENT>` (unless the exercise folder name already scopes it) |
| Raw log excerpt | Summarize + link to the external evidence path; do not paste the excerpt |

## Before any git add/commit/push

`.claude/hooks/redaction-check.sh`, registered as a `PreToolUse` hook in
`.claude/settings.json`, blocks any `git add`/`git commit`/`git push` —
repo-wide, not just `exercises/`/`reporting/` — if it detects likely
secrets or identifiers: private-key headers, `password=`/`api_key=`-shaped
strings, AWS-key-shaped strings, or RFC1918/internal-looking IPs not
already replaced with a placeholder token. It fails closed on any error
(unparseable input, git errors, not a repo). See `TESTING.md` for its test
record.

The hook is a backstop, not the primary control — the primary control is
writing placeholder tokens into these files in the first place, and never
storing raw evidence in the repo at all.
