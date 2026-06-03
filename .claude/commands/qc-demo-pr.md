---
description: "Step 2/2: open the PR for the current demo branch (into develop) and watch the Quality Clouds gate post blocker comments and fail the PR."
argument-hint: "[branch] (optional — defaults to the current demo/qc-* branch, else the most recent one)"
---

# Quality Clouds gate demo — Step 2: raise the PR and show the gate block

Open the pull request for a branch built by `/qc-demo-branch`, then watch the Quality Clouds scan
run, post 🔴 blocker inline comments, and **fail** the PR via `pr_fails_on_blockers: true`.

Optional branch argument: `$ARGUMENTS`

## Fixed facts about this repo (do not re-derive)

- Base branch for the PR is **`develop`**. The QC workflow triggers on `pull_request`.
- Do **not** hardcode the GitHub repo URL/name. Let `gh` derive it from the remote; use `{owner}/{repo}` in `gh api`.

## Steps

1. **Determine the demo branch:**
   - If an argument was given, use it.
   - Else if the current branch (`git branch --show-current`) matches `demo/qc-*`, use it.
   - Else pick the most recent remote demo branch that has no open PR yet:
     `git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/remotes/origin/demo/qc-* | sed 's#^origin/##'`
     and cross-check against `gh pr list --state open`.
   - Make sure it is pushed: `git push -u origin <branch>` (idempotent).

2. **Open the PR into develop:**
   ```bash
   gh pr create --base develop --head <branch> \
     --title "Demo: Quality Clouds gate on non-compliant Apex" \
     --body "Live demo of the Quality Clouds PR gate. The added Apex (2 classes + 1 trigger) contains blocker-level violations; the scan should post inline 🔴 comments and fail this PR via pr_fails_on_blockers."
   ```
   Capture the PR number and URL.

3. **Watch and VERIFY** (do not claim success without this):
   - Find the run: `gh run list --limit 3`; watch it: `gh run watch <id> --interval 15`.
   - Read the scan summary line `Total Issues found:` from the run log.
   - **A correct demo requires ALL of:**
     - run conclusion = **failure** and PR check `build` = **fail**
     - **Total Issues found > 0**, **Blocking Issues > 0**, **Quality Gate: Not Passed**
     - inline comments present: `gh api repos/{owner}/{repo}/pulls/<PR#>/comments -q '.[].path' | wc -l`
   - **Known silent-failure mode — do NOT report success if you see this:** if the log says
     `Scan result is Failed. Quality check is ommited.` with `Total Issues found: 0`, the GitHub job
     goes green but the QC backend did **not** actually scan. That means the repo is not
     authorized/provisioned on the Quality Clouds side (check `QC_TOKEN`, repo authorization, and
     whether a `url_id` instance mapping is required). Report this clearly instead of claiming the gate passed.

4. **Report:** the PR URL, run conclusion, issue counts (total / blocking), and inline-comment count.
   Leave the branch and PR open for the demo.
