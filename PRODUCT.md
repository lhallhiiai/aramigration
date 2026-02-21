# ARA — Product Owner Requirements for MVP

Generated: 2026-02-21

This document lists every decision that the product owner must make before the
corresponding frontend or backend feature can be built. Each item states exactly
what is known from the user guide, what is missing, and the minimum answer needed
to unblock development.

Items are grouped into two tiers:

- **Tier 1 — Must resolve before MVP launch** — the workflow cannot function without these answers
- **Tier 2 — Can simplify or defer for MVP** — a reasonable default exists, but confirmation is needed

---

## Tier 1 — Must Resolve Before MVP Launch

---

### Q1 — What are the questions on the PM tab?

**What the guide says:**
> "Questions only apply to ARA amounts greater than $50K."
> The PM fills out questions on the ARA Summary screen before Sign & Submit.

**What is missing:**
The guide never lists the questions. The form cannot be built without knowing what
to display.

**What we need:**

Provide a complete list of every question that appears on the PM tab, using this format:

| Question text | Data type | Required? | Shown when amount > $50K only? |
|---|---|---|---|
| Example: Is this work within the original scope? | Yes/No | Yes | Yes |
| Example: Provide justification | Free text (max chars?) | Yes | Yes |

At least one example per data type that exists in the system (Yes/No, dropdown,
free text, numeric, date).

**Blocks:** PM tab form fields in the frontend; PM section storage in the database.

---

### Q2 — What are the questions on the CA tab?

**What the guide says:**
> "The CA is to answer all questions." (Figure 24)

**What is missing:**
The guide never lists the CA questions. The form cannot be built without knowing
what to display.

**What we need:**

Provide a complete list of every question that appears on the CA tab, using the
same format as Q1. Also indicate:

- Are the CA questions the same set as the PM questions, or a different set?
- Are any CA questions suppressed below $50K?

**Blocks:** CA tab form fields in the frontend; CA section storage in the database.

---

### Q3 — What are the Approval & Threshold Matrix tiers?

**What the guide says:**
> "ARA automatically forwards email alerts to the appropriate users to review
> entries based on the Approval and Threshold Matrix (Figure 7)."
> "An approved ARA will be queued to the next approver for action based on the
> Approval & Threshold Matrix."

**What is missing:**
The guide references Figure 7 (a screenshot that is no longer available) but
never states the dollar thresholds, the roles required at each tier, or how many
approvers each tier requires.

**What we need:**

Provide the complete Approval & Threshold Matrix in this format:

| Tier | ARA Amount Range | Required Approver Role(s) | Number of approvers |
|---|---|---|---|
| 1 | $0 – $X | Role name | 1 |
| 2 | $X – $Y | Role name | 1 |
| 3 | > $Y | Role name | 2 |

Also answer:
- Are the approvers named individuals, or are they determined by system role?
- If named individuals: where are they configured? (System Information page?)
- Is there a situation where zero approvers are required (auto-approved)?

**Blocks:** Approval routing engine in `AraService.ApproveAsync`; approval routing
on every ARA submission from the Controller stage.

---

### Q4 — Do approvers act sequentially or simultaneously?

**What the guide says:**
> "An approved ARA will be queued to the next approver for action."
> The guide references "the next approver" but never states whether multiple
> approvers at the same tier act one at a time or all at once.

**What is missing:**
The routing model (sequential vs. parallel) determines the entire approval engine
architecture.

**What we need — choose one:**

- **Sequential:** Each approver sees the ARA only after the previous approver has
  approved. The ARA moves forward when the last approver in the tier approves.
- **Parallel:** All required approvers for a tier are notified simultaneously. The
  ARA moves forward when all of them have approved.
- **Other:** Describe the rule.

Also answer:
- If sequential: in what order do approvers act? (by role seniority? by
  configuration on the matrix?)
- What happens if one approver rejects while others have already approved?

**Blocks:** Same as Q3 — approval engine architecture.

---

### Q5 — What are the Controller fields Interest Impact and Expected Burn Rate?

**What the guide says:**
> "The Controller will need to complete the following fields and save the form:
> Company, Interest Impact, Expected Burn Rate, Incurred Costs, Incurred Fee."

**What is missing:**
Neither field is defined anywhere in the guide or glossary. The Controller form
cannot be built without knowing their meaning, data type, and validation rules.

**What we need — for each field:**

| Field | Data type | Unit | Required? | Min | Max | Description / calculation source |
|---|---|---|---|---|---|---|
| Interest Impact | ? | ? | ? | ? | ? | ? |
| Expected Burn Rate | ? | ? | ? | ? | ? | ? |

Examples of data types: dollar amount, percentage, free text, date, integer.

**Blocks:** Controller tab form fields in the frontend and backend DTO/SP.

---

### Q6 — How does the Revision field work on rejection?

**What the guide says:**
> "The Status and Revision change prior to (Figure 42) and after rejection
> (Figure 43)."

**What is missing:**
The guide confirms Revision changes on rejection but never states the starting
value, increment rule, or whether it ever resets.

**What we need — answer all four:**

1. What value does Revision start at when an ARA is first created? (0 or 1?)
2. How much does Revision increment on each rejection? (always +1?)
3. Does Revision ever reset? (e.g., after final approval? or never?)
4. Is Revision displayed to users on the ARA list, the ARA detail page, or both?

**Blocks:** `AraService.RejectAsync` increment logic; Revision display in the
frontend ARA list and detail views.

---

### Q7 — What is the expected expiration date and what triggers the Expired status?

**What the guide says:**
> "The Dashboard displays critical ARA expirations by expected expiration dates."
> "If a contract modification is never received from the customer, the ARA will
> remain 'Expired'."

**What is missing:**
The guide never states how the expected expiration date is set, who sets it,
or what transitions an ARA to Expired status.

**What we need — answer all three:**

1. **Who sets the expiration date?**
   - PM enters it during ARA creation?
   - System calculates it from the risk category and contract dates?
   - Admin sets it after approval?

2. **What is the expiration date based on?**
   If calculated: what is the formula? (e.g., 90 days after approval?
   based on contract period of performance end date?)

3. **What triggers the Expired status transition?**
   - A nightly scheduled job that compares today to the expiration date?
   - A manual admin action?
   - Something else?

**Blocks:** Expiration date field on ARA creation form; Dashboard expiration view;
scheduled expiration job (if applicable).

---

### Q8 — Is "Contract Manager" on Step 2 the same role as "Contract Administrator"?

**What the guide says:**
> Non-Early Start Step 2: "The Creator may select the Contract Manager and
> Controller from the drop-down menus." (Figure 14)
> All other references in the guide use "Contract Administrator."

**What is missing:**
It is unclear whether "Contract Manager" in Step 2 is a display label for the
same Contract Administrator role, or a separate person/role.

**What we need — choose one:**

- **Same role:** "Contract Manager" in Step 2 is just a label; the selected person
  IS the Contract Administrator who will review the ARA. Use one consistent label
  throughout (which one?).
- **Different roles:** "Contract Manager" is a distinct role or person separate
  from the Contract Administrator. Describe what the Contract Manager does and
  how they differ from the Contract Administrator.

**Blocks:** Step 2 UI label and the role assignment model in ARA creation.

---

### Q9 — Can the CA submit an Early Start ARA without uploading documents?

**What the guide says:**

The guide describes two CA action lists for Early Start:

Before document upload (Figure 27):
> Save / Upload Documents / Reject (Submit for Next Approval is NOT listed)

After document upload (Figure 29):
> Save / Upload Documents / Submit for Next Approval / Reject

But the guide also states:
> "Supporting documentation is not required for Early Starts."

**What is missing:**
If documentation is not required, it is unclear whether Submit becomes available
only after uploading at least one optional document, or immediately after Save,
or always.

**What we need — choose one:**

- **Submit always available after Save** (regardless of document upload): Early
  Start CAs can submit as soon as they save, without ever uploading a document.
- **Submit available only after at least one document is uploaded** (even though
  it's optional): Early Start CAs must upload at least one document to unlock Submit,
  but the document itself is described as optional (the guide is inconsistent).
- **Other:** Describe the intended rule.

**Blocks:** CA tab action button logic for Early Start ARAs.

---

## Tier 2 — Can Simplify for MVP (Confirm or Override Defaults)

These items have a sensible default that can ship. Flag a correction if the
default is wrong, otherwise the team will proceed with the stated assumption.

---

### Q10 — Export to JAMIS process

**What the guide says:**
> ARA can reach Exported status. Negation is only possible on Exported ARAs.

**What is missing:**
The export mechanism is not described at all — no endpoint, no trigger, no data format.

**MVP default we will build:**
A manual "Export to JAMIS" button visible to Admins on a fully Approved ARA.
Clicking it transitions the ARA to Exported status. No actual JAMIS API call is
made — the status change is the only action. Real JAMIS integration will be wired
in a follow-up once the JAMIS API details are available.

**Confirm or correct:**
- Is a manual Export button acceptable for MVP? If not, describe the trigger.
- Is there a JAMIS API we can call? If so, provide the endpoint, authentication
  method, and payload format.
- Which role(s) can trigger Export? (Admin only? Automatic?)

---

### Q11 — Delegation configuration

**What the guide says:**
> "ARA System Information page displays system-level configuration including
> delegations." (Figure 6)

**What is missing:**
The guide does not explain what can be delegated, who can configure it, or how
it affects workflow routing.

**MVP default we will build:**
The Delegations section on the System Information page will display as a
placeholder ("Delegation configuration coming soon") for the initial release.
No delegation functionality will be built until the rules are defined.

**Confirm or correct:**
- Is delegation required for MVP? If yes, answer all three:
  1. What can be delegated? (PM approval rights? Approver rights? Specific workflow steps?)
  2. Who configures delegations? (Admin? Each user for their own role?)
  3. How does an active delegation affect routing? (The delegate receives the task instead of
     the original assignee? Both receive it?)

---

### Q12 — OMS Number format and validation

**What the guide says:**
> The OMS Number field autocompletes from OMS data for Early Start ARAs.

**What is missing:**
No format constraint, minimum length, or error message guidance is provided.
Live OMS integration is also not yet possible (no API access).

**MVP default we will build:**
The OMS Number field will accept free-text input up to 50 characters with no
format validation. OMS autocomplete will be stubbed out (field accepts manual
entry). Real OMS validation will be added when API access is available.

**Confirm or correct:**
- Is there a known OMS Number format or pattern? (e.g., all numeric, prefix like
  "OMS-", minimum 6 digits?)
- What error message should appear if the OMS Number does not match a live OMS record?
- Is manual entry acceptable for MVP while OMS integration is pending?

---

### Q13 — Document upload limits

**What the guide says:**
> "Must accept PDF format only."
> One PDF can satisfy multiple requirements; multiple PDFs can satisfy one requirement.

**What is missing:**
No maximum file size or maximum number of uploads per stage is stated.

**MVP default we will build:**
- Maximum file size: **25 MB per PDF**
- Maximum files per stage: **20 PDFs**
- File type: PDF only (enforced client-side and server-side)

**Confirm or correct:**
- Are these limits acceptable? If not, provide the correct values.
- Are the limits different per stage (CA vs Controller)?

---

## Summary — Decision Priority for MVP

| # | Question | Tier | Blocks |
|---|---|---|---|
| Q1 | PM tab questions | 1 | PM form, DB schema |
| Q2 | CA tab questions | 1 | CA form, DB schema |
| Q3 | Approval threshold matrix | 1 | Approval routing engine |
| Q4 | Sequential vs parallel approvers | 1 | Approval routing engine |
| Q5 | Interest Impact and Expected Burn Rate | 1 | Controller form |
| Q6 | Revision field behavior | 1 | Rejection logic, ARA list display |
| Q7 | Expiration date source and Expired trigger | 1 | ARA creation, Dashboard |
| Q8 | Contract Manager vs Contract Administrator | 1 | Step 2 UI label, role model |
| Q9 | Early Start CA Submit availability | 1 | CA tab button logic |
| Q10 | Export to JAMIS process | 2 | Export feature (deferrable) |
| Q11 | Delegation rules | 2 | System Information page (deferrable) |
| Q12 | OMS Number format | 2 | Early Start creation form |
| Q13 | Document upload limits | 2 | Upload component validation |

**Recommended session order:** Answer Q1 and Q2 first (questions unblock the
largest UI surface area — the entire PM and CA tabs). Then Q3 and Q4 together
(approval routing). Then Q5 through Q9 in any order.
