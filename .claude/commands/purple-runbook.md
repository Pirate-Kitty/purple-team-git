---
description: Turn an approved technique-map into an ordered, human-executed runbook with approval checkpoints — this command does not execute anything itself.
---

## Your Task

1. **Require a mapped exercise.** Read `exercises/<id>/technique-map.md` and
   `exercises/<id>/scope.md`. If the technique map doesn't exist, tell the
   user to run `/purple-map-techniques` first.

2. **Confirm human review happened.** Ask the user to confirm they've
   reviewed the technique map and approve which candidate tests to include
   (not all candidates need to make it into the runbook).

3. **Write `exercises/<id>/runbook.md`** as an ordered sequence, one section
   per approved test:
   - Pre-checks (dependencies, target state, backups/snapshots if relevant)
   - The exact command to be run (copied from the technique map, not
     reworded) and who runs it
   - **An explicit approval checkpoint** before this step — the runbook
     records that a human signed off on this specific step during the
     authorized time window, it does not grant that approval itself
   - Expected telemetry / what detection should fire
   - Cleanup/rollback command (flag prominently if the atomic test has none)

4. Update `exercises/<id>/metadata.yaml` status to `runbook-ready`.

5. State plainly to the user: **this command produces a document, not an
   action** — no command in the runbook is executed by Claude Code. Execution
   is manual, by a human operator, logged afterward via `/purple-log`.

## Guardrails

- Do not reorder or bundle steps in a way that removes an approval checkpoint.
- If a test has no cleanup/cleanup_command, the runbook must say so explicitly
  rather than omitting the field.
- If the technique map flagged a technique/test as out-of-scope, it must not
  appear in the runbook.
