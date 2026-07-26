# purple-team-toolkit

A Claude Code plugin/project driving purple-team engagements end to end:
scoping, MITRE ATT&CK-to-Atomic-Red-Team technique mapping, runbook
generation, execution logging, and after-action reporting.

## Status

The repository is tracked in git and pushed to a public GitHub remote
(`origin/main`, `github.com/Pirate-Kitty/purple-team-git`) — see
`HANDOFF.md`'s Current status for the full checkpoint.

**The plugin itself is local-only and not distribution-ready.** That's
about the installation model, not whether the code is public: it has no
LICENSE, is not listed in any Claude Code plugin marketplace, and isn't
intended for anyone else to install as a plugin dependency yet. Treat it
as a working project whose source happens to be public, not a released,
supported package.

**No live Atomic Red Team technique execution or real-target exercise has
been performed using this project.** Everything validated so far — the
Hayabusa MCP integration, the Atomic Red Team lookup, the command chain —
has been exercised against sample and synthetic data only. See
`HANDOFF.md`'s Validation Record for exactly what has and hasn't been
exercised.

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
  `/purple-log`, `/purple-report`, `/query` (symlinked to `.claude/commands/`,
  the tested source of truth; `/query` intentionally breaks the `purple-`
  naming convention). `/query` generates manual SIEM query syntax from a
  detection question and validates human-provided results — no live SIEM
  connection.
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
   `TESTING.md` for exactly what was and wasn't exercised. **This is not a
   real exercise.**
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
