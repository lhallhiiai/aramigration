# At Risk Authorization User Guide

*July 2012*

---

## Contents

- [Overview](#overview)
- [Logging In](#logging-in)
- [Menu/Functionalities](#menufunctionalities)
- [Creating New ARA (Non-Early Start) – Program Manager (PM)](#creating-new-ara-non-early-start--program-manager-pm)
- [Creating New ARA (Early Start) – Program Manager](#creating-new-ara-early-start--program-manager)
- [New ARA (Non-Early Start) – Contract Administrator (CA)](#new-ara-non-early-start--contract-administrator-ca)
  - [Documentation Upload](#documentation-upload-ca-non-early-start)
- [New ARA (Early Start) – Contract Administrator](#new-ara-early-start--contract-administrator)
  - [Documentation Upload](#documentation-upload-ca-early-start)
- [Negating an ARA](#negating-an-ara)
- [New ARA Non-Early Start – Controller](#new-ara-non-early-start--controller)
  - [CLIN Worksheet/Calculator](#clin-worksheetcalculator)
  - [Documentation Upload](#documentation-upload-controller-non-early-start)
- [New ARA Early Start – Controller](#new-ara-early-start--controller)
  - [Documentation Upload](#documentation-upload-controller-early-start)
- [ARA Approval – Approvers](#ara-approval--approvers)
- [Glossary](#glossary)

---

## Overview

The At Risk Authorization (ARA) application within Alion Journal Entry and Revenue Adjustment System (AJERAS) allows for the submission, review and approval of ARAs through the web. Users can search and filter through all entries and review their statuses.

The ARA application will accommodate two types of ARAs:

- Authority to Spend Only
- Authority to Spend with Revenue Recognition

---

## Logging In

To begin, the user should navigate their browser to `http://intra-app.alionscience.com/ajeras/`. The initial login page (Figure 1) provides for the submission of user name and password. Once granted access, users may log in using the Alion network credentials.

> **Figure 1: Login Page**

The system will time out after three (3) hours of non-use.

Once logged in, the application then displays the main landing page (Figure 2) where the application allows **'My Action List'** or **'See All ARAs'** selection to show only ARAs which require the user's actions, or all ARAs currently circulating the application, respectively.

---

## Menu/Functionalities

### Landing Page

> **Figure 2: Main Landing Page**

### Dashboard Page

The user may also click on **'Dashboards'** to display critical ARA expirations by expected expiration dates, and also all ARAs pending approval listed by status (Figure 3).

> **Figure 3: Dashboard Page**

### Create ARA Page

**'Create ARA'** (Figure 4) is only available to users with the **'Creator'** role in the ARA application.

> **Figure 4: Create ARA Page – Only for Creator Roles**

### Search ARA Page

**'Search ARA'** (Figure 5) allows users to search through existing ARAs.

> **Figure 5: Search ARA Page**

### ARA System Information Page

**'ARA System Information'** (Figure 6) displays system-level configuration including delegations.

> **Figure 6: ARA System Information Page – Delegations**

### Approval and Threshold Matrix Page

ARA automatically forwards email alerts to the appropriate users to review entries based on the Approval and Threshold Matrix (Figure 7).

> **Figure 7: ARA System Information Page – Approval & Threshold Matrix**

### Quick Search Page

The **'Quick Search'** function allows partial or complete ARA ID or JAMIS ID searches (Figure 8).

> **Figure 8: Quick Search Page**

---

## Creating New ARA (Non-Early Start) – Program Manager (PM)

Creators may create new ARAs by clicking the **'Create ARA'** menu and selecting a Risk Category (Figure 9; also see [Glossary](#glossary) for each risk category definition).

Non-Early Start risk categories include:

- Award Fees
- Mod Pending (Incremental Funding)
- Internal Cleared
- Mod Pending (Exercise Option Period)
- Commercial At-Risk
- Change in Scope
- Fixed Price Mod
- Mod Pending (Not Exercise Option Period)

Selecting a Non-Early Start risk category prompts the **Org Autocomplete** input field, **Revenue Recognition** selection, and **JAMIS/Contract Autocomplete** input field (Figure 10).

> **Figure 9: Risk Categories**

> **Figure 10: Risk Categories – Non-Early Start ARA**

The ARA application prompts the **Org Autocomplete** input field which pulls up any keystrokes matching Sector, Group, Operation, Division, or Description of data stored in JAMIS (Figure 11).

To improve the accuracy of the data, the ARA application checks the validity of data made in these input fields. When you begin to type in a value in a field, the application will display a drop-down window with possible valid values (Figure 11).

> **Figure 11: Org Autocomplete Input Field**

Once the Org is autocompleted, the user may select the **Revenue Recognition** (Figure 12) of the ARA to either grant:

- Authority to Spend and Recognize Revenue, or
- Authority to Spend only

> **Figure 12: Revenue Recognition Selection**

Then, the application prompts the **JAMIS/Contract Autocomplete** input field which pulls up any keystrokes matching JAMIS Number or Contract Number currently stored in JAMIS (Figure 13), before clicking **'Next'** to complete the 'Create ARA' page.

> **Figure 13: JAMIS/Contract Number Autocomplete Input Field**

Once the **'Next'** button is clicked, the ARA application will prompt the **ARA Creation Step 2** screen detailing the Creator's data inputs. The Creator may select the **Contract Manager** and **Controller** from the drop-down menus (Figure 14).

> **Figure 14: Non-Early Start ARA Creation Step 2 Screen – Contract Manager & Controller**

After the Contract Administrator and Controller are selected, click the **'Create ARA'** button (Figure 14) to complete the ARA creation.

Once the ARA is created, the **ARA Summary** screen will prompt to allow the Creator to either:

1. **Save** – To save an ARA to complete later; the application will call up information entered up to this point when the PM is ready to complete this ARA form
2. **Upload Documents** – To upload any supporting documents as necessary
3. **Sign and Submit** – To submit an ARA once the required input fields are completed; once an ARA is signed and submitted by the PM, that section of the ARA form will become read-only, and any additional edits can be done by having the next user to take action reject the form (Figure 15)
4. **Cancel this ARA** *(PM-Only right)* – To cancel an ARA in progress (Figure 15)

> **Figure 15: ARA Summary Screen – Non-Early Start**

> **Note:** The PM shall Save the ARA of answered questions prior to being allowed to Upload Documents or Sign & Submit (Figure 16).

> **Figure 16: ARA Summary Screen – Non-Early Start Prior to Sign & Submit**

> **Note:** Questions only apply to ARA amounts greater than $50K.

Once the PM signs and submits the ARA, the PM section of the ARA form becomes read-only, an email notification will be sent, and this ARA will be in queue for the **Contract Administrator** to take action.

---

## Creating New ARA (Early Start) – Program Manager

Creators may create new ARAs by clicking the **'Create ARA'** menu and selecting a Risk Category (Figure 9).

> **Figure 17: Risk Categories**

**Pre-Contract Costs (Early Start)** ARAs will prompt the Org Autocomplete input field, Revenue Recognition selection, and the **Opportunity Management System (OMS) Number** (Figure 18).

> **Figure 18: Risk Categories – Early Start ARA**

The ARA application prompts the **Org Autocomplete** input field which pulls up any keystrokes matching Sector, Group, Operation, Division, or Description of data stored in JAMIS (Figure 19).

To improve the accuracy of the data, the ARA application checks the validity of data made in these input fields. When you begin to type in a value in a field, the application will display a drop-down window with possible valid values (Figure 19).

> **Figure 19: Org Autocomplete Input Field**

Once the Org is autocompleted, the user may select the **Revenue Recognition** (Figure 20) of the ARA to either grant:

- Authority to Spend and Recognize Revenue, or
- Authority to Spend only

> **Figure 20: Revenue Recognition Selection**

Then, the PM will need to fill out the **Opportunities Management System Number (OMS)** field which pulls up any keystrokes matching data currently stored in the OMS (Figure 21), before clicking **'Next'** to complete the 'Create ARA' page.

> **Figure 21: OMS Number Input Field**

Once the **'Next'** button is clicked, the ARA application will prompt the **ARA Creation Step 2** screen detailing the Creator's data inputs. The PM will need to enter the **Title** and **Customer** information, as well as select the **Contract Administrator** and **Controller** from the drop-down menus (Figure 22).

> **Figure 22: Early Start ARA Creation Step 2 Screen – Contract Administrator & Controller**

After the Contract Administrator and Controller are selected, click the **'Create ARA'** button (Figure 22) to complete the ARA creation.

Once the ARA is created, the **ARA Summary** screen will prompt to allow the PM to either:

1. **Save** – To save an ARA to complete later; the application will call up information entered up to this point when the PM is ready to complete this ARA form
2. **Sign and Submit** – To submit an ARA once the required input fields are completed; once an ARA is signed and submitted by the PM, that section of the ARA form will become read-only, and any additional edits can be done by having the next user to take action reject the form (Figure 23)
3. **Cancel this ARA** *(PM-Only right)* – To cancel an ARA in progress (Figure 23)

> **Figure 23: ARA Summary Screen – Early Start**

> **Note:** Questions only apply to ARA amounts greater than $50K.

Once the PM completes, signs and submits the ARA, the PM section of the ARA form becomes read-only, an email notification will be sent, and this ARA will be in queue for the **Contract Administrator** to take action.

---

## New ARA (Non-Early Start) – Contract Administrator (CA)

The application will prompt the Contract Administrator page (Figure 24) in an ARA for which the CA selected to take action on. The CA is to answer all questions.

> **Figure 24: Contract Administrator Page – Non-Early Start**

The CA may take one of the following actions:

1. **Save** – To save an ARA to complete later; the application will call up information entered up to this point when the CA is ready to complete this ARA form (Figure 24)
2. **Reject ARA** – To reject an ARA; a rejected ARA will be returned to the PM's queue and the action chain starts over, and an email notification will be sent out to all parties that have taken action on this rejected ARA up to this point (Figure 24)

Once the questions are answered, the CA will need to save this section of the form prior to being given the option to upload documents (Figure 24).

### Documentation Upload (CA Non-Early Start)

Once the CA section of the form is completed, the CA may upload one PDF file to satisfy multiple document upload requirements, or upload multiple PDF files to satisfy one document requirement; by checking off any boxes on the right of the pop-up screen that applies to the document being uploaded (Figure 25).

> **Figure 25: Contract Administrator Page – Non-Early Start Documentation Upload**

Once the contracts documentation(s) upload is satisfied, the CA may take the following actions:

1. **Save** – To save an ARA to complete later; the application will call up information entered up to this point when the CA is ready to complete this ARA form
2. **Upload Documents** – To upload any supporting documents as necessary
3. **Submit for Next Approval** – To submit an ARA once the required input fields are completed; once an ARA is signed and submitted by the CA, that section of the ARA form will become read-only, and any additional edits can be done by having the next user to take action reject the form (Figure 26)
4. **Reject ARA** – To reject an ARA; a rejected ARA will be returned to the PM's queue and the action chain starts over, and an email notification will be sent out to all parties that have taken action on this rejected ARA up to this point (Figure 26)

> **Figure 26: Contract Administrator Page – Non-Early Start Documentation After Document Upload**

After the CA submits the ARA, the CA section of the ARA form becomes read-only, an email notification will be sent, and this ARA will be in queue for the **Controller** to take action.

---

## New ARA (Early Start) – Contract Administrator

The application will prompt the Contract Administrator page (Figure 27) in an ARA for which the CA selected to take action on.

> **Figure 27: Contract Administrator Page – Early Start**

The CA may take one of the following actions:

1. **Save** – To save an ARA to complete later; the application will call up information entered up to this point when the CA is ready to complete this ARA form (Figure 27); the CA must save the form prior to being allowed to upload a document
2. **Upload Documents** – To upload documentation(s) to support an ARA based on Risk Category; documentation upload is not mandatory for Early Start ARAs. Once an ARA is signed and submitted by the CA, that section of the ARA form will become read-only, and any additional edits can be done by having the next user to take action reject the form (Figure 27)
3. **Reject ARA** – To cancel an ARA; a rejected ARA will be returned to the PM's queue and the action chain starts over, and an email notification will be sent out to all parties that have taken action on this rejected ARA up to this point (Figure 27)

### Documentation Upload (CA Early Start)

Once the CA section of the form is completed, the CA may upload one PDF file to satisfy multiple document upload requirements, or upload multiple PDF files to satisfy one document requirement; by checking off any boxes on the right of the pop-up screen that applies to the document being uploaded (Figure 28). However, supporting documentation is **not required** for Early Starts.

> **Figure 28: Contract Administrator Page – Early Start Documentation Upload**

Once the contracts documentation(s) upload is satisfied, the CA may take the following actions:

1. **Save** – To save an ARA to complete later; the application will call up information entered up to this point when the CA is ready to complete this ARA form
2. **Upload Documents** – To upload any supporting documents as necessary
3. **Submit for Next Approval** – To submit an ARA once the required input fields are completed; once an ARA is signed and submitted by the CA, that section of the ARA form will become read-only, and any additional edits can be done by having the next user to take action reject the form (Figure 29)
4. **Reject ARA** – To reject an ARA; a rejected ARA will be returned to the PM's queue and the action chain starts over, and an email notification will be sent out to all parties that have taken action on this rejected ARA up to this point (Figure 29)

> **Figure 29: Contract Administrator Page – Early Start Documentation After Document Upload**

After the CA submits the ARA, the CA section of the ARA form becomes read-only, an email notification will be sent, and this ARA will be in queue for the **Controller** to take action.

---

## Negating an ARA

If a contract modification is never received from the customer, the ARA will remain **'Expired'** in the ARA module. However, if a contract modification is received after an ARA is exported into JAMIS, the Contract Administrator has the capability to negate the ARA by first going into the **'Archived'** menu (Figure 30).

> **Figure 30: Archived – Negating ARA**

Select the ARA to negate; the Contract Administrator tab will be prompted. Negate the ARA by clicking on the **"Negate ARA"** button (Figure 31).

> **Figure 31: Exported ARA – Negating ARA**

Once negated, the Status will change to **"Negated"** (Figure 32) and an email will be sent to all parties involved in the creation and approval of this ARA.

> **Figure 32: Negating ARA – Status Change**

---

## New ARA Non-Early Start – Controller

The application will prompt the Controller page (Figure 33) in an ARA for which the Controller selected to take action on.

> **Figure 33: Controller Page – Non-Early Start**

### CLIN Worksheet/Calculator

The Controller may take one of the following actions:

1. **Add** – To add a CLIN to allocate the ARA funding; the system displays and pre-populates the total number of available CLIN(s) under the JAMIS entered (Figure 33)
2. **Reject ARA** – To reject an ARA; a rejected ARA will be returned to the PM's queue and the action chain starts over, and an email notification will be sent out to all parties that have taken action on this rejected ARA up to this point (Figure 33)

Once the CLIN(s) are added, the Controller Summary page will prompt for additional information entry. The Controller will need to complete the following fields and save (Figure 33) the form before the system allows documentation upload; or reject the ARA (Figure 33):

- Company
- Interest Impact
- Expected Burn Rate
- Incurred Costs
- Incurred Fee

> **Figure 34: Controller Page – Non-Early Start Prior to Submission**

**Please note:**

1. Any pre-populated CLINs can only be used once for each ARA
2. The Total Cost, Total Fees, and Total fields will auto-populate once all CLIN information is entered
3. The system will not allow the Cost and Fee funding for all CLINs combined to exceed the total ARA Amount set by the PM

### Documentation Upload (Controller Non-Early Start)

Once the Controller section of the form is completed, the Controller may save the ARA and upload one PDF file to satisfy multiple document upload requirements, or upload multiple PDF files to satisfy one document requirement; by checking off any boxes on the right of the pop-up screen that applies to the document being uploaded (Figure 35).

> **Figure 35: Controller Page – Non-Early Start Documentation Upload**

The Controller may submit the ARA for approval after the documentation upload is completed:

1. **Save** – To save an ARA to complete later; the application will call up information entered up to this point when the Controller is ready to complete this ARA form
2. **Upload Documents** – To upload any additional supporting documents as necessary
3. **Submit for Approval** – To submit an ARA once the required input fields are completed; once an ARA is signed and submitted by the Controller, that section of the ARA form will become read-only, and any additional edits can be done by having the next user to take action reject the form (Figure 36)

> **Figure 36: Controller Page – Non-Early Start After Documentation Upload**

After the Controller submits the ARA, the Controller section of the ARA form becomes read-only, an email notification will be sent, and this ARA will be in queue for the next **Approver** to take action.

---

## New ARA Early Start – Controller

The application will prompt the Controller page (Figure 37) in an ARA for which the Controller selected to take action on.

> **Figure 37: Controller Page – Early Start**

The Controller may take one of the following actions:

1. **Save** – To save an ARA to complete later; the application will call up information entered up to this point when the Controller is ready to complete this ARA form (Figure 37)
2. **Upload Documents** – To upload any supporting documents as necessary
3. **Submit for Approval** – To submit the ARA after the Controller section of the form is completed; a submitted ARA will be queued to the next approver for review and processing (Figure 37)
4. **Reject ARA** – To cancel an ARA; a rejected ARA will be returned to the PM's queue and the action chain starts over, and an email notification will be sent out to all parties that have taken action on this rejected ARA up to this point (Figure 37)

**Please note:** The Controller is not required to input the CLIN information.

### Documentation Upload (Controller Early Start)

The Controller is not required to supply any supporting documentations, but has the option to upload one PDF file to satisfy multiple document upload requirements, or upload multiple PDF files to satisfy one document requirement.

> **Figure 38: Controller Page – Early Start Documentation Upload**

The Controller may submit the ARA for approval after the documentation upload is completed:

1. **Save** – To save an ARA to complete later; the application will call up information entered up to this point when the Controller is ready to complete this ARA form
2. **Upload Documents** – To upload any additional supporting documents as necessary
3. **Submit for Approval** – To submit an ARA once the required input fields are completed; once an ARA is signed and submitted by the Controller, that section of the ARA form will become read-only, and any additional edits can be done by having the next user to take action reject the form

> **Figure 39: Controller Page – Early Start After Documentation Upload**

After the Controller submits the ARA, the Controller section of the ARA form becomes read-only, an email notification will be sent, and this ARA will be in queue for the next **Approver** to take action.

---

## ARA Approval – Approvers

The application will prompt the ARA Home page (Figure 40) upon login. The approver may select an ARA to take action on. Please see [Logging In](#logging-in) for details on the left-hand menu.

> **Figure 40: ARA Home Page – Approver**

Once the Approver selects the ARA to review, the system will prompt the **Approvals** page, which details the Approval Cycle(s) of the selected ARA (Figure 41).

> **Figure 41: Approval Cycle(s)**

The Approver may take one of the following actions (Figure 41):

1. **Review** – The approver is given read-only rights to review an ARA
2. **Approve** – An approved ARA will be queued to the next approver for action based on the Approval & Threshold Matrix (Figure 7); an email notification will be sent to all users who have taken action on the ARA of approval, and an email notification will be sent to the next approver to take action
3. **Reject** – The approver will be allowed to provide a comment and pick a reason code for the rejection, and select an affected tab for focus of review and resubmission. A rejected ARA will be sent back to the PM to correct/resubmit, and the ARA life cycle starts over (Figure 42)

> **Figure 42: Approval Cycle(s) – Prior to Rejection**

> **Figure 43: Approval Cycle(s) – After Rejection**

> **Note:** The Status and Revision change prior to (Figure 42) and after rejection (Figure 43).

---

## Glossary

1. **AWARD FEES** are estimated and recorded as a percentage of costs incurred or revenue recognized – by definition not funded until awarded.

2. **MODIFICATION PENDING** applies where the customer needs to increase contract funding, increase contract value, exercise an option period and/or extend the period of performance ONLY for work performed within the scope and statement of work on an existing cost reimbursement or T&M contract. Alion is continuing to provide services at the customer's oral or written request and has submitted a valid notice (i.e., 75% Letter/Limitation of Funds Notice) as well as a modification request to the customer AND the customer has notified Alion a contract modification is in process.

   **Modification Pending Sub-Categories:**
   - Any pending modification that is solely a request for incremental funding within the existing period of performance and contract ceiling.
   - Any pending modification to exercise an option period and increase funding.
   - Any pending request to increase funding and extend period of performance that is not the exercise of an option period.

3. **CHANGE IN SCOPE** – Work involving a change in scope and/or a change in statement of work for an existing cost reimbursement or T&M contract may include changes in contract value, funding and/or period of performance. A change in scope can be triggered by a customer-issued change order or a written customer authorization for Alion to proceed in accordance with Alion's submitted proposal requesting a change in contract scope.

4. **FIXED PRICE MODIFICATION**, including a request for an equitable adjustment, involves work that gives rise to a request for an increase in the funding and/or value of a fixed price contract. A fixed price modification may include changes to a contract's scope, statement of work, period of performance and/or other terms and conditions.

5. **COMMERCIAL AT-RISK** is work requested by an existing commercial customer based on prior commercial practice absent an executed T&M or fixed price contract. This includes situations where the customer has paid Alion for amounts billed above contract ceiling.

6. **INTERNALLY CLEARED** applies where the condition that created the need for risk funding has been cleared or significantly mitigated after the report run date. These items require Alion action but do not require customer involvement or action. Examples include: funding modifications received after the report run date; funding modifications in hand but not recorded in JAMIS as of the report run date; JAMIS data corrections not recorded as of the report run date that arose from contract modifications already received; and contract cost corrections in process as of the report run date. These conditions are normally resolved within the next cost accounting period, usually 30 days, but not later than the end of the subsequent quarter.

7. **PRE-CONTRACT COSTS** involve work in advance of a final negotiated contract subject to notice of award where the customer has authorized Alion in writing to proceed in advance of issuing a definitized contract.
