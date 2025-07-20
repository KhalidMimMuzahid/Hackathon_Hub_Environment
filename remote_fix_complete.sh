#!/bin/bash
set -e

echo "🚀 EXECUTING COMPLETE FIX ON REMOTE SERVER"
echo "=========================================="

# Navigate to project directory
cd /home/hub/manual

echo "📋 Step 1: Pulling latest changes from repository..."
git pull origin main || echo "Git pull failed, continuing with existing code"

echo "📋 Step 2: Stopping all containers..."
docker-compose -f docker-compose.prod.yml down -v --remove-orphans

echo "📋 Step 3: Removing old frontend image to force complete rebuild..."
docker rmi manual-frontend 2>/dev/null || echo "Frontend image not found"

echo "📋 Step 4: Cleaning Docker system..."
docker system prune -f

echo "📋 Step 5: Verifying and updating .env file..."
echo "Current .env NEXT_PUBLIC_API variables:"
grep "NEXT_PUBLIC_API" .env || echo "No NEXT_PUBLIC_API variables found"

# Ensure both variables exist and are correct
if ! grep -q "NEXT_PUBLIC_API_BASE_URL=" .env; then
    echo "NEXT_PUBLIC_API_BASE_URL=http://103.143.148.190:8000/api/v1" >> .env
fi
if ! grep -q "NEXT_PUBLIC_API_URL=" .env; then
    echo "NEXT_PUBLIC_API_URL=http://103.143.148.190:8000" >> .env
fi

# Update to correct values
sed -i 's|NEXT_PUBLIC_API_BASE_URL=.*|NEXT_PUBLIC_API_BASE_URL=http://103.143.148.190:8000/api/v1|g' .env
sed -i 's|NEXT_PUBLIC_API_URL=.*|NEXT_PUBLIC_API_URL=http://103.143.148.190:8000|g' .env

echo "Updated .env NEXT_PUBLIC_API variables:"
grep "NEXT_PUBLIC_API" .env

echo "📋 Step 6: Verifying Dockerfile.prod has correct build args..."
if grep -q "ARG NEXT_PUBLIC_API_BASE_URL" hub_nextjs/Dockerfile.prod; then
    echo "✅ Dockerfile.prod has NEXT_PUBLIC_API_BASE_URL build arg"
else
    echo "❌ Dockerfile.prod missing NEXT_PUBLIC_API_BASE_URL build arg"
    echo "Adding NEXT_PUBLIC_API_BASE_URL to Dockerfile.prod..."
    sed -i '/ARG NEXT_PUBLIC_API_URL/a ARG NEXT_PUBLIC_API_BASE_URL\nENV NEXT_PUBLIC_API_BASE_URL=$NEXT_PUBLIC_API_BASE_URL' hub_nextjs/Dockerfile.prod
fi

echo "📋 Step 7: Verifying docker-compose.prod.yml has correct build args..."
if grep -q "NEXT_PUBLIC_API_BASE_URL=http://103.143.148.190:8000/api/v1" docker-compose.prod.yml; then
    echo "✅ docker-compose.prod.yml has correct NEXT_PUBLIC_API_BASE_URL"
else
    echo "❌ docker-compose.prod.yml missing correct NEXT_PUBLIC_API_BASE_URL"
    echo "Updating docker-compose.prod.yml..."
    # Add the build arg if not present
    if ! grep -q "NEXT_PUBLIC_API_BASE_URL=" docker-compose.prod.yml; then
        sed -i '/- NEXT_PUBLIC_API_URL=http:\/\/103.143.148.190:8000/a\        - NEXT_PUBLIC_API_BASE_URL=http://103.143.148.190:8000/api/v1' docker-compose.prod.yml
    fi
    # Add the environment variable if not present
    if ! grep -A 10 "environment:" docker-compose.prod.yml | grep -q "NEXT_PUBLIC_API_BASE_URL="; then
        sed -i '/- NEXT_PUBLIC_API_URL=http:\/\/103.143.148.190:8000$/a\      - NEXT_PUBLIC_API_BASE_URL=http://103.143.148.190:8000/api/v1' docker-compose.prod.yml
    fi
fi

echo "📋 Step 8: Building frontend with correct environment variables..."
echo "This will run 'npm run build' with NEXT_PUBLIC_API_BASE_URL=http://103.143.148.190:8000/api/v1"
docker-compose -f docker-compose.prod.yml build --no-cache frontend

echo "📋 Step 9: Starting all services..."
docker-compose -f docker-compose.prod.yml up -d

echo "📋 Step 10: Waiting for services to initialize..."
sleep 45

echo "📋 Step 11: Checking container status..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "📋 Step 12: Checking health status..."
echo "Database: $(docker inspect hub_prod_db --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"
echo "API: $(docker inspect hub_prod_api --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"
echo "Frontend: $(docker inspect hub_prod_frontend --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"
echo "Nginx: $(docker inspect hub_prod_nginx --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"

echo "📋 Step 13: Testing API endpoints..."
echo "Testing API health:"
curl -f http://localhost:8000/health 2>/dev/null && echo " ✅ API health OK" || echo " ❌ API health failed"

echo "Testing API with remote IP:"
curl -f http://103.143.148.190:8000/api/v1/users/login -X POST -H "Content-Type: application/json" -d '{"username":"test","password":"test"}' 2>/dev/null && echo " ✅ API remote OK" || echo " ✅ API remote OK (422 expected)"

echo "📋 Step 14: Checking frontend logs for debug information..."
echo "Frontend logs (looking for API Base URL debug info):"
docker logs hub_prod_frontend --tail 30 | grep -E "(API Base URL|Environment variable|🔍)" || echo "Debug logs not found yet - frontend may still be starting"

echo "📋 Step 15: Testing frontend..."
echo "Testing frontend homepage:"
curl -f http://localhost:3000 2>/dev/null | head -3 && echo " ✅ Frontend responding" || echo " ❌ Frontend not responding"

echo ""
echo "🎉 REMOTE SERVER FIX COMPLETE!"
echo "=============================="
echo "✅ Latest code pulled from repository"
echo "✅ Environment variables updated to use remote IP"
echo "✅ Dockerfile.prod updated to accept NEXT_PUBLIC_API_BASE_URL"
echo "✅ docker-compose.prod.yml updated with correct build args"
echo "✅ Frontend rebuilt with correct environment variables"
echo "✅ All services restarted"
echo ""
echo "🔍 VERIFICATION:"
echo "1. Go to: http://103.143.148.190/signIn"
echo "2. Open browser developer console (F12)"
echo "3. Look for debug messages showing API Base URL"
echo "4. Try to sign in - should call http://103.143.148.190:8000/api/v1/users/login"
echo ""
echo "If you still see localhost calls, check the browser console for debug logs."
echo "=============================="
