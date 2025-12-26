---
description: Intelligent refactoring suggestions and execution
---

# Smart Refactor

Analyze code and suggest/apply refactoring improvements.

## Analysis:
1. **Code Smells**:
   - Long methods (>50 lines)
   - Deep nesting (>3 levels)
   - Duplicate code
   - Large classes
   - Feature envy

2. **Architecture Issues**:
   - Circular dependencies
   - God objects
   - Tight coupling
   - Missing abstractions

3. **Modern Patterns**:
   - Outdated syntax
   - Missing async/await
   - Callback hell
   - Missing TypeScript types

## Output:
For each issue:
- Location (file:line)
- Problem description
- Suggested refactoring
- Risk level (low/medium/high)

## Commands:
- `/refactor` - Analyze and show suggestions
- `/refactor apply` - Apply all safe refactorings
- `/refactor <file>` - Focus on specific file
