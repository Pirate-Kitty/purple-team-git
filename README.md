# purple-team-toolkit

A Claude Code plugin/project driving purple-team engagements end to end:
scoping, MITRE ATT&CK-to-Atomic-Red-Team technique mapping, runbook
generation, execution logging, and after-action reporting.

## Status

**Local-only. Not distribution-ready.** This has not been published to any
marketplace, is not installed from a Git remote, and is not intended to be
installed by anyone outside this local checkout yet. Treat everything here
as a working project, not a released package.

## Authorization / dual-use notice

This toolkit helps plan and document purple-team exercises. It maps
objectives to candidate Atomic Red Team tests and produces human-readable
runbooks and reports — **it does not execute anything itself.** All
technique execution is manual, by an authorized human operator, against
explicitly authorized targets, within an explicitly authorized time window.
Every exercise must be scoped (`/purple-scope`) with sign-off before any
mapping, runbook, or logging step proceeds. Do not use this against systems
or accounts you are not explicitly authorized to test.

## Components

- `commands/` — `/purple-scope`, `/purple-map-techniques`, `/purple-runbook`,
  `/purple-log`, `/purple-report` (symlinked to `.claude/commands/`, the
  tested source of truth)
- `agents/atomic-red-team-mapper.md` — planning-only technique-to-test
  mapping subagent, no execution capability (symlinked to `.claude/agents/`)
- `skills/purple-team-workflow/` — workflow overview and generic starter
  templates for other installations
- `.claude/hooks/redaction-check.sh` — repo-wide pre-commit secrets/PII/
  hostname gate, fails closed on error (project-local, not part of the
  portable plugin content)

## Setup (this installation)

1. `config/data-sources.yaml` (tracked) ships with `null` placeholders, as
   designed — real values for this installation (`atomic_red_team_path`,
   a local `redcanaryco/atomic-red-team` clone, and `evidence_root`, an
   external non-repo path for raw exercise evidence) live in
   `config/data-sources.local.yaml` instead, gitignored and never
   committed. Commands and the mapper agent check the local override file
   first and fall back to the tracked one for anything it doesn't set.
2. Detection validation (optional): `.mcp.json` is configured for this
   installation, pointing at a local Hayabusa MCP server clone. `.mcp.json`
   is gitignored — it's local, machine-specific config, never committed.
3. Sample-data validation of this configuration is complete — see
   `TESTING.md`'s 2026-07-25 entry for exactly what was and wasn't
   exercised. **This is not a real exercise.**
4. Run `/purple-scope` to start a real exercise. It requires its own
   explicit scope, sign-off, approved targets/techniques, a time window,
   and a cleanup plan before any mapping, runbook, or logging step
   proceeds.

## Documentation

- `CLAUDE.md` — invariants + file layout
- `REDACTION.md` — placeholder-token conventions + what the redaction hook checks
- `TESTING.md` — integration test record, including explicit test-rigor limitations
- `HANDOFF.md` — current project status, what's done/open, gotchas, next steps

## What's NOT bundled with the plugin, by design

- Real exercise data (`exercises/<id>/`) and generated reports
  (`reporting/<id>/`)
- This installation's `.mcp.json` (machine-specific external server path)
- This installation's `config/data-sources.local.yaml` (real paths for this
  deployment; `config/data-sources.yaml` itself is bundled but always ships
  with `null` placeholders)
- The redaction hook and its `.claude/settings.json` registration
  (project-local security control, not a distributable feature)
