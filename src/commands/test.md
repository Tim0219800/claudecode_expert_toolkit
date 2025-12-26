---
description: Run tests and fix failures automatically
---

# Auto Test & Fix

1. **Detect test framework**:
   - Jest (package.json)
   - Vitest (vite.config)
   - Pytest (pytest.ini, pyproject.toml)
   - Go test
   - Cargo test

2. **Run tests**:
   ```bash
   npm test / npx jest / npx vitest run
   pytest
   go test ./...
   cargo test
   ```

3. **Analyze failures**:
   - Parse error messages
   - Identify failing test files
   - Read relevant source code

4. **Fix each failure**:
   - Understand expected vs actual
   - Fix the code (not the test, unless test is wrong)
   - Re-run to verify

5. **Repeat until all tests pass**

Report summary at the end:
- Tests fixed
- Tests still failing (if any)
- Time taken
