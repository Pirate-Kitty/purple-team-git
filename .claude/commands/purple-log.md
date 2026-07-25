---
description: Append an execution/detection log entry for a purple-team exercise — after a human has actually run a runbook step.
---

## Your Task

1. Ask which `exercises/<id>/` this is for, and confirm `runbook.md` exists.

2. Collect for this entry: timestamp, technique/test id (matching the
   runbook), operator name, what was actually run (may differ from the
   runbook — record deviations explicitly), result/outcome, and whether the
   expected detection fired (yes / no / partial).

3. **Append** (never overwrite or edit prior entries) to
   `exercises/<id>/execution-log.md`.

4. **Append** the detection outcome to `exercises/<id>/detections.md`, one row
   per technique/test: detected / missed / partial, with a one-line note.

5. If the user has raw evidence (log excerpt, screenshot) for this entry, do
   **not** paste it into these files — ask them to store it under the
   external evidence root (`evidence_root` from `config/data-sources.local.yaml`
   if that file exists, else `config/data-sources.yaml`) and record only the
   relative path/filename reference here.

## Guardrails

- Append-only: never rewrite history in `execution-log.md`.
- Apply `REDACTION.md` placeholder tokens to any real hostname/account/IP
  before writing.
- Do not accept raw log/credential content into these files — redirect to the
  external evidence path.
