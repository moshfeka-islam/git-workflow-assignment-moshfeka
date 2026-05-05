# git-workflow-assignment-moshfeka

**Author:** Moshfeka Islam  
**Role:** DevOps Engineer  
**Assignment:** Git Workflow — Branching, Conflicts, Cherry-pick, Rebase, HEAD  
**Date:** 2026-05-04

---

## Project Purpose

This repository simulates a realistic infrastructure team Git workflow. It covers:
- Branch creation and management
- Real merge conflict creation and resolution
- Remote/origin tracking
- Cherry-picking a hotfix commit
- Rebasing a feature branch on main
- HEAD and detached HEAD demonstration
- Readable commit history using conventional commits

All files are Terraform-style config files and YAML — no real credentials or company code.

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
│   ├── conflict-resolution.md    # Conflict evidence and resolution log
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
| `release/v1.0` | Release candidate with hotfix | main + cherry-pick |
| `experiment/detached-head-demo` | HEAD concept demonstration | old commit (detached HEAD) |

---

## Commands Used

See [`docs/command-log.md`](docs/command-log.md) for the full annotated command log.

Key commands used:
```bash
git init / git add / git commit
git checkout -b / git switch -c
git remote add origin / git push -u origin
git merge / git rebase
git cherry-pick <sha>
git log --oneline --graph --decorate --all
git reflog --date=relative
git branch -a / git branch -vv
git remote -v
git fetch origin
git status / git diff / git show
```

---

## Conflict Created and How It Was Solved

**Location:** `app/config.yaml`

**How it was created:** Both `main` and `feature/add-staging-config` edited the same lines:
- `service.version`
- `logging.level`
- `timeout.request_timeout`
- `environment`

**How it was resolved:**
```
<<<<<<< HEAD (feature/add-staging-config)
  version: "1.1.0"
=======
  version: "2.0.0"
>>>>>>> main
```

**Decision:** Accepted `version: "2.0.0"` from main (never go backward on version numbers). Kept `environment: staging` and `logging.level: debug` from the feature branch since this is the staging config branch.

Full evidence in [`docs/conflict-resolution.md`](docs/conflict-resolution.md).

---

## Cherry-pick Explanation

**What it is:** `git cherry-pick <sha>` applies a single commit from one branch onto another without merging the whole branch.

**What was done:**
1. Created `hotfix/prod-timeout` from `main`
2. Fixed `prod.tfvars` — increased `request_timeout` from 15 to 30
3. Committed the fix: SHA `a505bfe7c3525087e4f3b9084d0bc5ed323bdb88`
4. Created `release/v1.0` from `main`
5. Cherry-picked the hotfix commit into `release/v1.0`

**Why:** The release branch was not ready to absorb all of main. Cherry-pick allowed the critical timeout fix to reach the release without pulling in unrelated changes.

```bash
git cherry-pick a505bfe7c3525087e4f3b9084d0bc5ed323bdb88
```

---

## Back-merge Explanation

**What it is:** Merging `main` into a long-running feature branch to keep it current.

**What was done:** After `main` diverged (with the `fix: update main service config` commit), `main` was merged into `feature/add-staging-config`.

**Why teams do this:**
- Reduces final PR merge conflict complexity
- Catches integration issues early when they are smaller
- Ensures CI on the feature branch reflects real integration state
- Makes reviewer's job easier — fewer surprises at merge time

```bash
git checkout feature/add-staging-config
git fetch origin
git merge origin/main
```

---

## Rebase Explanation

**What it is:** `git rebase <branch>` replays your commits on top of another branch's tip, creating a linear history.

**What was done:**
1. Created `feature/rename-service` from `main`
2. Made 2 commits (rename service, update docs)
3. `main` received another commit while feature branch existed
4. Ran `git rebase main` on `feature/rename-service`
5. Git replayed both feature commits on top of updated main — no merge commit created

**Merge vs Rebase:**
| Merge | Rebase |
|-------|--------|
| Creates merge commit | Linear history, no merge commit |
| Preserves exact history | Rewrites commit SHAs |
| Safe on shared branches | Only use on private/local branches |

**Rule:** Never rebase branches that others are using (e.g., `main`, shared feature branches).

---

## HEAD and Detached HEAD Explanation

### HEAD
`HEAD` is a pointer to your current position in the repository.
- Normally: `HEAD → main → <latest commit SHA>`
- You can verify: `cat .git/HEAD` → shows `ref: refs/heads/main`

### Branch Pointer
A branch is just a file in `.git/refs/heads/` containing a commit SHA. When you commit, the branch pointer advances automatically.

### Detached HEAD
Occurs when HEAD points directly to a commit SHA instead of a branch name.

**How to enter:**
```bash
git checkout 17f5767   # an old commit SHA
# HEAD is now detached at 17f5767
```

**Risk:** Commits made in detached HEAD are not on any branch. Git will garbage-collect them eventually.

**Safe practice:**
```bash
git switch -c experiment/detached-head-demo   # save work to a new branch
git checkout main                              # return to normal state
```

### HEAD~1, HEAD~2
- `HEAD~1` — one commit before HEAD
- `HEAD~2` — two commits before HEAD
- `ORIG_HEAD` — set before merges/rebases, used to undo: `git reset --hard ORIG_HEAD`

---

## Origin / Local / Remote Branch Explanation

| Term | What it is |
|------|-----------|
| `origin` | Alias for the remote repository URL (GitHub/GitLab) |
| `main` | Your local branch — moves with your commits |
| `origin/main` | Remote-tracking ref — snapshot of what origin had at last `git fetch` |
| Remote branch | A branch on the remote server; viewed via `git branch -r` |

**Key behavior:**
- `git fetch` updates `origin/main` without touching local `main`
- `git pull` = `git fetch` + `git merge origin/main`
- `git push -u origin main` sets up upstream tracking so `git push` works without arguments

---

## Final Git Graph

```
* ca25ee5 (experiment/detached-head-demo) docs: add comprehensive git-notes
| * f18193d (feature/rename-service) docs: update git-notes for service rename
| * fee933b feat: rename service from platform-service to infra-platform-service
| * 36ae6c4 (HEAD -> main) feat: add service_name variable to infra variables
| | * a505bfe (release/v1.0, hotfix/prod-timeout) fix: increase prod request_timeout
| |/
| | * ab1cd6f (feature/add-staging-config) docs: add conflict resolution evidence
| | *   30ccb26 fix: resolve merge conflict — keep v2.0.0, staging env, debug logging
| | |\
| | |/
| |/|
| * | 1b407ce fix: update main service config to version 2.0.0 and production timeouts
|/ /
| * 46abaea feat: add staging feature flags and enable new_dashboard for staging
| * 189728c feat: add staging feature flags
|/
* 17f5767 feat: initial project structure with app config, infra, and docs
```

---

## Branch Tracking Output

```
  experiment/detached-head-demo  ca25ee5 docs: add comprehensive git-notes
  feature/add-staging-config     ab1cd6f docs: add conflict resolution evidence
  feature/rename-service         f18193d docs: update git-notes for service rename
  hotfix/prod-timeout            a505bfe fix: increase prod request_timeout
* main                           36ae6c4 feat: add service_name variable
  release/v1.0                   a505bfe fix: increase prod request_timeout
```

---

## Lessons Learned

1. **Commit atomically** — one logical change per commit makes cherry-pick and revert safe
2. **Back-merge early** — merging main into feature branches regularly prevents mega-conflicts at PR time
3. **Never rebase shared branches** — rebase rewrites SHAs; if others have pulled the old SHAs, history diverges badly
4. **Detached HEAD is not dangerous** if you create a branch before leaving it
5. **Cherry-pick is surgical** — it copies one commit's diff, not the whole branch; perfect for hotfixes
6. **`git reflog` is your safety net** — even after bad resets, reflog can recover lost commits
7. **Conflict resolution requires understanding intent** — reading both sides before choosing is critical
8. **Use `git fetch` before `git merge`** — always fetch first to get the latest remote state
9. **Conventional commits** (feat:, fix:, docs:) make `git log` readable and enable changelog automation
10. **`ORIG_HEAD` saves you** after any rebase or merge — always know you can `git reset --hard ORIG_HEAD`

---

## Revert vs Reset vs Restore

| Command | Effect | Shared Branch Safe? |
|---------|--------|---------------------|
| `git revert <sha>` | New commit undoing the change | ✅ Yes |
| `git reset --hard HEAD~1` | Moves HEAD back, deletes commits | ❌ Never on shared |
| `git reset --soft HEAD~1` | Moves HEAD back, keeps changes staged | ⚠️ Only local |
| `git restore <file>` | Discards unstaged file changes | ✅ Local only |

**Rule:** On `main` or any shared branch, always use `revert`. Use `reset` only on local, unshared branches.

