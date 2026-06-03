# SalesforceGitHubPipelineTest

Repo to test running quality check and returning gate and issue data.

A sandbox for demonstrating the **Quality Clouds (QC) pull-request quality gate** on Salesforce Apex.
A GitHub Actions workflow runs the QC cloud scan on every PR, posts inline review comments for
violations, and **fails the PR when blocker-level issues are found**.

## How the gate works

- **Workflow:** [`.github/workflows/main.yml`](.github/workflows/main.yml) — job `build`, using
  `qualityclouds/action-full-scan`.
- **Triggers:** `pull_request` and `workflow_dispatch`. **Pushing a branch alone does _not_ scan** —
  the gate only runs when a PR is opened/updated.
- **Key inputs:** `mode: cloud`, `review: true` (inline PR comments), `pr_fails_on_blockers: true`
  (blocks the PR when blockers are found).
- **Base branch:** `develop`.

## Setup

1. **`QC_TOKEN` secret** — repo **Settings → Secrets and variables → Actions → New repository secret**.
   Value is your Quality Clouds API key. The key must be **authorized for this repository** on the
   Quality Clouds platform (not just valid).
2. **`GITHUB_TOKEN`** is provided automatically by GitHub Actions. Ensure the workflow has
   `pull-requests: write` (Settings → Actions → General → Workflow permissions) so the review can post.

## Demo commands

The full demo is automated as Claude Code slash commands (in [`.claude/commands/`](.claude/commands/)).
They run a three-act cycle: **introduce violations → gate blocks → resolve → gate passes.**

| Command | Act | What it does |
|---------|-----|--------------|
| `/qc-demo-branch [theme]` | 1 — build | Creates a unique branch off `develop` with 2 Apex classes + 1 trigger full of blocker violations, pushes it. **No scan yet** — show the code first. |
| `/qc-demo-pr` | 2 — gate | Opens the PR into `develop`; the scan posts 🔴 blocker comments and **fails** the PR. |
| `/qc-demo-resolve` | 3 — resolve | Rewrites the Apex into compliant code (and moves trigger logic to a handler), pushes; the gate flips to ✅ **Passed, 0 issues**. |
| `/qc-demo [theme]` | all | Runs all three acts hands-off and reports the block → green transition. |
| `/qc-demo-cleanup [branch \| --all]` | teardown | Closes the demo PR **without merging** and deletes the demo branch (local + remote), returning the repo to a clean `develop`. Pass `--all` to sweep every leftover demo branch. |

`theme` is an optional business noun (e.g. `Order`, `Invoice`) used to name the elements; it defaults
to a fresh one. Branch and element names are timestamped so repeated runs never collide. A clean run
shows **27 blockers → 0**.

The three acts and the one-shot deliberately **leave the green PR open** as the "after" exhibit. Run
`/qc-demo-cleanup` when you are finished showing it — it closes the PR unmerged (so `develop` stays
Apex-free, per the invariant below) and removes the branch.

## ⚠️ The clean-baseline invariant

**The QC action scans the _whole branch's_ Apex** — it diffs against `main` (which has no Apex), **not**
against the PR's base branch. So **every** Apex file present on the branch counts toward the gate, not
just the files changed in the PR.

Consequence: **`develop` must stay free of non-compliant Apex.** If violating code lands on `develop`,
those violations reappear in *every* demo scan (inflating the issue count and making the green finale
impossible). `develop` is intentionally kept with an **empty Apex baseline** — demos add and remove
their own elements only.

## Troubleshooting

- **Run is green but nothing was scanned.** If the log shows `Scan result is Failed. Quality check is
  ommited.` with `Total Issues found: 0`, the QC backend did not actually scan — the repository is not
  authorized/provisioned for that API key on the Quality Clouds platform. Fix it on the QC side
  (check `QC_TOKEN`, repo authorization, and any required instance mapping), not in GitHub.
- **Gate reports issues you didn't introduce.** They're coming from the `develop` Apex baseline — see
  the clean-baseline invariant above.
- **Repository renamed.** Update the local git remote (`git remote set-url origin <new-url>`) and make
  sure the new repo URL is the one authorized in Quality Clouds.
