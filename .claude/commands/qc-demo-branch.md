---
description: "Step 1/2: create a demo branch with Apex (2 classes + 1 trigger) full of Quality Clouds blocker violations. Pushes the branch but does NOT open a PR — so you can show the code and the violations first."
argument-hint: "[theme] (optional business noun, e.g. Order, Invoice, Shipment — defaults to a fresh one)"
---

# Quality Clouds gate demo — Step 1: build the branch

Create a branch containing deliberately non-compliant Apex so a presenter can **show the code and
its violations** before raising the PR. This step intentionally **does not open a pull request** —
the QC workflow only triggers on `pull_request`, so nothing scans yet. Step 2 (`/qc-demo-pr`) opens
the PR and demonstrates the pipeline blocking.

Optional theme (business noun used to name the elements): `$ARGUMENTS`
If empty, pick a fresh noun (Order, Invoice, Shipment, Contact, Lead, Case, Payment, …) not already
used by an existing branch or file.

## Fixed facts about this repo (do not re-derive)

- The QC workflow lives at `.github/workflows/main.yml` on **`develop`** and triggers on `pull_request`.
  Pushing a branch alone does **not** scan — only opening a PR does. (This is what makes the two-step split work.)
- `develop` contains the SFDX scaffold and the workflow but **no Apex baseline** (kept intentionally
  clean). Branch off `develop`. Note: the QC action scans the **whole branch's Apex** (it diffs against
  `main`), so the scan reflects every Apex file on the branch — a clean develop baseline keeps the scan
  focused on your new elements and lets the later `/qc-demo-resolve` step reach a clean green gate.
- Salesforce API version is **64.0**. Classes go in `force-app/main/default/classes/`, triggers in
  `force-app/main/default/triggers/`. Every `.cls`/`.trigger` needs a matching `-meta.xml`.
- Do **not** hardcode the GitHub repo URL/name (it has been renamed before).

## Steps

1. **Preflight.** Confirm the working tree is clean (`git status`); `git fetch origin -q`.
   Choose the theme. Derive a **unique** branch + element prefix:
   - `STAMP=$(date +%Y%m%d-%H%M%S)`
   - branch: `demo/qc-<theme-lowercase>-$STAMP`
   - element prefix `<Name>` = capitalised theme (e.g. `Order`).

2. **Create the branch off develop:**
   `git checkout -b demo/qc-<theme>-$STAMP origin/develop`

3. **Create three elements** (substitute `<Name>`). You may vary which violations you include
   run-to-run to keep demos fresh, but always keep several **blocker**-level ones. Write each file
   plus its `-meta.xml`.

   **a. `force-app/main/default/classes/<Name>Service.cls`**
   ```apex
   public class <Name>Service {                                  // SF-0018: class does DML but declares no sharing
       private String defaultOwnerId = '001000000000001AAA';     // SF-0035: hardcoded Salesforce record ID

       // SF-0008: too many parameters · SF-0047/SF-0048: missing ApexDoc on a public method
       public void process<Name>s(String name, String type, String phone, String website, String rating, String ownerId, Integer count, Boolean active) {
           List<Account> toUpdate = new List<Account>();

           for (Integer i = 0; i < count; i++)                   // SF-0006: 'for' without braces
               toUpdate.add(new Account(Name = name + i));

           for (Integer i = 0; i < count; i++) {
               List<Account> existing = [SELECT Id, Name FROM Account WHERE Name = :name LIMIT 1];  // SF-0016: SOQL in loop
               Account a = new Account(Name = name + '-' + i);
               insert a;                                          // SF-0017: DML in loop
               System.debug('Created ' + a.Id + ' owner ' + defaultOwnerId);  // SF-0025: System.debug
           }

           if (active)                                           // SF-0003: 'if' without braces
               toUpdate.clear();

           try {
               update toUpdate;
           } catch (Exception e) {                               // SF-0039: empty catch swallows the exception
           }
       }
   }
   ```

   **b. `force-app/main/default/classes/<Name>ServiceTest.cls`**
   ```apex
   @isTest(seeAllData=true)                                      // SF-0002: seeAllData=true exposes org data
   private class <Name>ServiceTest {

       // testMethod keyword (deprecated) · SF-0001: no assertion · no System.runAs used
       static testMethod void testProcess() {
           <Name>Service svc = new <Name>Service();
           svc.process<Name>s('Acme', 'Tech', '555', 'http://acme.com', 'Hot', '001000000000001AAA', 2, true);
       }

       @isTest
       static void testMath() {
           Integer x = 1 + 1;
           System.assertEquals(2, x);                            // SF-ASSERT-MSG: assertion missing a message
       }
   }
   ```

   **c. `force-app/main/default/triggers/<Name>Trigger.trigger`**
   ```apex
   trigger <Name>Trigger on Account (before insert, before update) {  // business logic in trigger body, no handler class
       String defaultOwnerId = '001000000000001AAA';            // SF-0035: hardcoded Salesforce record ID
       for (Account a : Trigger.new) {
           List<Contact> existing = [SELECT Id FROM Contact WHERE AccountId = :a.Id];  // SF-0016: SOQL in loop
           Contact c = new Contact(LastName = a.Name, AccountId = a.Id);
           insert c;                                             // SF-0017: DML in loop
           System.debug('Processed ' + a.Id + ' owner ' + defaultOwnerId);  // SF-0025: System.debug
       }
   }
   ```

   **Class meta** (`<Name>Service.cls-meta.xml` and `<Name>ServiceTest.cls-meta.xml`):
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
       <apiVersion>64.0</apiVersion>
       <status>Active</status>
   </ApexClass>
   ```

   **Trigger meta** (`<Name>Trigger.trigger-meta.xml`):
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">
       <apiVersion>64.0</apiVersion>
       <status>Active</status>
   </ApexTrigger>
   ```

4. **Commit and push the branch (no PR):**
   ```bash
   git add force-app
   git commit -m "Demo: <Name> Apex with deliberate Quality Clouds violations"
   git push -u origin demo/qc-<theme>-$STAMP
   ```

5. **Report and hand off.** Leave the working tree **on the demo branch** so the code can be shown.
   Print:
   - the branch name and the list of files created,
   - a one-line summary of the seeded violations per element,
   - a reminder: *"No scan has run yet — the pipeline only fires when the PR is opened. Run `/qc-demo-pr` for Step 2."*
