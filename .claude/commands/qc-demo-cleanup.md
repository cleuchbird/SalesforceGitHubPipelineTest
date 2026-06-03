---
description: "Step 4 (teardown): close the demo PR without merging and delete the demo branch (local + remote), returning the repo to a clean develop. Pass --all to sweep every leftover demo branch."
argument-hint: "[branch | --all] (optional — defaults to the current demo/qc-* branch, else the most recent one with an open PR)"
---

# Quality Clouds gate demo — Step 4: tear down the demo

Close the pull request **without merging** and delete the demo branch created by the earlier steps,
returning the repo to a clean state. This is the optional teardown after the demo is over — the
one-shot `/qc-demo` and Step 3 deliberately leave the green PR open as the "after" exhibit, so run
this only when you are done showing it.

**The PR is closed, never merged.** Merging would add the demo Apex onto `develop`, which the whole
two-step demo design intentionally keeps Apex-free. Closing tears down the exhibit and preserves that
clean baseline.

Optional argument: `$ARGUMENTS`

## Fixed facts about this repo (do not re-derive)

- Demo branches are named `demo/qc-<theme>-<stamp>` and target base **`develop`**.
- `develop` is intentionally kept **free of any Apex baseline**; closing (not merging) keeps it that way.
- Do **not** hardcode the GitHub repo URL/name. Let `gh` derive it from the remote; use `{owner}/{repo}` in `gh api`.
- **Safety guard:** only ever close PRs whose head branch matches `demo/qc-*`, and only ever delete
  branches matching `demo/qc-*`. **Never** touch `develop` or `main`. If a resolved target does not
  match `demo/qc-*`, abort and report instead of deleting anything.

## Steps

1. **Resolve the target branch(es).**
   - If the argument is `--all`: every remote demo branch —
     `git for-each-ref --format='%(refname:short)' refs/remotes/origin/demo/qc-* | sed 's#^origin/##'`.
   - Else if an explicit branch argument was given: use it.
   - Else if the current branch (`git branch --show-current`) matches `demo/qc-*`: use it.
   - Else the most recent remote demo branch with an **open** PR:
     `git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/remotes/origin/demo/qc-* | sed 's#^origin/##'`
     cross-checked against `gh pr list --state open --json number,headRefName`.
   - Apply the safety guard to every resolved branch before doing anything destructive.

2. **Get off the demo branch** so it can be deleted locally:
   ```bash
   git checkout develop
   git pull --ff-only
   ```

3. **For each target branch:**
   - Find its PR: `gh pr list --head <branch> --state all --json number,state -q '.[0]'`.
   - **If an open PR exists**, post a short closing comment, then close **without merging** and delete the remote branch:
     ```bash
     gh pr comment <PR#> --body "Demo complete — closing and tearing down. No merge: develop stays Apex-free."
     gh pr close <branch> --delete-branch
     ```
     (`gh pr close --delete-branch` closes the PR unmerged and deletes the remote branch; it also
     removes the local branch when present.)
   - **If there is no open PR**, delete the remote branch directly:
     ```bash
     git push origin --delete <branch>
     ```
   - Delete the local branch if it still exists: `git branch -D <branch>` (ignore "not found").

4. **Verify and report** (do not claim cleanup without this). For each target:
   - PR state is **CLOSED** (not **MERGED**): `gh pr view <PR#> --json state,mergedAt`.
   - The remote branch is gone: `git ls-remote --heads origin <branch>` returns nothing.
   - Confirm the working tree is on `develop` and `develop` is unchanged and still Apex-free
     (`git ls-tree -r --name-only origin/develop -- force-app | grep -E 'classes|triggers'` returns nothing).

   Report: each branch removed, each PR closed (with its number), confirmation that **no PR was merged**,
   and that `develop` remains clean.
