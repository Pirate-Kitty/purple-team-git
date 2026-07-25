---
description: Translate a detection question into SIEM query syntax for manual execution, then analyze human-provided results and map them to ATT&CK — no live SIEM connection exists or is ever claimed.
---

## Your Task

1. **Require a runbook-ready exercise.** Ask which `exercises/<id>/` this is
   for. Read `exercises/<id>/scope.md`, `exercises/<id>/technique-map.md`, and
   `exercises/<id>/runbook.md`. If any of these three is missing, stop and
   tell the user which prerequisite command to run first (`/purple-scope`,
   `/purple-map-techniques`, or `/purple-runbook`, in that order) — do not
   proceed.

2. **Identify the technique/test to validate.** Ask which technique or test
   id (matching `runbook.md`) this query is for. Pull its "expected
   telemetry" from `runbook.md` and its safety notes from `technique-map.md`
   as context.

3. **Check for a prior execution-log entry.** Look in
   `exercises/<id>/execution-log.md` for an entry matching this technique/test
   id. If none exists, warn the user plainly — there is no record this test
   was actually run yet — and ask whether they want to (a) proceed anyway
   (e.g. validating steady-state/historical coverage, or a baseline query)
   or (b) stop and run `/purple-log` first. Do not proceed silently either
   way.

4. **Ask the detection question in plain language.** E.g. "what would tell us
   this technique fired" — don't assume `runbook.md`'s expected telemetry
   fully specifies it; let the user refine or narrow it.

5. **Ask which SIEM product this query is for, every invocation** — never
   assume or default to one, and never default to Sigma:
   - Splunk (SPL)
   - Elastic (KQL/EQL)
   - Microsoft Sentinel (KQL)
   - Other/generic — generate a best-effort generic boolean/field-match
     pseudo-query and label it clearly as pseudo-syntax needing adaptation to
     the user's actual platform.

6. **Generate the query** in the chosen syntax. Alongside it, state
   explicitly:
   - The expected data source/index/table (infer from the runbook's expected
     telemetry and the technique; say so plainly if inferring rather than
     quoting a known source).
   - The time scope to search — default to the exercise's authorized window
     from `scope.md`, narrowed around the matching execution-log entry's
     timestamp if one exists.
   - **That no live SIEM connection exists.** This query is for the user to
     run manually in their own SIEM. Ask them to paste or import the results
     back here when ready.

7. **Stop and wait.** Do not analyze, estimate, or fabricate results. Do not
   proceed past this point until the user has actually provided result data.

8. **Analyze the provided results**, once given:
   - Determine detected / missed / partial for this technique/test, based
     only on what was actually provided.
   - Map the finding to the ATT&CK technique id from `technique-map.md`.
   - Write investigation notes: what the data shows, anomalies, false-positive
     risk, anything inconclusive.
   - Propose follow-up actions: tune a rule, close a gap, escalate, or no
     action needed.

9. **Write the results** — only once the full cycle (query generated →
   results provided → analysis complete) has finished:
   - **Append** one row to `exercises/<id>/detections.md`: technique/test id,
     detected / missed / partial, one-line note — matching the file's
     existing schema exactly.
   - **Append** a full entry to `exercises/<id>/detection-validations.md`
     (create the file with a header if it doesn't exist yet): timestamp,
     technique/test id, SIEM product, the query used, expected data
     source/time scope, a summary of results, ATT&CK mapping, investigation
     notes, follow-up actions.

10. Tell the user this now feeds `/purple-report`'s Detection Coverage
    section.

## Guardrails

- **Never claim or imply a live SIEM connection exists.** This command only
  generates query syntax and analyzes human-provided results — it has no
  SIEM integration of any kind.
- **Never fabricate results.** If no results have been provided, do not
  proceed past step 6 — do not guess, estimate, or infer what a query
  "probably" returns.
- Do not default to a specific SIEM product or to Sigma — ask, every
  invocation.
- Apply `REDACTION.md` placeholder tokens to any real hostname/account/IP
  appearing in the generated query, the results summary, or the
  investigation notes.
- Do not paste raw log excerpts into `detections.md` or
  `detection-validations.md` — summarize and reference the external
  evidence path (`evidence_root`) instead.
- Append-only: never edit or overwrite a prior entry in `detections.md` or
  `detection-validations.md`.
- If the technique/test has no matching `execution-log.md` entry, warn
  explicitly before proceeding — do not silently validate against nothing.
