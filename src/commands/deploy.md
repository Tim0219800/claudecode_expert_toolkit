---
description: Automated deployment workflow
---

# Deploy

Automated deployment workflow with safety checks.

## Pre-deploy Checks:
1. ✓ All tests passing
2. ✓ No TypeScript/lint errors
3. ✓ No uncommitted changes
4. ✓ On correct branch (main/master)
5. ✓ Build successful

## Deployment Steps:

### Detect Platform:
- Vercel (vercel.json)
- Netlify (netlify.toml)
- Railway (railway.json)
- Docker (Dockerfile)
- Custom (package.json scripts)

### Execute:
```bash
# Example for Vercel
vercel --prod

# Example for Docker
docker build -t app .
docker push registry/app:latest
```

## Commands:
- `/deploy` - Deploy to production
- `/deploy preview` - Deploy preview/staging
- `/deploy status` - Check deployment status
- `/deploy rollback` - Rollback to previous version

## Safety:
- Always run checks first
- Require confirmation for production
- Log deployment details to history
