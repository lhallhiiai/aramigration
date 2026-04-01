# ARA Modernization — Product Owner Questions

**Purpose:** The following questions must be answered before Phase 2 development
can begin. Each item maps to a specific build blocker. No assumption has been made
where the user guide is silent — we have stopped and flagged instead.

---

## Section 1 — Approval & Threshold Matrix

The user guide references the Approval & Threshold Matrix (Figure 7) as the
mechanism that drives all approval routing. However, the actual matrix data,
thresholds, and routing rules are not documented anywhere. This is the single
largest blocker for Phase 2.

**1.1 — Dollar thresholds**
What are the dollar amount thresholds that determine which approvers are required?
For example:
- $0–$50K → approver set A
- $50K–$250K → approver set B
- $250K+ → approver set C

Please provide the complete threshold table.

**1.2 — Approver roles per threshold band**
For each threshold band, which job titles are required to approve?
Please map each threshold band to the required job title(s) from the `JobTitle` table.

**1.3 — Sequential vs. parallel approval**
When multiple approvers are required for a single ARA, do they act:
- **Sequentially** — one at a time in a defined order, or
- **In parallel** — all notified at once, any one can approve?

**1.4 — Terminal approval condition**
What condition marks an ARA as fully approved and ready for export?
- Is it when the last approver in the chain approves?
- Is there a specific approver role whose approval is always final?
- Can a single approver satisfy all threshold requirements if they hold
  sufficient authority?

**1.5 — Risk category influence on routing**
Does the ARA risk category (Award Fees, Mod Pending, etc.) affect which
approvers are required, or is routing determined solely by dollar amount?

**1.6 — Division / Org influence on routing**
The legacy data has `Approve_grp`, `Approve_op`, and `Approve_div` on each
approver's user record. How do these fields constrain which ARAs an approver
is responsible for? Does an approver only see ARAs whose Division matches
their `Approve_grp`?

**1.7 — OpsVP approver**
The ARA record has an `OpsVpUserId` field. Is the Ops VP always an approver,
or only for certain threshold bands or risk categories? How is this user
selected — by the PM, or determined automatically by the matrix?

**1.8 — Delegation**
The System Information page shows a Delegations section. What can be delegated,
who can delegate, and how does a delegation affect the routing chain? For example,
if an approver delegates to another user, does the delegated user receive the
notification and take action instead?

---

## Section 2 — ARA Form Questions

The user guide states that questions appear on the PM and CA sections of the ARA
form, and that certain questions are suppressed when the ARA amount is $50,000
or less. However, the actual questions are never listed anywhere in the guide.

**2.1 — Complete question list**
Please provide the full list of questions that appear on the PM section of the
ARA form. For each question, specify:
- The question text (exactly as it should appear to the user)
- Whether it applies to amounts **over $50K only**, or to **all amounts**
- Whether it is **required** or optional
- The expected answer format (free text, yes/no, dropdown, etc.)

**2.2 — CA section questions**
The guide states "The CA is to answer all questions" (Figure 24, Non-Early Start).
Please provide the full list of questions that appear on the CA section. Same
format as above.

**2.3 — Early Start question differences**
Do the PM and CA questions differ between Early Start and Non-Early Start ARAs,
or are the same questions shown for both types?

**2.4 — $50K threshold applicability per question**
The guide states questions only apply to amounts greater than $50K, but it is
unclear whether this applies to all questions or only a subset. Please confirm
which specific questions are suppressed at or below $50K and which always appear.

---

## Section 3 — Approval Chain Behavior

**3.1 — Approver count**
What is the maximum number of sequential approvers an ARA can have? Is there a
fixed chain length, or does it vary by threshold and risk category?

**3.2 — Approval notification recipients**
When an approver approves, the guide says an email goes to "all users who have
taken action on the ARA" and to "the next approver." Does this include the PM,
CA, and Controller, or only prior approvers?

**3.3 — Rejection reason codes**
When an approver rejects, they must select a reason code. Please provide the
complete list of rejection reason codes and their display labels.

**3.4 — Rejection affected tab**
When an approver rejects, they select an "affected tab for focus of review
and resubmission." What are the valid tab options available for selection?
Are these the PM, CA, and Controller tabs, or are there more granular options?

**3.5 — Revision field behavior**
The guide notes (Figures 42–43) that the Revision field changes on rejection.
Please confirm:
- What is the initial Revision value when an ARA is first created? (0 or 1?)
- Does Revision increment by 1 on each rejection cycle?
- Is Revision displayed to users, and if so where?

**3.6 — Re-submission after rejection**
When a PM resubmits after a rejection, does the approval chain restart from
the beginning (PM → CA → Controller → Approver 1 → ...) with all sections
unlocked, or does it restart at the specific tab the approver flagged?

---

## Section 4 — JAMIS Export

The guide references "Exported" status and the ability to negate Exported ARAs,
but the export process itself is entirely absent from the documentation.

**4.1 — Export trigger**
What action or condition triggers an ARA to be exported to JAMIS?
- Is it automatic upon final approval?
- Does an admin or Controller manually initiate it?
- Is there a batch job that runs on a schedule?

**4.2 — Export data**
What data fields from the ARA record are sent to JAMIS?
Please provide the complete field mapping: ARA field → JAMIS field.

**4.3 — JAMIS ID assignment**
The ARA record has a `JamisId` field that is populated after export.
Who or what populates this — does JAMIS return an ID in the export response,
or is it assigned before the export is sent?

**4.4 — Export failure handling**
If the JAMIS export fails, what should happen? Should the ARA status remain
at its pre-export state, or move to a failed/error status?

**4.5 — Re-export**
Can an ARA be exported to JAMIS more than once (e.g. after a correction)?
If so, what triggers a re-export?

---

## Section 5 — Controller Section

**5.1 — Interest Impact**
The CLIN worksheet includes an "Interest Impact" field (stored as float in the
legacy database). Please confirm:
- What does this field represent?
- What unit is it expressed in (percentage, dollar amount, other)?
- Is it entered manually by the Controller, or calculated from other fields?
- Is there a validation range?

**5.2 — Expected Burn Rate**
Same questions as above for the "Expected Burn Rate" field.

**5.3 — CLIN funding cap enforcement**
The guide states the system will not allow Cost and Fee funding across all CLINs
combined to exceed the total ARA Amount set by the PM. Should this be:
- A hard block (cannot submit if exceeded), or
- A soft warning (can proceed with acknowledgement)?

**5.4 — CLIN pre-population source**
CLINs are pre-populated from JAMIS for the entered contract number. Is this a
live API call to JAMIS at the time the Controller opens the form, or is it data
already imported into the local database?

---

## Section 6 — Naming and Role Conflicts

**6.1 — Contract Manager vs. Contract Administrator**
The Non-Early Start ARA Creation Step 2 screen (Figure 14) labels the dropdown
as **"Contract Manager"**, but every other reference in the guide uses
**"Contract Administrator"**. Are these the same role, or are they two distinct
roles with different permissions in the system?

**6.2 — Early Start CA — Submit availability**
There is an inconsistency in the guide regarding the Early Start CA workflow:
- The **first** action list for Early Start CA (Figure 27) shows: Save, Upload
  Documents, Reject — with no Submit option.
- The **post-save** action list (Figure 29) adds: Submit for Next Approval.

Is Submit intentionally unavailable before the CA saves and potentially uploads
a document, or is this a documentation error? Should Submit be available as soon
as the CA opens the form (matching Non-Early Start behavior)?

---

## Section 7 — ARA Expiration

**7.1 — Expiration date source**
The ARA has an `ExpirationDate` field displayed on the Dashboard as "critical ARA
expirations." How is this date determined?
- Is it entered manually by the PM during creation?
- Is it calculated from the start date plus a fixed period?
- Is it derived from the JAMIS contract's period of performance end date?

**7.2 — Expired status transition**
What triggers an ARA to transition to **Expired** status?
- Is it automatic (a nightly job compares today's date to ExpirationDate)?
- Is it manual?
- Does it only apply to ARAs in specific statuses (e.g. active, not yet exported)?

**7.3 — Expired ARA behavior**
Once an ARA is Expired, can any further action be taken on it, or is it
permanently read-only? Should it appear in search results?

---

## Section 8 — Document Upload

**8.1 — Document requirement list**
The upload screen shows checkboxes for document requirements (Figure 25). What
are all the document requirement types available for each stage (CA and Controller)?
Please provide the complete list with display labels.

**8.2 — Required vs. optional documents**
For Non-Early Start CA, the guide says documentation is required before the CA
can submit. Which specific document requirements must be satisfied, and which
are optional?

**8.3 — File size limit**
What is the maximum file size for a single PDF upload?

**8.4 — Upload count limit**
Is there a maximum number of PDFs that can be uploaded per ARA per stage?

---

## Section 9 — OMS Number

**9.1 — OMS Number format**
What is the expected format of an OMS Number? For example:
- Is it purely numeric?
- Does it have a prefix (e.g. "OMS-12345")?
- What is the minimum and maximum length?

**9.2 — OMS validation behavior**
If a user enters an OMS Number that does not exist in the OMS system, should
the field show an error immediately, or only on form submission?

**9.3 — OMS API availability**
Is the OMS system available as a live API for lookups, or will OMS data need
to be imported and cached locally (similar to how JAMIS data may be handled)?

---

## Section 10 — Email Notifications

**10.1 — Email sender address**
What email address should system notifications be sent from?

**10.2 — Email content**
For each notification event (PM submits, CA submits, rejection, approval,
negation), should the email body include:
- A link directly to the ARA in the system?
- A summary of the ARA details?
- The specific action taken and by whom?

**10.3 — Notification on cancellation**
The guide covers email notifications for rejection and negation but does not
mention cancellation. Should an email be sent when a PM cancels an ARA? If so,
to whom?

---

## Priority Order for Response

If a full response is not immediately possible, please prioritize in this order
as each section unblocks specific build work:

| Priority | Section | Unblocks |
|---|---|---|
| 1 | Section 1 — Approval & Threshold Matrix | Entire approval routing engine |
| 2 | Section 2 — ARA Form Questions | PM and CA form UI |
| 3 | Section 3 — Approval Chain Behavior | Rejection/resubmission workflow |
| 4 | Section 4 — JAMIS Export | Export and archived/negation features |
| 5 | Section 5 — Controller Section | CLIN worksheet |
| 6 | All remaining sections | Supporting features |
