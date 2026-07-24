---
description: Scope a new purple-team exercise — capture objective, authorized targets, out-of-scope list, time window, and sign-off before anything else can proceed.
---

## Your Task

Interview the user to scope a new purple-team exercise, then write the scope
files. Do not proceed to technique mapping, runbooks, or execution guidance in
this command — scoping only.

1. **Determine the exercise id.** Ask the user for a short slug (e.g.
   `2026-07-24-acmecorp`) if not given. Create `exercises/<id>/`.

2. **Collect required fields** (do not accept the exercise as scoped until all
   are present):
   - Objective / threat scenario being emulated
   - Authorized targets: hosts, accounts, networks, environments (use
     placeholder tokens from `REDACTION.md` if the user pastes real
     hostnames/IPs into the conversation — ask them to confirm the
     placeholder mapping is tracked safely on their side, not in this repo)
   - Explicit out-of-scope: hosts, techniques, or actions that must NOT be run
   - Authorized time window (start/end)
   - Approval / sign-off (who authorized this, and how — reference a ticket
     or doc, don't paste the authorization document itself)
   - Emergency-stop contact

3. **Write `exercises/<id>/scope.md`** with the above, using placeholder
   tokens per `REDACTION.md` for any real hostname/account/credential the
   user provides.

4. **Write `exercises/<id>/metadata.yaml`**:
   ```yaml
   id: <id>
   status: scoped
   created: <date>
   evidence_path: null  # to be set once the user confirms the external evidence root
   ```

5. Tell the user the exercise is scoped and that `/purple-map-techniques` is
   the next step — it will refuse to run without a complete `scope.md`.

## Guardrails

- Never write real credentials, API keys, or private-key material into
  `scope.md` — if the user pastes one, replace it with `<REDACTED-CRED>` and
  tell them you did.
- If any required field is missing, stop and ask — do not fill in a
  placeholder objective or invented authorization.
