---
description: Auto-fix lint, type, or build errors
---

# Auto-Fix

1. Detect project type (package.json, tsconfig, etc.)
2. Run appropriate verification commands:
   - TypeScript: `npx tsc --noEmit`
   - ESLint: `npx eslint . --fix`
   - Prettier: `npx prettier --write .`
   - Python: `ruff check --fix` or `python -m py_compile`
3. Analyze remaining errors
4. Automatically fix each error
5. Re-verify until everything passes

Do not stop while there are fixable errors.
