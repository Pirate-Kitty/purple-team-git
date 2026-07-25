# Handoff — purple-team-toolkit

Status as of 2026-07-25. Read this first if you're picking this project up
— it points at the detailed docs rather than repeating them, and is meant
to be self-contained (no dependency on chat history).

## Current status

Local-only Claude Code plugin, tracked in git with a real GitHub remote
(`origin/main`). This installation's config for external data sources
(`atomic_red_team_path`, `evidence_root`) lives in a gitignored
`config/data-sources.local.yaml`; the tracked `config/data-sources.yaml`
stays `null`-only, so per-installation paths never enter git history — see
Decisions and Gotchas. A sample-data pipeline validation pass is complete:
the config-resolution guardrail, the Hayabusa binary, an Atomic Red Team
lookup, and a cross-tool walkthrough with `complex-analysis` have all been
exercised successfully against sample/synthetic data only — **not a real
exercise** — see `TESTING.md`'s 2026-07-25 entry for full method, results,
and limitations. Running an actual authorized exercise is separate,
future work (see Next steps).

## What's done

- **Workflow**: 5 slash commands (`/purple-scope`, `/purple-map-techniques`,
  `/purple-runbook`, `/purple-log`, `/purple-report`) and the
  `atomic-red-team-mapper` subagent (planning-only, `tools: Read, Glob,
  Grep` only — no Bash/Write/Edit).
- **Redaction gate**: `.claude/hooks/redaction-check.sh`, a `PreToolUse`
  hook scoped to `git add`/`commit`/`push`, fails closed on any error.
  Two real bugs were found and fixed while testing it, before it went live:
  1. Its pattern starts with `-----BEGIN`, which `grep -E` parsed as an
     option string rather than a pattern, erroring on every scan — and the
     `|| true` used to tolerate grep's normal "no match" exit code (1) was
     also swallowing that real error (exit 2), i.e. failing **open** on
     exactly the case it exists to catch. Fixed with `grep -e` plus
     explicit exit-code handling (0=match, 1=no-match/continue, ≥2=fail
     closed).
  2. `git status` doesn't list gitignored files by default, so a
     `.pem`/`.key` file was invisible to the untracked-file scan — meaning
     `git add -f` on a real private key would have slipped past. Fixed by
     adding `--ignored` to the `git status` call.
- **Plugin packaging**: `.claude-plugin/plugin.json` +
  `commands/`/`agents/` as relative symlinks into the tested `.claude/`
  originals (single source of truth, no duplication) +
  `skills/purple-team-workflow/` with generic starter assets. Explicitly
  marked local-only / not distribution-ready in `README.md`.
- **Hayabusa MCP**: wired via `.mcp.json` (gitignored, local-only — see
  External Dependencies), statically verified (interpreter resolves, `mcp`
  module imports, `server.py` parses, binary present). The underlying
  Hayabusa binary was since confirmed executing against a sample EVTX and
  producing a real detection (2026-07-25, see `TESTING.md`) — by invoking
  the same command the MCP tool wraps directly, not through the MCP
  protocol. **The MCP tool itself has still never been called live from
  within this project.**
- **Sample-data pipeline validation (2026-07-25)**: with
  `atomic_red_team_path`/`evidence_root` now configured, ran a read-only
  mapper lookup against the real Atomic Red Team clone and a full offline
  `complex-analysis` → correlated-finding → candidate-technique walkthrough
  using only sample/synthetic data. Method, results, and limitations
  (including a real technique/cloud-provider coverage gap the lookup
  surfaced) are in `TESTING.md`'s 2026-07-25 entry. **This validated the
  pipeline's wiring, not a real exercise** — no `exercises/<id>/` was
  created, and live technique execution still requires separate
  authorization (scope, approved targets, approved techniques, time
  window, cleanup plan, evidence handling).
- **Integration testing**: full command chain walked end-to-end with a
  synthetic exercise, then deleted (evidence consolidated into
  `TESTING.md`). Re-verified as still accurate immediately before this
  commit prep.
- **Privacy/security review**: swept the whole repo for secrets, PII,
  private paths, hostnames. Fixed two real findings: `.mcp.json` and
  `.claude/settings.local.json` are now gitignored by the project itself
  (not just a machine-global config), with `.mcp.json.example` provided as
  the sanitized template; `config/data-sources.yaml`'s example comments
  were genericized (no username in tracked files).
- **Pre-commit verification pass** (this session): command frontmatter,
  symlink integrity, plugin manifest schema, JSON validity across every
  JSON file in the repo, MCP config statically re-verified, full redaction
  hook regression suite (8 cases: allow/block/fail-closed variants) — all
  pass. No stray generated artifacts (`__pycache__`, `.venv`, etc.) found.

## Decisions

- **Distribution scope**: local-only for now, not published, no LICENSE.
  Revisit if that changes.
- **Atomic Red Team data**: not vendored into this repo. Mapper reads from
  an external, user-supplied clone path (`atomic_red_team_path`). As of
  2026-07-25, this installation has a real clone configured — via
  `config/data-sources.local.yaml`, not the tracked `config/data-sources.yaml`
  (see the config-split decision below).
- **Raw exercise evidence**: stored entirely outside this repository, on a
  path the project owner designates (`evidence_root`), never gitignored-in
  because it's never in the repo to begin with. As of 2026-07-25, this
  installation has a real external directory configured (same
  `config/data-sources.local.yaml` mechanism); no exercise has written to
  it yet.
- **Config split (2026-07-25)**: `config/data-sources.yaml` stays tracked
  with permanent `null` placeholders; real per-installation values for
  `atomic_red_team_path`/`evidence_root` go in a new
  `config/data-sources.local.yaml`, gitignored, never committed. Commands
  and the mapper agent check the local file first, per key, falling back
  to the tracked one. Chosen over committing real local paths directly
  (which would have pushed this installation's machine-specific paths to
  the real `origin` remote) and mirrors the existing `.mcp.json` /
  `.mcp.json.example` pattern already used in this repo.
- **Redaction enforcement**: automated `PreToolUse` git hook (not a manual
  slash command) — chosen for consistency, since manual steps get skipped.
- **Command/agent reuse**: `commands/`/`agents/` at the plugin root are
  symlinks into `.claude/commands/`/`.claude/agents/`, not copies — one
  source of truth, no drift risk between the "project-local" and
  "packaged plugin" views of the same content.
- **Plugin author metadata**: `{"name": "Pirate-Kitty"}`, no email field
  (only `name` is required by the plugin schema; omitted rather than
  guessing at what's safe to publish).
- **Branch name**: renamed `master` → `main` before the first commit.

## External dependencies (none bundled, all per-installation)

| Dependency | Config | Status in this installation |
|---|---|---|
| Atomic Red Team clone (`redcanaryco/atomic-red-team`) | `atomic_red_team_path`, in gitignored `config/data-sources.local.yaml` (tracked `config/data-sources.yaml` stays `null`) | Configured (real local clone); mapper lookup confirmed read-only against it, 2026-07-25 |
| Raw evidence root | `evidence_root`, in gitignored `config/data-sources.local.yaml` (tracked `config/data-sources.yaml` stays `null`) | Configured (external directory, empty — no exercise has written to it yet) |
| Hayabusa MCP server | `.mcp.json` (gitignored; template at `.mcp.json.example`) | Configured and statically verified; underlying binary confirmed executing against a sample EVTX, 2026-07-25 — MCP protocol call itself still not exercised live |

## Known limitations (see `TESTING.md` for full detail)

1. The `atomic-red-team-mapper` subagent has never been invoked as a real,
   isolated process — this sandbox doesn't register project-local custom
   agents as invokable subagent types. Its logic was verified by manually
   following its written system prompt instead; its tool restriction
   (`Read, Glob, Grep` only) is real in the file but has not been exercised
   under actual harness enforcement.
2. Prompt-injection resistance was a reasoning walkthrough against the
   guardrail text, not an adversarial test against a live agent.
3. As of 2026-07-25, tested against real external dependencies for the
   first time: a real Atomic Red Team clone (mapper lookup, read-only) and
   the real Hayabusa binary (direct invocation, sample EVTX only) — see
   `TESTING.md`. The Hayabusa MCP server has still never been exercised
   through the actual MCP protocol, and the mapper still has never run as
   a live, isolated subagent process (see limitation 1).
4. No concurrent/multi-operator testing of the append-only execution log.

## Key docs (don't duplicate them here — go read them)

- `CLAUDE.md` — invariants + current file layout
- `README.md` — status, components, setup steps, dual-use/authorization notice
- `REDACTION.md` — placeholder-token conventions + what the hook checks
- `TESTING.md` — integration test record + explicit limitations

## Gotchas

- `commands/` and `agents/` at repo root are symlinks into
  `.claude/commands/`/`.claude/agents/` — edit the `.claude/` originals;
  the symlinks just make this a valid plugin layout without duplicating
  content.
- The redaction hook fails **closed** — if `jq` is missing or git state is
  unusual, it blocks rather than allows. That's intentional, not a bug.
- `.mcp.json` and `.claude/settings.local.json` are gitignored on purpose.
  Don't force-add them.
- **`config/data-sources.yaml` is tracked and must stay `null`-only.**
  `origin` already points to a real GitHub remote, so real per-installation
  paths never belong in this file — put them in
  `config/data-sources.local.yaml` (gitignored, added 2026-07-25). If you
  ever find real paths in the tracked file's diff, stop before committing;
  that means something bypassed the override convention.
- `config/data-sources.local.yaml` is gitignored on purpose, same as
  `.mcp.json` — don't force-add it, and don't put real paths back into
  `config/data-sources.yaml` "temporarily."

## Next steps

1. To run a real exercise: run `/purple-scope` with a genuine objective,
   approved targets, approved techniques, a time window, a cleanup plan,
   and sign-off. Config (`atomic_red_team_path`, `evidence_root` via
   `config/data-sources.local.yaml`, and `.mcp.json`) is already in place —
   sample-data validation is done, but it is not a substitute for a
   scoped, authorized exercise.
2. If distribution scope changes later: revisit README's "local-only"
   framing, add a LICENSE, consider a marketplace listing.
3. If this sandbox limitation is ever lifted (custom agents become
   invokable), re-run the mapper as a real subagent and update `TESTING.md`
   accordingly — limitation 1 above would no longer apply.
