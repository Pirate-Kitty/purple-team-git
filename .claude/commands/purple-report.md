---
description: Assemble scope, technique-map, execution-log, and detections into an after-action report using the shared template.
---

## Your Task

1. Ask which `exercises/<id>/` this is for. Read `scope.md`,
   `technique-map.md`, `execution-log.md`, and `detections.md`.

2. Fill `reporting/templates/after-action-report.md`'s sections using only
   what's in those files:
   - Executive Summary
   - Scope & Objectives (from `scope.md`)
   - Techniques Tested (table: technique, test, result)
   - Detection Coverage (detected / missed / partial, from `detections.md`)
   - Findings & Gaps
   - Recommendations
   - Appendix — reference the external evidence path for raw artifacts;
     never inline raw log excerpts, screenshots, or credentials here

3. Write the result to `reporting/<id>/after-action-report.md`.

4. Update `exercises/<id>/metadata.yaml` status to `reported`.

5. **Before this report is committed or shared, remind the user to run the
   redaction check** (Phase 5 hook, or manual review if the hook isn't set up
   yet) — this is the point where an exercise's findings are most likely to
   leave the repo, so it's the highest-stakes checkpoint for any leftover
   real hostnames/credentials.

## Guardrails

- Do not copy raw evidence content into the report — path references only.
- If `execution-log.md` or `detections.md` is incomplete for a technique the
  scope says was authorized, call that out in Findings & Gaps rather than
  silently omitting it.
