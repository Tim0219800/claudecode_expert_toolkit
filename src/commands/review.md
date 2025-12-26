---
description: Professional code review of modified code or a file
---

# Code Review

Perform a professional code review.

If git changes exist (`git diff`), analyze those changes.
Otherwise, analyze the specified file.

## Evaluation Criteria

### Quality
- Readability and clarity
- Convention compliance
- DRY (Don't Repeat Yourself)
- SOLID principles

### Security
- Injection (SQL, XSS, Command)
- Secret management
- Input validation
- Authentication/Authorization

### Performance
- Algorithmic complexity
- N+1 queries
- Memory leaks
- Missed optimizations

### Maintainability
- Tests present
- Documentation
- Error handling
- Logging

## Output Format

For each issue found:
- [CRITICAL/WARNING/INFO] Description
- File:line
- Suggested fix

End with an overall score /10 and positive points.
