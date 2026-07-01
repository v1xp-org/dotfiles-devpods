---
description: Review uncommitted changes — diffs, suggestions, security, quality
---

Run these commands to gather all uncommitted changes:

```bash
# Unstaged changes
git diff

# Staged changes
git diff --cached

# Summary of changes
git status --porcelain
```

Then review the output for:

## 1. Security Issues
- Hardcoded secrets, API keys, tokens
- Credentials in config files
- Sensitive data in logs

## 2. Code Quality
- Naming conventions (consistent with codebase)
- Code duplication
- Function length (>50 lines?)
- Error handling
- Magic numbers/strings

## 3. Test Coverage
- Are new features tested?
- Are edge cases covered?
- Are error paths tested?

## 4. Documentation
- Are public APIs documented?
- Are complex functions explained?
- Are TODOs tracked?

## 5. Commit Readiness
- Can these changes be split into atomic commits?
- What's the recommended commit message?
- Should any changes be staged vs unstaged?

## Output Format

```
## Security
[issues found or "No security issues detected"]

## Code Quality
[suggestions]

## Test Coverage
[gaps or "Tests look good"]

## Documentation
[gaps or "Documentation looks good"]

## Commit Recommendation
Suggested commit message:
feat: [description]

Files to stage: [list]
Files to leave unstaged: [list]
```

Be concise. Focus on actionable feedback. Don't repeat what's already good.
