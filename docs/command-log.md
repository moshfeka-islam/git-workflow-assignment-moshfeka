# Command Log — Git Workflow Assignment

Author: Moshfeka Islam  
Date: 2026-05-04

---

## Task 1: Initialize Repository

```bash
git init
git status
git add .
git commit -m "feat: initial project structure with app config, infra, and docs"
git log --oneline
```
**Note:** Created folder structure with app/, infra/, docs/, scripts/. First commit on main establishes the base.

---

## Task 2: Remote Named origin

```bash
git remote add origin <github-repo-url>
git branch -M main
git push -u origin main
git remote -v
git branch -vv
```
**Note:** `-u` sets upstream tracking so future pushes can use `git push` without arguments.

---

## Task 3: Feature Branch — feature/add-staging-config

```bash
git checkout -b feature/add-staging-config
# edited infra/environments/staging.tfvars and app/feature-flags.yaml
git add .
git commit -m "feat: add staging feature flags and enable new_dashboard for staging"
# edited app/config.yaml
git commit -am "feat: update staging config defaults and bump version to 1.1.0"
git push -u origin feature/add-staging-config
```
**Note:** `-b` creates and switches to the branch in one command. Two separate commits to show commit atomicity.

---

## Task 4: Create and Resolve a Real Merge Conflict

```bash
# On main — edit same lines as feature branch
git checkout main
# edited app/config.yaml (version, logging level, timeout)
git commit -am "fix: update main service config to version 2.0.0 and production timeouts"
git push

# Switch to feature branch, merge main
git checkout feature/add-staging-config
git merge main
# CONFLICT (content): Merge conflict in app/config.yaml
# Automatic merge failed; fix conflicts and then commit the result.

git status
# Both modified: app/config.yaml — opened file, removed conflict markers manually

git add app/config.yaml
git commit -m "fix: resolve merge conflict — use v2.0.0 from main, keep staging env and debug logging"
```
**Note:** Conflict happened because both branches modified `version`, `logging.level`, and `timeout.request_timeout` on the same lines. Resolution kept main's version (2.0.0) but kept staging environment values.

---

## Task 5: Back-merge from main into Feature Branch

```bash
git checkout feature/add-staging-config
git fetch origin
git merge origin/main
git log --oneline --graph --decorate --all --max-count=20
```
**Why back-merge?** Long-running feature branches diverge from main over time. Regularly merging main into the feature branch:
1. Reduces future merge conflict size
2. Catches integration issues early
3. Makes the final PR merge (or rebase) clean

---

## Task 6: Hotfix and Cherry-pick

```bash
# Create hotfix branch from main
git checkout main
git checkout -b hotfix/prod-timeout
# edited infra/environments/prod.tfvars — changed request_timeout from 15 to 30
git commit -am "fix: increase prod request_timeout from 15 to 30 to prevent gateway timeouts"
git push -u origin hotfix/prod-timeout

# Create release branch and cherry-pick the hotfix commit
git checkout main
git checkout -b release/v1.0
git cherry-pick a505bfe7c3525087e4f3b9084d0bc5ed323bdb88
git push -u origin release/v1.0
```
**Cherry-pick SHA:** `a505bfe7c3525087e4f3b9084d0bc5ed323bdb88`  
**Why cherry-pick?** The release branch needs the timeout fix immediately but is not ready to absorb all of main. Cherry-pick applies exactly one commit without bringing in unrelated changes.

---

## Task 7: Rebase — feature/rename-service

```bash
git checkout main
git checkout -b feature/rename-service
# edited app/config.yaml — changed service name
git commit -am "feat: rename service from platform-service to infra-platform-service"
# updated docs/git-notes.md
git commit -am "docs: update git-notes to document service rename rationale"

# While on feature/rename-service, main got a new commit
git checkout main
# added service_name variable to infra/variables.tf
git commit -am "feat: add service_name variable to infra variables for resource tagging"

# Rebase feature branch on top of updated main
git checkout feature/rename-service
git rebase main
# Rebasing (1/2): replays commit 1
# Rebasing (2/2): replays commit 2
# Successfully rebased
```
**Rebase result:** feature/rename-service commits are now on top of the latest main, creating a linear history. No merge commit created.  
**If conflict during rebase:**
```bash
# Fix conflict in file, then:
git add <conflicted-file>
git rebase --continue
# or to abort:
git rebase --abort
```

---

## Task 8: HEAD and Detached HEAD

```bash
# View recent log
git log --oneline --decorate --max-count=5

# Checkout an old commit (enters detached HEAD)
git checkout 17f5767
git status
# HEAD detached at 17f5767
# nothing to commit, working tree clean

# Create a branch to safely capture work from detached HEAD
git switch -c experiment/detached-head-demo
# added docs/git-notes.md comprehensive content
git commit -m "docs: add comprehensive git-notes covering HEAD, detached HEAD, rebase, and origin"

# Return to main safely
git checkout main
```

---

## Task 9: Inspect History

```bash
git log --oneline --graph --decorate --all
git reflog --date=relative --max-count=15
git branch -a
git branch -vv
git remote -v
git diff main feature/rename-service
git show a505bfe
```

---

## Revert vs Reset vs Restore (Bonus)

```bash
# Revert: safe, creates a new commit undoing a previous one — use on shared branches
git revert <sha>

# Reset: moves HEAD backward — NEVER use --hard on shared branches
git reset --hard HEAD~1    # destructive: deletes commits
git reset --soft HEAD~1    # safe: keeps changes staged

# Restore: discards local file changes only
git restore app/config.yaml   # discards unstaged changes
git restore --staged app/config.yaml   # unstages a file
```
