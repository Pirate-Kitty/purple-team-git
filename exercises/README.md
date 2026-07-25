# Exercises

Each purple-team engagement gets its own `exercises/<exercise-id>/` folder,
created by `/purple-scope`. No real exercise exists yet — this describes the
structure the commands will produce.

| File | Created by | Contents |
|---|---|---|
| `metadata.yaml` | `/purple-scope` | id, status, dates, `evidence_path` pointer (external, see `config/data-sources.yaml`) |
| `scope.md` | `/purple-scope` | objective, authorized targets/out-of-scope, time window, sign-off, emergency-stop contact |
| `technique-map.md` | `/purple-map-techniques` | atomic-red-team-mapper output: technique → candidate test(s) → safety notes |
| `runbook.md` | `/purple-runbook` | ordered human-executed steps with approval checkpoints |
| `execution-log.md` | `/purple-log` | append-only record of what was actually run |
| `detections.md` | `/purple-log`, `/query` | detected / missed / partial per technique/test |
| `detection-validations.md` | `/query` | full SIEM-validation entries: query used, SIEM product, expected data source/time scope, results summary, ATT&CK mapping, investigation notes, follow-up actions |

Raw evidence (logs, screenshots, pcaps) is never stored here — see
`REDACTION.md` and `config/data-sources.yaml`.
