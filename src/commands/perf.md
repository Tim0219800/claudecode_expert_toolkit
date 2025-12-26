---
description: Performance analysis and optimization suggestions
---

# Performance Analysis

Analyze code for performance issues and suggest optimizations.

## Analysis Areas:

### Algorithm Complexity
- Identify O(n²) or worse operations
- Suggest more efficient alternatives
- Check for unnecessary iterations

### Database/API
- N+1 query patterns
- Missing indexes
- Unbatched operations
- Missing caching opportunities

### Memory
- Large object creation in loops
- Memory leaks (event listeners, subscriptions)
- Unnecessary data copying
- Missing cleanup

### Frontend Specific
- Unnecessary re-renders
- Missing memoization
- Large bundle imports
- Unoptimized images

### Backend Specific
- Blocking operations
- Missing connection pooling
- Synchronous file I/O
- Missing compression

## Output:
```
[HIGH] O(n²) loop in processItems() - src/utils.ts:45
  Current: nested forEach
  Suggested: Use Map for O(1) lookup
  Impact: ~100x faster for 1000 items

[MEDIUM] Missing useMemo - src/components/List.tsx:23
  Expensive computation on every render
  Add: useMemo(() => computeItems(data), [data])
```
