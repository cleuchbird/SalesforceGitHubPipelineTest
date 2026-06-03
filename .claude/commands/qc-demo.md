---
description: "One-shot Quality Clouds gate demo: runs Step 1 (build branch + violating Apex) then Step 2 (open PR + watch the gate block it), end to end without pausing."
argument-hint: "[theme] (optional business noun, e.g. Order, Invoice — passed through to Step 1)"
---

# Quality Clouds gate demo — one-shot

Run the full demo end to end. Prefer the two-step commands when presenting live (they let you pause
to show the code before raising the PR); use this when you just want a finished, failing demo PR.

Theme passed through to Step 1: `$ARGUMENTS`

## Steps

1. **Step 1 — build the branch.** Execute the instructions in `.claude/commands/qc-demo-branch.md`
   exactly (read that file and follow it), passing the theme argument above. This creates a unique
   `demo/qc-<theme>-<stamp>` branch off `develop` with 2 Apex classes + 1 trigger full of blocker
   violations, commits, and pushes it. **No scan runs yet** — the workflow only triggers on `pull_request`.

2. **Step 2 — raise the PR and verify.** Execute the instructions in `.claude/commands/qc-demo-pr.md`
   exactly (read that file and follow it) for the branch just created. This opens the PR into
   `develop`, watches the Quality Clouds scan, and confirms it posts 🔴 blocker inline comments and
   fails the PR — including the silent-failure guard (do not report success on a
   `Scan result is Failed. Quality check is ommited.` / `Total Issues found: 0` result).

3. **Report:** the branch name, PR URL, run conclusion, issue counts (total / blocking), and
   inline-comment count. Leave the branch and PR open.
