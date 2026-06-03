---
description: "Step 3/3: resolve all Quality Clouds violations on the current demo branch and push, so the gate on the existing PR flips from blocked to PASSING (green)."
argument-hint: "[branch] (optional — defaults to the current demo/qc-* branch with an open PR)"
---

# Quality Clouds gate demo — Step 3: resolve the issues and show the gate pass

Rewrite the violating Apex created by `/qc-demo-branch` into fully compliant code, push to the
**same branch**, and watch the Quality Clouds gate on the existing PR flip from ❌ blocked to
✅ **Passed**. This is the satisfying "after" that closes the demo cycle.

Optional branch argument: `$ARGUMENTS`

## Fixed facts about this repo (do not re-derive)

- Base branch is **`develop`**; the QC workflow triggers on `pull_request`. Pushing to the demo
  branch re-runs the scan on its open PR (a `synchronize` event).
- The compliant templates below are **verified green** (0 blockers) for the service + test. The
  trigger is made compliant by delegating to a handler class. Salesforce API version is **64.0**.
- Do **not** hardcode the GitHub repo URL/name. Let `gh` derive it from the remote; use `{owner}/{repo}`.

## Steps

1. **Locate the demo branch and PR.**
   - Branch: the argument if given; else the current branch if it matches `demo/qc-*`; else the most
     recent remote `demo/qc-*` branch that has an **open** PR (cross-check `gh pr list --state open`).
   - `git checkout <branch>` if not already on it; `git pull --ff-only` to be current.
   - Derive the element prefix `<Name>` from the branch theme (`demo/qc-<theme>-<stamp>` → capitalise
     `<theme>`). Sanity-check against the actual files: `ls force-app/main/default/classes/*Service.cls`.
   - Capture the PR number: `gh pr view --json number -q .number` (or `gh pr list --head <branch>`).

2. **Overwrite the three violating elements with the compliant versions** (substitute `<Name>`), and
   **add a new handler class** so the trigger body carries no business logic.

   **`force-app/main/default/classes/<Name>Service.cls`** (verified green):
   ```apex
   /**
    * @description Service for creating Account records in bulk. Declared
    * `with sharing` so all DML runs in the calling user's sharing context.
    */
   public with sharing class <Name>Service {

       /**
        * @description Creates `count` Account records, each named from `baseName`.
        * Records are collected into a list and inserted with a single DML statement,
        * keeping the method bulk-safe and within governor limits. Object create
        * permission is checked before the insert.
        *
        * @param baseName base text used to build each Account's Name
        * @param count    number of Account records to create; ignored when not positive
        */
       public void process<Name>s(String baseName, Integer count) {
           if (String.isBlank(baseName) || count == null || count <= 0) {
               return;
           }

           if (!Schema.sObjectType.Account.isCreateable()) {
               return;
           }

           List<Account> accountsToInsert = new List<Account>();
           for (Integer i = 0; i < count; i++) {
               accountsToInsert.add(new Account(Name = baseName + '-' + i));
           }

           insert accountsToInsert;
       }
   }
   ```

   **`force-app/main/default/classes/<Name>ServiceTest.cls`** (verified green):
   ```apex
   /**
    * @description Unit tests for <Name>Service.
    */
   @isTest
   private class <Name>ServiceTest {

       @isTest
       static void createsRequestedNumberOfAccounts() {
           System.runAs(currentUser()) {
               Test.startTest();
               new <Name>Service().process<Name>s('Acme', 3);
               Test.stopTest();
           }

           Integer created = [SELECT COUNT() FROM Account WHERE Name LIKE 'Acme-%'];
           System.assertEquals(3, created, 'process<Name>s should create one Account per requested count');
       }

       @isTest
       static void ignoresNonPositiveCount() {
           System.runAs(currentUser()) {
               Test.startTest();
               new <Name>Service().process<Name>s('Acme', 0);
               Test.stopTest();
           }

           Integer created = [SELECT COUNT() FROM Account WHERE Name LIKE 'Acme-%'];
           System.assertEquals(0, created, 'No Accounts should be created when count is not positive');
       }

       /**
        * @description Returns a handle to the running user so tests can demonstrate
        * execution in a specific user context via System.runAs.
        *
        * @return the running user
        */
       private static User currentUser() {
           return new User(Id = UserInfo.getUserId());
       }
   }
   ```

   **`force-app/main/default/triggers/<Name>Trigger.trigger`** (thin — logic delegated):
   ```apex
   trigger <Name>Trigger on Account (before insert, before update) {
       new <Name>TriggerHandler().applyDefaults(Trigger.new);
   }
   ```

   **`force-app/main/default/classes/<Name>TriggerHandler.cls`** (NEW — compliant handler):
   ```apex
   /**
    * @description Handles <Name> trigger logic for Account records, keeping the
    * trigger body free of business logic and running in the caller's sharing context.
    */
   public with sharing class <Name>TriggerHandler {

       /**
        * @description Applies default field values to Account records before they
        * are saved. Operates on the in-memory trigger records, so it performs no
        * SOQL or DML.
        *
        * @param accounts the Account records supplied by the trigger context
        */
       public void applyDefaults(List<Account> accounts) {
           if (accounts == null) {
               return;
           }

           for (Account account : accounts) {
               if (String.isBlank(account.Description)) {
                   account.Description = 'Processed by <Name>TriggerHandler';
               }
           }
       }
   }
   ```

   **Handler meta** (`<Name>TriggerHandler.cls-meta.xml`):
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
       <apiVersion>64.0</apiVersion>
       <status>Active</status>
   </ApexClass>
   ```

3. **Commit and push to the same branch** (re-triggers the scan on the open PR):
   ```bash
   git add force-app
   git commit -m "Resolve all Quality Clouds violations in <Name> Apex"
   git push origin <branch>
   ```

4. **Watch and VERIFY the gate now PASSES** (do not claim success without this):
   - Find the newest run: `gh run list --limit 3`; watch it: `gh run watch <id> --interval 15`.
   - **A correct resolution requires ALL of:**
     - run conclusion = **success** and PR check `build` = **pass**
     - scan summary: **Quality Gate: Passed**, **Total Issues found: 0**, **Blocking Issues: 0**
   - **If blockers remain** (the scan still reports issues), read the issue table from the run log
     (`gh run view <id> --log | grep '^|'`), fix the named elements/lines, push again, and re-verify.
     Do NOT report success until **Total Issues found: 0**. (Common stragglers QC flags: missing
     ApexDoc `@description` tags, and missing CRUD/FLS checks before SOQL/DML — both already handled
     in the templates above.)

5. **Report:** the PR URL, the before→after (e.g. "51 blockers → 0"), run conclusion, and that the
   gate now passes. Leave the PR open as the green "after" exhibit.
