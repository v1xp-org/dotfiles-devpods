---
description: Quick git state summary — branches, dirty state, recent commits, stash
---

Run these commands and format the output as a clean summary:

```bash
# Current state
git status --short

# Branches
git branch -a

# Recent history
git log --oneline --graph -15

# Changes summary
git diff --stat

# Stash
git stash list
```

Format the output with clear sections:

## Current State
[git status output]

## Branches
[current branch highlighted, remote branches listed]

## Recent Commits
[graph view]

## Changes Summary
[diff stats]

## Stash
[stash list or "No stashed changes"]

Keep it concise. Focus on what matters:
- Are there uncommitted changes?
- Which branch are we on?
- What changed recently?
- Is there anything stashed?
