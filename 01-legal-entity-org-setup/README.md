# Module 01 — Legal Entity & Organization Setup

![Status](https://img.shields.io/badge/status-in%20progress-yellow)

I spent seven years working inside legal entities that someone else had configured.
Whatever the founding consultant chose — the company code, the functional currency,
the chart of accounts structure — became the constraint I operated against every
month-end. This module is the first time I'm on the other side of that decision.

**Objective:** Set up a Sri Lankan legal entity (Contoso Sri Lanka, DataAreaId `CSL`)
and build the organisation hierarchy that consolidation and management reporting will
sit on top of.

**Source:**
[Plan and implement legal entities in finance and operations apps — Microsoft Learn](https://learn.microsoft.com/en-us/training/modules/plan-implement-legal-entities-finance-operations/)

---

## Accounting requirement

<!-- Why a legal entity is the unit of statutory reporting under SLFRS / IAS 21.
     Two irreversible choices: DataAreaId and functional currency. To be written. -->

## D365 configuration

Configuration runs in seven stages in this order — some steps depend on earlier
ones (number sequences before legal entity, legal entity before hierarchy).

### Step 1 — Create a number sequence

Navigation: `Organization administration > Number sequences > Number sequences`

<!-- Steps and field values to be filled in after sandbox session. -->
<!-- [SCREENSHOT 01] -->

### Step 2 — Create the legal entity

Navigation: `Organization administration > Organizations > Legal entities > New`

<!-- Three required fields: Name, Company (DataAreaId), Country/region. To be written. -->
<!-- [SCREENSHOT 02] -->

### Step 3 — Complete the General section

<!-- Consolidation company flag, elimination company flag, cash-flow method. To be written. -->
<!-- [SCREENSHOT 03] -->

### Step 4 — Fill the supporting FastTabs

<!-- Ten FastTabs: Addresses, Contact information, Statutory reporting, Registration numbers,
     Bank account information, Number sequences, Images, Tax registration, Tax 1099.
     Table of FastTab / why-it-matters to be written. -->
<!-- [SCREENSHOT 04] — Statutory reporting FastTab -->
<!-- [SCREENSHOT 05] — Tax registration FastTab -->

### Step 5 — Create the organisation hierarchy

Navigation: `Organization administration > Organizations > Organization hierarchies`

<!-- Hierarchy name, purpose assignment. To be written. -->
<!-- [SCREENSHOT 06] -->

### Step 6 — Add the legal entity to the hierarchy and publish

<!-- Hierarchy designer: Edit > Insert > select entity. Publish step — critical. To be written. -->
<!-- [SCREENSHOT 07] — hierarchy designer before publish -->
<!-- [SCREENSHOT 08] — hierarchy status Published -->

### Step 7 — Validate

<!-- Two checks: company switcher in top banner, legal entity in hierarchy designer. -->
<!-- [SCREENSHOT 09] -->

---

## Posting and reporting impact

<!-- What downstream modules depend on choices made here. To be written. -->

## Common pitfalls

<!-- At least 4. To be written. -->

## Field notes

*To be added after the sandbox configuration session.*

## Validation checklist

<!-- At least 6 checks before moving to Module 02. To be written. -->

---

Next: [Module 02 — Currencies & Exchange Rates](../02-currencies-exchange-rates/)