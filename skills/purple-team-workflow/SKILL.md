---
name: purple-team-workflow
description: Use this skill when scoping, mapping, running, or reporting on a purple-team exercise with the purple-team-toolkit plugin's commands (/purple-scope, /purple-map-techniques, /purple-runbook, /purple-log, /purple-report) and the atomic-red-team-mapper agent. Also use it when setting up a new installation of this plugin to scaffold exercise folders or configure external data sources.
version: 0.1.0
---

# Purple Team Workflow

## Overview

This plugin drives a purple-team engagement end to end: scope, map ATT&CK
techniques to candidate Atomic Red Team tests, generate a human-executed
runbook, log execution and detection results, and produce an after-action
report. See the plugin's `commands/` for the step-by-step workflow and
`agents/atomic-red-team-mapper.md` for the mapping subagent's contract.

## Invariants (see this project's CLAUDE.md for the authoritative copy)

- No exercise proceeds past scoping without an explicit objective,
  authorized targets, out-of-scope list, time window, and sign-off.
- The mapper agent never executes anything — planning only, human review
  required before any command is run.
- Real evidence (logs, screenshots, pcaps) and real exercise data are never
  bundled with this plugin — they live outside the plugin, per-installation.

## Setting up a new installation

Two external data sources are configured per-installation, not bundled with
the plugin (see `assets/data-sources.yaml.example`):

1. A local clone of `redcanaryco/atomic-red-team`, for the mapper agent to
   read from.
2. An external evidence root, outside any git repository, for raw exercise
   artifacts.

Copy `assets/data-sources.yaml.example` to your project's
`config/data-sources.yaml` and leave both paths `null` — the commands and
agent will tell you what's missing rather than guessing. Put your real,
per-installation paths in `config/data-sources.local.yaml` instead
(gitignored, never committed); commands and the mapper agent check that
file first and fall back to `config/data-sources.yaml` for anything it
doesn't set. This keeps real local paths out of git history entirely.

## Assets

- `assets/after-action-report.md` — generic after-action report template
- `assets/exercise-folder.md` — describes the per-exercise file layout
- `assets/data-sources.yaml.example` — starter config, no real paths
