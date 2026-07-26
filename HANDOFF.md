# Handoff — purple-team-toolkit

Status as of 2026-07-25. Read this first if you're picking this project up
— it points at the detailed docs rather than repeating them, and is meant
to be self-contained (no dependency on chat history).

## Executive Summary

This is a Claude Code plugin that runs a purple-team engagement from
scoping through after-action reporting — objective and technique intake,
ATT&CK-to-Atomic-Red-Team mapping, human-executed runbooks, append-only
execution logging, and report assembly — with a fail-closed redaction gate
in front of every git write. It is functionally complete and has been
validated end-to-end against sample and synthetic data only, including
live calls through the actual Hayabusa MCP protocol and a live,
harness-enforced invocation of the technique-mapping subagent. **No live
Atomic Red Team technique execution and no real-target exercise has been
performed under this project.** Running one is separate, future,
authorization-gated work — see Next steps.

## Technical Summary

Five slash commands (`/purple-scope` → `/purple-map-techniques` →
`/purple-runbook` → `/purple-log` → `/purple-report`) drive the workflow,
backed by a planning-only `atomic-red-team-mapper` subagent restricted to
`Read`/`Glob`/`Grep` (no Bash/Write/Edit — it cannot execute anything). A
`PreToolUse` hook (`.claude/hooks/redaction-check.sh`) gates every
`git add`/`commit`/`push` repo-wide and fails closed. External dependencies
(an Atomic Red Team clone, a Hayabusa MCP server, and a raw evidence root)
are all per-installation and never vendored or committed — see External
dependencies below. All of it, including the MCP tool itself and the
mapper subagent as a real harness-enforced process, has now been exercised
live, not just statically. Full detail: What's done, Decisions, External
dependencies.

## Coverage & Gap Findings

- **Real finding, still open**: the 2026-07-25 sample-data validation
  derived two candidate ATT&CK techniques from a correlated finding and
  looked both up against the real Atomic Red Team clone. One technique had
  no test specific to the cloud provider involved — only tests for other
  providers exist in the local data. This is a genuine local data-coverage
  gap, not a tooling bug; closing it means sourcing or writing a test for
  that provider, or documenting it as an accepted gap in a real exercise's
  report.
- **Redaction hook coverage is intentionally narrow, not exhaustive**: it
  matches five pattern categories (PEM private-key headers, AWS access-key
  IDs, `password=`/`api_key=`/`secret=`-style assignments, RFC1918 IPs). Per
  `REDACTION.md`, it is a backstop, not the primary control — the primary
  control is that real secrets/evidence never enter the repo to begin with.
  It will not catch other credential formats (other cloud providers' key
  formats, JWTs, generic tokens) or PII beyond what those five patterns
  happen to match.
- **Minor pre-existing terminology mismatch, not fixed**: `purple-log.md`
  and `/query` both write `detected/missed/partial` to `detections.md`, while
  `reporting/templates/after-action-report.md`'s Detection Coverage table
  uses `Yes/No/Partial` wording. Same three-state meaning, cosmetic only —
  left unreconciled since fixing it means editing the report template,
  which is out of scope for the `/query` addition.

## Validation Record

Full method/results/limitations live in `TESTING.md`; this is an index:

- **2026-07-24** — full command chain walked end-to-end with a synthetic
  exercise (deleted after, consolidated here); gate ordering, mapper
  match/exclusion/no-fabrication behavior, runbook generation, append-only
  logging, report assembly, and redaction-hook regression all verified.
- **2026-07-25, sample-data pipeline validation** — config unblock
  confirmed; Hayabusa binary run directly against a sample EVTX (real
  detection); a full offline `complex-analysis` walkthrough against sample
  fixtures producing one correlated finding plus a confirmed negative
  control; a mapper lookup against the real Atomic Red Team clone
  (surfacing the coverage gap above).
- **2026-07-25, live-invocation validation** —
  `mcp__hayabusa-mcp__scan_evtx` called live through the actual MCP
  protocol (same result as the direct binary run); `atomic-red-team-mapper`
  invoked as a real, harness-enforced subagent against the real ART clone,
  with its tool restriction holding under actual enforcement.
- **2026-07-25, `/query` validation** — command discovery, scoped-exercise
  enforcement, per-invocation SIEM selection, query generation,
  pause-for-results behavior, ATT&CK mapping, and append-only documentation
  output all verified against synthetic fixtures, by manual walkthrough and
  by live `Skill` invocation. Tested in manual mode only, using
  sanitized/synthetic data — not against a live SIEM.

## Current status

Tracked in git and pushed to a public GitHub remote
(`origin/main`, `github.com/Pirate-Kitty/purple-team-git`). "Local-only"
below describes the plugin's installation model (no marketplace listing,
no LICENSE, not intended for others to install yet) — it does not mean
the repository is unpushed or private; it is neither. This installation's
config for external data sources
(`atomic_red_team_path`, `evidence_root`) lives in a gitignored
`config/data-sources.local.yaml`; the tracked `config/data-sources.yaml`
stays `null`-only, so per-installation paths never enter git history — see
Decisions and Gotchas. A sample-data pipeline validation pass is complete:
the config-resolution guardrail, the Hayabusa binary, an Atomic Red Team
lookup, and a cross-tool walkthrough with `complex-analysis` have all been
exercised successfully against sample/synthetic data only. The two
remaining live-invocation gaps from that pass have since been closed: the
Hayabusa MCP tool has been called live through its actual protocol, and
the `atomic-red-team-mapper` subagent has been invoked as a real,
harness-enforced process. **None of this constitutes a real exercise** —
see `TESTING.md`'s 2026-07-25 entries for full method, results, and
limitations. Running an actual authorized exercise is separate, future
work (see Next steps).

## What's done

- **Workflow**: 5 slash commands (`/purple-scope`, `/purple-map-techniques`,
  `/purple-runbook`, `/purple-log`, `/purple-report`) and the
  `atomic-red-team-mapper` subagent (planning-only, `tools: Read, Glob,
  Grep` only — no Bash/Write/Edit).
- **`/query` (SIEM-validation command, added 2026-07-25)**: a sixth command,
  deliberately breaking the `purple-` naming convention. Translates a
  detection question into SIEM query syntax (Splunk/Elastic/Sentinel/generic,
  asked per-invocation, never assumed or defaulted) for **manual execution
  only** — no live SIEM connection exists or is ever claimed. Stops and waits
  for human-provided results before analyzing anything; writes a
  `detected/missed/partial` row to `detections.md` plus a fuller entry
  (query used, SIEM product, data source/time scope, results summary, ATT&CK
  mapping, investigation notes, follow-up actions) to the new
  `detection-validations.md`. Tested in manual mode only, using
  sanitized/synthetic data — not against a live SIEM (see Known
  limitations).
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
  Hayabusa binary was confirmed executing against a sample EVTX and
  producing a real detection (2026-07-25, see `TESTING.md`) by invoking the
  same command directly, and separately, `mcp__hayabusa-mcp__scan_evtx`
  was called live through the actual MCP protocol against the same sample
  EVTX, returning the same finding (2026-07-25, see `TESTING.md`).
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
  `TESTING.md`).
- **Privacy/security review**: swept the whole repo for secrets, PII,
  private paths, hostnames. Fixed two real findings: `.mcp.json` and
  `.claude/settings.local.json` are now gitignored by the project itself
  (not just a machine-global config), with `.mcp.json.example` provided as
  the sanitized template; `config/data-sources.yaml`'s example comments
  were genericized (no username in tracked files).
- **Pre-commit verification pass**: command frontmatter, symlink integrity,
  plugin manifest schema, JSON validity across every JSON file in the repo,
  MCP config statically re-verified, full redaction hook regression suite
  (8 cases: allow/block/fail-closed variants) — all pass. No stray generated
  artifacts (`__pycache__`, `.venv`, etc.) found.

## Cross-project validation: CTI correlation scenario shape

Scenario shape and negative-control detail from the sample-data validation
above (full result in `TESTING.md`):

- **Scenario shape**: the correlated finding traced a suspicious host-side
  call-out (a command-line tool spawned from a shell, connecting outbound)
  to a cloud storage read from the same source IP shortly after — i.e. a
  minimal call-out-then-cloud-data-access pattern tied together by one
  shared indicator. Candidate reference shape if a future exercise wants
  something a host+cloud correlation pipeline should be able to catch.
- **Negative control confirmed**: the sample data included two additional
  host events and two additional cloud events that deliberately do *not*
  share an indicator with anything else. The pipeline correctly left them
  uncorrelated — confirms it isn't over-matching on unrelated activity,
  not just that it can find a planted match.
- **Limitations**: heuristic/no behavioral correlation, deterministic-matching
  only — no LLM reasoning exercised, single indicator/single hop, one
  cloud-provider event shape, no live feed involved (see `TESTING.md`).

## Decisions

- **Distribution scope**: the repository is public and pushed (`origin/main`
  on GitHub), but the *plugin* is not distribution-ready — no LICENSE, no
  marketplace listing, not intended for anyone else to install yet. Revisit
  if that changes.
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
| `complex-analysis` sibling project (threat-intel/correlation CLI) | `complex_analysis_path`, in gitignored `config/data-sources.local.yaml` (tracked `config/data-sources.yaml` stays `null`) | Configured, path-only connection — no code shared or vendored. Not read by any purple-team command yet; its own `cti` CLI (`cti ingest-ti`/`cti analyze-endpoint`/`cti analyze-cloud`/`cti correlate`) is the documented launch interface for manual cross-tool workflows. Re-validated against its own sample fixtures, 2026-07-25 |
| Hayabusa MCP server | `.mcp.json` (gitignored; template at `.mcp.json.example`) | Configured and verified end-to-end: underlying binary confirmed against a sample EVTX, and the MCP tool itself (`scan_evtx`) called live and returning the same result, 2026-07-25 |

## Known limitations (see `TESTING.md` for full detail)

1. Prompt-injection resistance against the `atomic-red-team-mapper`
   subagent has one live data point (a single live invocation that
   correctly treated an embedded "this is validation only" framing as
   context, not instruction), not a full adversarial test suite.
2. No concurrent/multi-operator testing of the append-only execution log.
3. `/query` was tested in manual mode with sanitized/synthetic data only —
   not against a live SIEM.

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
3. Test `/query` against a real SIEM product once one is available and
   authorized — current validation is manual-mode only, using sanitized
   data.
4. Run a dedicated adversarial prompt-injection test against the live
   mapper subagent, if deeper assurance is wanted beyond the single data
   point recorded in Known limitations.
