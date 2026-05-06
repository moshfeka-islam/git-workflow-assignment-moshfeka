git-workflow-assignment-moshfeka

**Author:** Moshfeka Islam  
**Role:** DevOps Engineer, BJIT Group  
**Assignment:** Git Workflow — Branching, Conflicts, Cherry-pick, Rebase, HEAD  
**Date:** 2026-05-06

---

## Project Purpose

This repository simulates a realistic infrastructure team Git workflow.
It demonstrates daily Git skills used in production DevOps teams including:
- Branch creation and management
- Real merge conflict creation and resolution
- Remote/origin tracking
- Cherry-picking a hotfix commit into a release branch
- Rebasing a feature branch on main
- HEAD and detached HEAD demonstration
- Readable commit history using conventional commits

All files are Terraform-style config files and YAML.
No real credentials or company code is used.

---

## Repository Structure

```
git-workflow-assignment-moshfeka/
├── README.md
├── app/
│   ├── config.yaml               # Service configuration
│   └── feature-flags.yaml        # Feature flag definitions
├── infra/
│   ├── backend.tf                # Terraform remote state config
│   ├── variables.tf              # Input variable declarations
│   └── environments/
│       ├── dev.tfvars            # Dev environment values
│       ├── staging.tfvars        # Staging environment values
│       └── prod.tfvars           # Prod environment values
├── docs/
│   ├── git-notes.md              # Key Git concept explanations
│   ├── conflict-resolution.md    # Conflict evidence and resolution
│   └── command-log.md            # All commands used with notes
└── scripts/
    └── validate.sh               # Repo structure validation script
```
---

## Branching Strategy

| Branch | Purpose | Created From |
|--------|---------|--------------|
| `main` | Stable production base | — |
| `feature/add-staging-config` | Staging env config updates | main |
| `feature/rename-service` | Service rename refactor | main |
| `hotfix/prod-timeout` | Emergency prod timeout fix | main |
| `release/v1.0` | Release candidate with hotfix | main |
| `experiment/detached-head-demo` | HEAD concept demonstration | old commit |
| `experiment/detached-head-demo-new` | New detached HEAD demo | old commit |

---

## Commands Used

See `docs/command-log.md` for full annotated command log.

Key commands used:
- `git init` — initialize repository
- `git checkout -b` — create and switch branch
- `git remote add origin` — connect to GitHub
- `git push -u origin` — push and set upstream tracking
- `git merge` — merge branches
- `git rebase` — rebase feature branch on main
- `git cherry-pick` — apply one specific commit
- `git fetch` — download from remote without applying
- `git log --oneline --graph --decorate --all` — view branch graph
- `git reflog` — view HEAD movement history
- `git branch -vv` — view branches with tracking info
- `git remote -v` — view remote connections

---

## Conflict Created and How It Was Solved

### Where
File: `app/config.yaml`

### How Conflict Was Created
Both `main` and `feature/add-staging-config` edited the same lines:
- `service.version`
- `logging.level`
- `timeout.request_timeout`
- `environment`

### Conflict Markers
<<<<<<< HEAD version:"1.1.0" environment:staging level: debug request_timeout:25
version: "1.1.0"
environment: staging
level: debug
request_timeout: 25
version: "2.0.0"
environment: production
level: warn
request_timeout: 30


main



### Resolution Decision
| Field | Feature Branch | Main | Kept | Reason |
|-------|---------------|------|------|--------|
| version | 1.1.0 | 2.0.0 | 2.0.0 | Never go backward on version |
| environment | staging | production | staging | This is staging config branch |
| logging.level | debug | warn | debug | Staging needs debug logging |
| request_timeout | 25 | 30 | 25 | Correct value for staging |

### Commands Used
```bash
git checkout feature/add-staging-config
git merge main
# CONFLICT in app/config.yaml
# Manually opened file and removed conflict markers
git add app/config.yaml
git commit -m "fix: resolve conflict — keep v2.0.0, keep staging env"
git push
```

Full evidence in `docs/conflict-resolution.md`

---

## Cherry-pick Explanation

Cherry-pick copies one specific commit from one branch
to another without merging the whole branch.

### What Was Done
1. Created `hotfix/prod-timeout` from `main`
2. Changed `request_timeout` from 15 to 30 in `prod.tfvars`
3. Committed — got SHA: `a505bfe`
4. Created `release/v1.0` from `main`
5. Cherry-picked only that one commit into release

### Commands Used
```bash
git checkout main
git checkout -b hotfix/prod-timeout
# edited infra/environments/prod.tfvars
git commit -am "fix: increase prod request_timeout from 15 to 30"
git push -u origin hotfix/prod-timeout

git log --oneline -1
# copied SHA: a505bfe

git checkout main
git checkout -b release/v1.0
git cherry-pick a505bfe
git push -u origin release/v1.0
```

### Why Cherry-pick Instead of Merge
| | Merge | Cherry-pick |
|--|-------|-------------|
| What it brings | ALL commits from branch | ONE specific commit |
| Use case | Full feature integration | Single hotfix or fix |
| Risk | Brings unrelated changes | Surgical — only what you need |

---

## Back-merge Explanation

Back-merge means merging `main` INTO a feature branch
to keep the feature branch updated with latest main changes.

### What Was Done
`main` had new commits while `feature/add-staging-config` was being worked on.
We merged `origin/main` into the feature branch before finalizing the PR.

### Commands Used
```bash
git checkout feature/add-staging-config
git fetch origin
git merge origin/main
# Fast-forward — 4 files updated from main
git push
```

### Why Teams Do Back-merge
- Reduces final PR merge conflict size
- Catches integration issues early
- Ensures feature branch has latest changes from main
- Makes reviewer's job easier

---

## Rebase Explanation

Rebase replays your branch commits on top of latest main.
Creates linear history with no merge commit.

### What Was Done
1. `feature/rename-service` had 3 commits
2. `main` got a new commit (`log_retention_days` variable)
3. Ran `git rebase main` on feature branch
4. Conflict happened in `app/config.yaml` — resolved manually
5. Ran `git rebase --continue`
6. Successfully rebased — linear history achieved
7. Force pushed because rebase rewrites commit SHAs

### Commands Used
```bash
git checkout feature/rename-service
git rebase main
# CONFLICT in app/config.yaml
# Manually resolved — kept infra-platform-service name
git add app/config.yaml
git rebase --continue
# Successfully rebased
git push origin feature/rename-service --force
```

### Rebase vs Merge
| | Merge | Rebase |
|--|-------|--------|
| Creates merge commit | Yes | No |
| History | Forked | Linear |
| Rewrites SHAs | No | Yes |
| Safe on shared branches | Yes | No |
| Force push needed | No | Yes |

---

## HEAD and Detached HEAD Explanation

### What is HEAD
HEAD is a pointer to your current position in the repository.
- Normal state: `HEAD → main → latest commit`
- Check it: `cat .git/HEAD` shows `ref: refs/heads/main`

### What is Detached HEAD
Detached HEAD occurs when HEAD points directly to a commit SHA
instead of a branch name.

### Evidence — What Was Done
```bash
# Normal HEAD
git checkout main
cat .git/HEAD
# output: ref: refs/heads/main

# Enter detached HEAD
git checkout 17f5767
# HEAD is now detached at 17f5767

git status
# HEAD detached at 17f5767

cat .git/HEAD
# output: 17f5767a084664abeb12816e543e6c1b8e3dd713

# Made a commit in detached HEAD
echo "this is a detached HEAD test" > detached-test.txt
git add detached-test.txt
git commit -m "test: commit made in detached HEAD state"
# commit 238c052 — no branch name next to it

# Saved safely to a branch
git switch -c experiment/detached-head-demo-new

# Returned to main
git checkout main
cat .git/HEAD
# output: ref: refs/heads/main — back to normal
```

### Risk of Detached HEAD
Commits made in detached HEAD have no branch.
Git will garbage collect them eventually.
Always run `git switch -c <branch-name>` before leaving.

## HEAD`~`1 and HEAD`~`2
- `HEAD~1` = one commit before current HEAD
- `HEAD~2` = two commits before current HEAD
- `ORIG_HEAD` = where HEAD was before merge/rebase — used to undo

---

## Origin / Local / Remote Branch Explanation

| Term | What it is |
|------|-----------|
| `origin` | Alias for the remote repository URL on GitHub |
| `main` | Your local branch on your machine |
| `origin/main` | Remote-tracking ref — GitHub's version of main |
| Remote branch | Branch on GitHub, seen via `git branch -r` |

### Key Points
- `git fetch` updates `origin/main` without touching local `main`
- `git pull` = `git fetch` + `git merge origin/main`
- `git push -u origin main` sets upstream tracking
- Local and remote can diverge — always fetch before merge

---

## Release Tag

A release tag marks a specific commit as a stable release point.
Tags are permanent labels that never move unlike branch pointers.

### Tags Created

| Tag | Branch | Purpose |
|-----|--------|---------|
| `v1.0` | `release/v1.0` | First stable release with prod timeout hotfix |
| `v1.0.0` | `main` | Final release after all features merged |

### Commands Used

```bash
# View existing tags
git tag -l

# Create annotated tag on release branch
git tag -a v1.0 release/v1.0 -m "Release v1.0 — includes prod timeout hotfix"

# Create annotated tag on main
git tag -a v1.0.0 -m "Release v1.0.0 — stable release with all features merged"

# View tag details
git show v1.0
git show v1.0.0

# Push tags to GitHub
git push origin v1.0
git push origin v1.0.0

# List all tags
git tag -l
```

<img width="873" height="138" alt="Release Tag" src="https://github.com/user-attachments/assets/a5a08869-9d83-445e-9a5b-700d46926a18" />



### Difference Between Lightweight and Annotated Tags

| | Lightweight | Annotated |
|--|-------------|-----------|
| Command | `git tag v1.0` | `git tag -a v1.0 -m "message"` |
| Has message | No | Yes |
| Has author | No | Yes |
| Has date | No | Yes |
| Recommended for | Temporary | Official releases |

### Why Tags Are Important
- Mark exact point in history when software was released
- Unlike branches they never move forward
- Teams can always checkout `v1.0` to get exact release code
- Used in CI/CD pipelines to trigger deployments
---

## Final Git Graph

Output of `git --no-pager log --oneline --graph --decorate --all`

<img width="1451" height="417" alt="Git-graph" src="https://github.com/user-attachments/assets/64fe91f7-35f2-489e-81c8-f2f5f80923a0" />


```
* (HEAD -> main) docs: add conventional commit style guide
* feat: update service name to infra-platform-service
* docs: update git-notes to document service rename rationale
* feat: rename service from platform-service to infra-platform-service
* feat: add log_retention_days variable to infra
| * (experiment/detached-head-demo-new) test: commit in detached HEAD
| * (experiment/detached-head-demo) docs: add comprehensive git-notes
|/
* feat: add enable_monitoring variable to infra
*   Merge pull request #1 from feature/add-staging-config
|\
| * Merge branch main into feature/add-staging-config
|/
* (tag: v1.0, release/v1.0, hotfix/prod-timeout) fix: increase prod timeout
* feat: initial project structure
```


---

## Branch Tracking

Output of `git branch -vv`

<img width="1242" height="226" alt="Branch Tracking" src="https://github.com/user-attachments/assets/5af16b6c-f79d-401f-9606-ca9fa5ed9089" />

---

## Lessons Learned

1. **Commit atomically** — one logical change per commit makes
   cherry-pick and revert safe and easy
2. **Back-merge early and often** — prevents mega-conflicts at PR time
3. **Never rebase shared branches** — rebase rewrites SHAs and breaks
   others who have pulled the old SHAs
4. **Detached HEAD is not dangerous** if you create a branch before leaving
5. **Cherry-pick is surgical** — copies one commit's diff, not whole branch
6. **`git reflog` is your safety net** — recovers lost commits after bad resets
7. **Conflict resolution needs understanding** — read both sides before choosing
8. **Always `git fetch` before `git merge`** — get latest remote state first
9. **Conventional commits** make git log readable and enable changelog automation
10. **`ORIG_HEAD` saves you** after rebase or merge — use
    `git reset --hard ORIG_HEAD` to undo

---

## Revert vs Reset vs Restore

| Command | Effect | Shared Branch Safe |
|---------|--------|-------------------|
| `git revert <sha>` | New commit undoing the change | Yes |
| `git reset --hard HEAD~1` | Moves HEAD back, deletes commits | Never |
| `git reset --soft HEAD~1` | Moves HEAD back, keeps changes staged | Local only |
| `git restore <file>` | Discards unstaged file changes | Yes |

## Revert vs Reset vs Restore

These three commands all undo things but in very different ways.

### 1. git revert — Safest

Creates a new commit that undoes a previous commit.
Original commit stays in history.
Always safe on shared branches.

**Example done in this assignment:**
```bash
# Made a test commit
echo "this line will be reverted" >> docs/git-notes.md
git add docs/git-notes.md
git commit -m "test: temporary commit to demonstrate revert"
# SHA: 59897c8

# Reverted it safely
git revert 59897c8

# Result in log:
# f941536 Revert "test: temporary commit to demonstrate revert"
# 59897c8 test: temporary commit to demonstrate revert
# Both commits exist — history fully preserved
```

**When to use:**
- On `main` or any shared branch
- When you want to undo a commit but keep history
- In production environments

<img width="895" height="146" alt="Revert" src="https://github.com/user-attachments/assets/50790690-801e-4b40-8f2f-42db68eac180" />


---

### 2. git reset — Dangerous

Moves HEAD backward and removes commits.
Never use on shared branches.

**Two types:**

**Soft reset** — removes commit but keeps changes staged:
```bash
# Made a test commit
echo "reset test line" >> docs/git-notes.md
git commit -am "test: commit to demonstrate reset"

# Soft reset — commit gone but changes still staged
git reset --soft HEAD~1
git status
# Changes to be committed:
#   modified: docs/git-notes.md
```

<img width="1010" height="355" alt="Reset" src="https://github.com/user-attachments/assets/991fdc80-df3f-4927-b201-72bf01200438" />


**Hard reset** — removes commit AND changes permanently:
```bash
# Hard reset — everything gone
git reset --hard HEAD~1
git status
# nothing to commit, working tree clean
```

**When to use:**
- Only on your own local branches
- Never on main or shared branches
- Soft reset when you want to redo commit message
- Hard reset when you want to completely undo local work

---

<img width="1037" height="287" alt="Reset Hard" src="https://github.com/user-attachments/assets/5f2f2894-a8f2-4b4c-9f9f-eba5ef86c5ac" />


### 3. git restore — File Level Only

Discards unstaged changes to a specific file.
Does not touch commits at all.

**Example:**
```bash
# Made a change but did NOT commit
echo "this will be discarded" >> docs/git-notes.md
git status
# Changes not staged for commit:
#   modified: docs/git-notes.md

# Restore — discard the change
git restore docs/git-notes.md
git status
# nothing to commit, working tree clean
```

<img width="911" height="372" alt="Git restore" src="https://github.com/user-attachments/assets/8b78e84b-faae-4621-8773-c4a50a004853" />


**Unstage a file:**
```bash
# Staged a file by mistake
git add docs/git-notes.md

# Unstage it without losing changes
git restore --staged docs/git-notes.md
git status
# Changes not staged for commit:
#   modified: docs/git-notes.md
```

**When to use:**
- When you made changes to a file but want to discard them
- When you staged a file by mistake
- Always safe — does not affect commits

---

### Comparison Table

| Command | Removes commit | Removes file changes | Safe on shared branch |
|---------|---------------|---------------------|----------------------|
| `git revert <sha>` | No — adds new commit | No — kept in new commit | ✅ Always |
| `git reset --soft HEAD~1` | Yes | No — kept staged | ❌ Local only |
| `git reset --hard HEAD~1` | Yes | Yes — permanently deleted | ❌ Never |
| `git restore <file>` | No | Yes — unstaged changes | ✅ Always |
| `git restore --staged <file>` | No | No — just unstages | ✅ Always |

---

### Golden Rule

```
On main or shared branch  → git revert
Undo local commit, keep changes → git reset --soft
Undo local commit, delete changes → git reset --hard
Discard unstaged file changes → git restore <file>
Unstage a file → git restore --staged <file>
```
