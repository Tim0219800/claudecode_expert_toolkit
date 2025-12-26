---
description: Generate documentation automatically
---

# Auto Documentation

Generate comprehensive documentation for the project.

## What to generate:

1. **README.md** (if missing or outdated):
   - Project title and description
   - Installation instructions
   - Usage examples
   - API reference (if applicable)
   - Contributing guidelines

2. **API Documentation**:
   - Scan for route handlers
   - Document endpoints, methods, parameters
   - Generate OpenAPI/Swagger if applicable

3. **Code Documentation**:
   - Add JSDoc/docstrings to public functions
   - Document complex algorithms
   - Add type annotations where missing

4. **Architecture Documentation**:
   - Folder structure explanation
   - Component relationships
   - Data flow diagrams (in Mermaid)

## Options:
- `/docs readme` - Generate/update README only
- `/docs api` - Generate API docs only
- `/docs code` - Add inline documentation
- `/docs all` - Generate everything
