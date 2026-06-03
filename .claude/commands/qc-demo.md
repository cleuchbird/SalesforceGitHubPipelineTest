---
description: "One-shot full-cycle Quality Clouds demo: build a branch with violating Apex, open a PR (gate blocks it), then resolve the issues so the gate passes — block → gate → green, end to end."
argument-hint: "[theme] (optional business noun, e.g. Order, Invoice — passed through to Step 1)"
---

# Quality Clouds gate demo — one-shot full cycle

Run the entire demo cycle end to end. Prefer the three step-commands when presenting live (they let
you pause between acts); use this for a hands-off run that produces the whole block→green story and
reports the transition.

Theme passed through to Step 1: `$ARGUMENTS`

## Steps

1. **Step 1 — build the branch.** Execute `.claude/commands/qc-demo-branch.md` exactly (read that
   file and follow it), passing the theme above. Creates a unique `demo/qc-<theme>-<stamp>` branch off
   `develop` with 2 Apex classes + 1 trigger full of blocker violations, commits, and pushes it. **No
   scan runs yet.**

2. **Step 2 — raise the PR (gate blocks).** Execute `.claude/commands/qc-demo-pr.md` exactly for the
   branch just created. Opens the PR into `develop`, watches the scan, and confirms it posts 🔴 blocker
   inline comments and **fails** the PR. Record the blocker count (the "before").

3. **Step 3 — resolve the issues (gate passes).** Execute `.claude/commands/qc-demo-resolve.md` exactly
   for the same branch. Rewrites the Apex into compliant code, pushes, and confirms the gate flips to
   ✅ **Passed** with **0 issues**. Honour its verify-and-iterate rule — do not report success until
   the scan reports `Total Issues found: 0`.

4. **Report the full cycle:** branch name, PR URL, and the before→after transition (e.g. "Step 2:
   blocked, 51 blockers → Step 3: passed, 0 issues"). Leave the branch and PR open as the green
   "after" exhibit.
