# Git Notes — Key Concepts

## HEAD
`HEAD` is a special pointer that points to the currently checked-out commit.
- Normally, HEAD points to a **branch name** (e.g., `refs/heads/main`)
- When you `git checkout main`, HEAD → main → latest commit on main

## Branch Pointer
A branch like `main` is just a lightweight pointer (file) that stores a commit SHA.
When you commit, the branch pointer moves forward automatically.

## Detached HEAD
Detached HEAD occurs when HEAD points **directly to a commit SHA** instead of a branch.

### How to enter detached HEAD:
```bash
git checkout <old-commit-sha>
```

### Risk:
Any commits made in detached HEAD state are **not tracked by any branch**.
They will be garbage collected unless you create a branch.

### Safe recovery:
```bash
git switch -c experiment/detached-head-demo   # save your work
git checkout main                              # return to normal
```

## HEAD~1 and Ancestry
- `HEAD~1` = one commit before HEAD
- `HEAD~2` = two commits before HEAD
- `HEAD^` = same as HEAD~1 (first parent)

## ORIG_HEAD
`ORIG_HEAD` is set automatically before risky operations like merge or rebase.
It lets you undo: `git reset --hard ORIG_HEAD`

## origin/main vs local main
| Concept | Description |
|---------|-------------|
| `main` | Your local branch |
| `origin/main` | Remote-tracking ref — snapshot of what origin had at last fetch |
| `origin` | The remote repository (e.g., GitHub) |

These can diverge. `git fetch` updates `origin/main` without touching local `main`.

## Rebase vs Merge
| Merge | Rebase |
|-------|--------|
| Creates a merge commit | Replays commits on top of base |
| Preserves full history | Creates linear history |
| Safe for shared branches | Avoid on shared branches |

## Cherry-pick
Applies one specific commit to another branch.
Useful for applying hotfixes without merging the entire hotfix branch.

## Back-merge
Merging `main` (or another upstream branch) back into a long-running feature branch.
This keeps the feature branch up-to-date and reduces future conflict complexity.

## revert vs reset vs restore
| Command | What it does | Safe for shared branches? |
|---------|-------------|--------------------------|
| `git revert <sha>` | Creates new commit that undoes changes | YES |
| `git reset --hard <sha>` | Moves HEAD backward, discards commits | NO (never on shared) |
| `git restore <file>` | Discards unstaged changes to a file | YES (local only) |
