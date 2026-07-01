---
name: tdd-workflow
description: Test-Driven Development workflow. Write tests first, then implement, then refactor. Triggers when user mentions TDD, test-first, red-green-refactor, or testing workflow.
category: development
risk: safe
---

# TDD Workflow Skill

## Overview

This skill enforces Test-Driven Development (TDD) — write tests first, then implement, then refactor. This approach reduces bugs, improves code design, and gives you confidence to make changes.

## The TDD Cycle

### 1. RED — Write a Failing Test

Before writing ANY implementation code:

1. Understand the requirement
2. Write a test that defines the expected behavior
3. Run the test — it MUST fail (red)
4. If the test passes, it's not testing the right thing

```bash
# Run tests to confirm they fail
uv run pytest  # or npm test, go test, etc.
```

### 2. GREEN — Write Minimal Implementation

Write the simplest code that makes the test pass:

1. Write the minimum code to satisfy the test
2. Don't worry about elegance yet
3. Run the test — it MUST pass (green)
4. Commit this step

### 3. REFACTOR — Improve the Code

Now that you have tests passing:

1. Improve the code structure
2. Remove duplication
3. Enhance readability
4. Run tests again — they MUST still pass
5. Commit this step

## Rules

### Before Starting
- [ ] Understand the requirement fully
- [ ] Identify edge cases and error conditions
- [ ] Check if similar tests already exist

### During RED Phase
- [ ] Test describes the behavior, not implementation
- [ ] Test covers the happy path
- [ ] Test covers edge cases
- [ ] Test covers error conditions
- [ ] Test FAILS before implementation

### During GREEN Phase
- [ ] Write minimal code to pass
- [ ] Don't over-engineer
- [ ] All tests pass
- [ ] Code compiles/builds

### During REFACTOR Phase
- [ ] Remove duplication (DRY)
- [ ] Improve naming
- [ ] Extract functions if needed
- [ ] Simplify logic
- [ ] All tests still pass

## Common Patterns

### Unit Test Template
```python
def test_[feature]_[scenario]():
    # Arrange
    input_data = setup_test_data()
    
    # Act
    result = function_under_test(input_data)
    
    # Assert
    assert result == expected_output
```

### Integration Test Template
```python
def test_[feature]_integration():
    # Setup
    service = create_test_service()
    
    # Execute
    result = service.process_request(test_request)
    
    # Verify
    assert result.status == "success"
    assert result.data is not None
```

## Anti-Patterns to Avoid

1. **Testing implementation details** — Test behavior, not internals
2. **Writing tests after code** — Always test first
3. **Skipping the red phase** — If test passes immediately, it's not testing enough
4. **Over-mocking** — Mock only external dependencies
5. **Giant test functions** — One assertion per concept

## When to Use This Skill

- Adding new features
- Fixing bugs (write test that reproduces bug first)
- Refactoring existing code
- Any time you're about to write implementation code

## Success Criteria

- [ ] All tests pass
- [ ] Test coverage is reasonable (>80% for new code)
- [ ] No test is skipped without justification
- [ ] Code is clean and well-structured
- [ ] You can explain what each test verifies
