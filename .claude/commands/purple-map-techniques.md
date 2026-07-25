---
description: Map an exercise's objective/ATT&CK technique IDs to candidate Atomic Red Team tests via the atomic-red-team-mapper subagent — planning only, no execution.
---

## Your Task

1. **Require a scoped exercise.** Ask which `exercises/<id>/` this is for. Read
   `exercises/<id>/scope.md`. If it doesn't exist or is missing required
   fields (objective, authorized targets, out-of-scope, time window,
   sign-off), stop and tell the user to run `/purple-scope` first — do not
   proceed.

2. **Gather technique input.** From the scope's objective and any MITRE
   ATT&CK technique IDs the user supplies (or asks you to help derive from
   the scenario), assemble the request for the mapper.

3. **Invoke the `atomic-red-team-mapper` subagent** with:
   - The objective/scenario text
   - The technique ID list
   - Target platform(s) from scope
   - The out-of-scope list from `scope.md` (the mapper must exclude anything
     listed there)

4. **Write the subagent's output verbatim** to
   `exercises/<id>/technique-map.md` — do not paraphrase or "clean up" the
   commands it returns. Preserve its safety notes and its closing statement
   that this is planning only.

5. Update `exercises/<id>/metadata.yaml` status to `mapped`.

6. Tell the user the technique map needs human review before
   `/purple-runbook` turns it into an executable runbook.

## Guardrails

- Resolve `atomic_red_team_path` from `config/data-sources.local.yaml` if
  that file exists and sets it, else from `config/data-sources.yaml`. If
  neither has it set, tell the user the mapper has no data source
  configured yet and stop — do not let the subagent guess at or fabricate
  atomic test content.
- Never execute, stage, or offer to run any command the mapper returns —
  this command's job ends at writing the candidate list to a file.
