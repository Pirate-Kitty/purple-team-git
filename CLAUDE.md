# Purple Team Workflow

This project drives purple-team engagements end to end: scoping, ATT&CK
technique-to-atomic-test mapping, runbook generation, execution logging, and
after-action reporting.

## Invariants

- **Scope first.** No exercise proceeds past `/purple-scope` until
  `exercises/<id>/scope.md` has an explicit objective, authorized
  targets/accounts, out-of-scope list, time window, and sign-off.
- **The mapper never executes.** `atomic-red-team-mapper` produces a
  candidate list of atomic tests for human review. It has no Bash, Write, or
  Edit tools — it cannot run or stage anything. All execution is manual, by a
  human, following the runbook.
- **Never fabricate offensive content.** The mapper must never invent a test
  ID, GUID, or command. If no match exists in the referenced Atomic Red Team
  data, it says so.
- **No real evidence in this repo.** Raw logs, screenshots, and pcaps live on
  an external path outside this repository (see `config/data-sources.yaml`).
  Exercise folders reference that path; they never contain the data itself.
- **Redaction gate before any `git add`/`commit`/`push`, repo-wide** (not
  just `exercises/`/`reporting/`). See `REDACTION.md`.

## Layout

Packaged as a local-only Claude Code plugin (`purple-team-toolkit`, not
distribution-ready — see `README.md`). `commands/` and `agents/` at the
project root are relative symlinks into `.claude/commands/` and
`.claude/agents/`, so there is one source of truth for their content, editable
from either path.

- `.claude-plugin/plugin.json` — plugin manifest
- `commands/` (symlinks) / `.claude/commands/` (real files) — slash commands
  driving the workflow
- `agents/` (symlink) / `.claude/agents/` (real file) — the
  atomic-red-team-mapper subagent
- `skills/purple-team-workflow/` — workflow overview + generic starter
  templates for other installations (not this project's live data)
- `.claude/hooks/redaction-check.sh` + `.claude/settings.json` —
  project-local pre-commit redaction gate (not part of the portable plugin)
- `.mcp.json` — this installation's external MCP server wiring
  (machine-specific, gitignored, not part of the portable plugin); the
  tracked template is `.mcp.json.example`
- `exercises/<id>/` — one folder per engagement (scope, technique-map,
  runbook, execution-log, detections)
- `reporting/` — report templates and generated after-action reports
- `config/data-sources.yaml` — this installation's external paths (ART data
  clone, evidence root)
- `TESTING.md` — integration test record + explicit limitations
- `HANDOFF.md` — project status, decisions, external dependencies, next steps
