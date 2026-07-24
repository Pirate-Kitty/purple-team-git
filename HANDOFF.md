# Handoff — purple-team-toolkit

Status as of 2026-07-24, immediately before the first commit. Read this
first if you're picking this project up — it points at the detailed docs
rather than repeating them, and is meant to be self-contained (no
dependency on chat history).

## Current status

Local-only Claude Code plugin. Branch renamed from the git default
(`master`) to `main`. Packaging, integrated testing, documentation, and the
privacy/security review are all complete and re-verified. **Nothing has
been staged, committed, tagged, or pushed yet** — this repo has zero
commits as of this writing; staging the first commit is pending explicit
approval from the project owner.

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
  module imports, `server.py` parses, binary present) but **never started
  or exercised live**.
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
  an external, user-supplied clone path (`config/data-sources.yaml` →
  `atomic_red_team_path`), left `null` — not installed yet.
- **Raw exercise evidence**: stored entirely outside this repository, on a
  path the project owner designates (`evidence_root`), never gitignored-in
  because it's never in the repo to begin with.
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
| Atomic Red Team clone (`redcanaryco/atomic-red-team`) | `config/data-sources.yaml` → `atomic_red_team_path` | Unset (`null`) — not installed |
| Raw evidence root | `config/data-sources.yaml` → `evidence_root` | Unset (`null`) |
| Hayabusa MCP server | `.mcp.json` (gitignored; template at `.mcp.json.example`) | Configured and statically verified, never run live |

## Known limitations (see `TESTING.md` for full detail)

1. The `atomic-red-team-mapper` subagent has never been invoked as a real,
   isolated process — this sandbox doesn't register project-local custom
   agents as invokable subagent types. Its logic was verified by manually
   following its written system prompt instead; its tool restriction
   (`Read, Glob, Grep` only) is real in the file but has not been exercised
   under actual harness enforcement.
2. Prompt-injection resistance was a reasoning walkthrough against the
   guardrail text, not an adversarial test against a live agent.
3. Never tested against real external dependencies (real ART data, a
   running Hayabusa MCP server) — only a synthetic fixture and static
   checks.
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

## Next steps

1. First commit, pending explicit approval (see git status/file list
   provided alongside this document at handoff time).
2. To run a real exercise: set `atomic_red_team_path`, set
   `evidence_root`, copy `.mcp.json.example` → `.mcp.json` with a real path.
3. If distribution scope changes later: revisit README's "local-only"
   framing, add a LICENSE, consider a marketplace listing.
4. If this sandbox limitation is ever lifted (custom agents become
   invokable), re-run the mapper as a real subagent and update `TESTING.md`
   accordingly — limitation 1 above would no longer apply.
