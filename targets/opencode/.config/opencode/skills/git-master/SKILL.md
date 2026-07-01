---
name: git-master
description: Git expert. Detects commit styles, splits atomic commits, formulates rebase strategies. Use for commits, history searches, branch management.
category: development
risk: safe
---

# Git Master Skill

Three specializations for git operations. Choose the right one for the task.

## Specialization 1: Commit Architect

Split large changes into atomic, well-structured commits.

### Detection

First, detect the commit style from recent history:

```bash
git log --oneline -20
```

Look for:
- Prefix style: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`
- Message length (short vs detailed)
- Whether body is used

### Atomic Commit Rules

1. **One logical change per commit** — Don't mix formatting with features
2. **Dependency ordering** — Tests before implementation, types before usage
3. **Each commit must pass tests** — No broken commits in history
4. **Conventional commits** — Match the project's existing style

### Commit Sequence Pattern

When implementing a feature:

```
1. test: add failing tests for [feature]
2. feat: implement [feature]
3. refactor: clean up [related code]
4. docs: update documentation for [feature]
```

### Commands

```bash
# Stage specific files
git add path/to/file1 path/to/file2

# Stage partial changes
git add -p  # interactive hunk selection

# Commit with message
git commit -m "feat: add user authentication"

# Amend last commit (before push)
git commit --amend

# Split last commit
git reset HEAD~1 --soft
git add -p
git commit -m "part 1"
git add .
git commit -m "part 2"
```

## Specialization 2: Rebase Surgeon

Rewrite history, resolve conflicts, clean up branches.

### Interactive Rebase

```bash
# Rebase last 5 commits
git rebase -i HEAD~5

# In the editor:
# pick   = keep commit
# reword = keep commit, edit message
# squash = merge with previous
# fixup  = merge with previous, discard message
# drop   = remove commit
```

### Conflict Resolution

```bash
# During rebase, when conflicts occur:
git status          # see conflicting files
git diff            # see conflict markers
# Edit files to resolve
git add <resolved>
git rebase --continue

# Or abort if needed
git rebase --abort
```

### Branch Cleanup

```bash
# Delete merged branches
git branch --merged main | grep -v main | xargs git branch -d

# Force delete unmerged (careful!)
git branch -D <branch>

# Prune remote tracking branches
git remote prune origin
```

### Common Patterns

```bash
# Squash last 3 commits into one
git reset --soft HEAD~3
git commit -m "feat: complete feature X"

# Rebase onto main (update feature branch)
git rebase main

# Cherry-pick specific commits
git cherry-pick <commit-hash>

# Revert a commit (safe, creates new commit)
git revert <commit-hash>
```

## Specialization 3: History Archaeologist

Find when code was introduced, who wrote it, why it changed.

### Find When Code Was Added

```bash
# When was a specific function added?
git log -p -S "function_name" -- path/to/file

# When was a line pattern added?
git log -p -G "regex_pattern" -- path/to/file

# Show commits that touched a file
git log --oneline -- path/to/file

# Show commits in date range
git log --oneline --after="2026-01-01" --before="2026-06-01"
```

### Find Who Wrote What

```bash
# Blame a file
git blame path/to/file

# Blame with line range
git blame -L 10,20 path/to/file

# Blame ignore revisions (skip formatting commits)
git blame -I <commit-list> path/to/file
```

### Search Commit Messages

```bash
# Find commits by message
git log --oneline --grep="auth"
git log --oneline --grep="fix" --grep="bug" --all-match

# Find commits by author
git log --oneline --author="v1XP"

# Find merge commits
git log --oneline --merges
```

### Graphify Integration

Use graphify for codebase context before git archaeology:

```bash
# Understand the codebase structure
graphify query "show the auth module" --graph graphify-out/graph.json

# Then investigate git history
git log -p -- src/auth/
```

## Rules

1. **Always check `git status`** before any git operation
2. **Never force push without explicit confirmation** from user
3. **Use `git diff`** to review changes before committing
4. **Atomic commits**: one logical change per commit
5. **Conventional commits**: match project style
6. **Preserve history**: prefer revert over reset for shared branches
7. **Verify after rebase**: run tests before pushing

## When to Use This Skill

- Writing commit messages
- Splitting large changes into commits
- Resolving merge conflicts
- Cleaning up branch history
- Finding when code was introduced
- Investigating who wrote specific code
- Searching git history for patterns

## Integration with Graphify

When doing history archaeology:

1. Use `graphify query` to understand codebase structure
2. Use git commands to investigate history
3. Use `graphify query "show dependencies for [module]"` to understand impact

This gives you both the "what" (graphify) and the "when/who" (git).
