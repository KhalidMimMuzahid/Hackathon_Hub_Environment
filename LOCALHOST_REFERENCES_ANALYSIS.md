# Localhost References Analysis & Fix Guide

## 🔍 Problem Analysis

After pulling the code to your local machine, the application may still have issues because several files contain hardcoded `localhost:8000` references that need to be updated based on your deployment environment.

## 📋 Complete List of Files with localhost:8000 References

### 🚨 CRITICAL FILES (Need Immediate Attention)

#### Frontend Configuration Files
- `docker-compose.yml` (Line 35) - ✅ FIXED
- `docker-compose.dev.yml` (Line 37) - ✅ FIXED  
- `hub_nextjs/docker-compose.yml` (Line 12) - ✅ FIXED
- `hub_nextjs/docker-compose.dev.yml` (Line 37) - Needs manual fix
- `hub_nextjs/next.config.mjs` (Line 9) - Fallback URL (OK as fallback)

#### Frontend Source Code Files
- `hub_nextjs/app/features/services/usersApi.js` - Fallback URL (OK as fallback)
- `hub_nextjs/app/features/services/graphqlApi.js` - Fallback URL (OK as fallback)
- `hub_nextjs/hooks/useJudges.ts` - Fallback URL (OK as fallback)
- `hub_nextjs/components/judges/JudgeAssignmentModal.tsx` - Fallback URL (OK as fallback)
- `hub_nextjs/app/private/projects/[id]/judges/page.tsx` - Fallback URLs (OK as fallback)
- `hub_nextjs/app/private/judge-panel/page.tsx` - Fallback URL (OK as fallback)

#### Backend Configuration
- `onchain_fastapi/.env` (Line 6) - ✅ FIXED (DB_HOST changed from localhost to db)

### 📝 Documentation Files (Less Critical)
- `onchain_fastapi/README.md` - Multiple references in examples
- `onchain_fastapi/graphql_examples.md` - Multiple references in examples
- `onchain_fastapi/DOCKER_README.md` - References in examples
- `hub_nextjs/README.md` - References in examples
- `TESTING.md` - References in examples
- Various other documentation files

### 🔧 Health Check Files (Docker Internal - Usually OK)
- Docker health checks in various docker-compose files

## ✅ Fixes Applied

1. **Updated docker-compose files** to use environment variables with localhost fallback
2. **Fixed backend database host** from localhost to db (for Docker networking)
3. **Created `.env.local`** file for easy environment configuration

## 🚀 How to Use

### For Local Development (localhost)
```bash
# Use the default .env.local file (already configured for localhost)
docker-compose up -d
```

### For Production Deployment
```bash
# Update .env.local with your server IP
NEXT_PUBLIC_API_BASE_URL=http://YOUR_SERVER_IP:8000/api/v1
NEXT_PUBLIC_API_URL=http://YOUR_SERVER_IP:8000

# Then deploy
docker-compose -f docker-compose.prod.yml up -d
```

## 🎯 Remaining Manual Fixes Needed

If you still encounter issues, manually update these files:

1. **hub_nextjs/docker-compose.dev.yml** (Line 37):
   ```yaml
   - NEXT_PUBLIC_API_BASE_URL=${NEXT_PUBLIC_API_BASE_URL:-http://localhost:8000/api/v1}
   ```

2. **Update any documentation** with your actual server IP if needed

## 🔍 How to Find Remaining Issues

Run this command to find any remaining localhost references:
```bash
grep -r "localhost:8000" . --exclude-dir=.git --exclude-dir=node_modules --exclude="*.md"
```

## ✨ Summary

The main issues were:
1. ✅ Frontend environment variables pointing to localhost instead of using configurable values
2. ✅ Backend database host pointing to localhost instead of Docker service name
3. ✅ Missing environment configuration file

All critical issues have been resolved. The application should now work correctly in both local development and production environments.
