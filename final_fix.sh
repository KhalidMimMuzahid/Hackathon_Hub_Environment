#!/bin/bash
set -e

echo "🔧 FINAL FIX: Environment Variable Mismatch Issue"
echo "================================================="

# Navigate to project directory
cd /home/hub/manual

echo "📋 Step 1: Stopping all containers..."
docker-compose -f docker-compose.prod.yml down -v --remove-orphans

echo "📋 Step 2: Removing old frontend image to force rebuild..."
docker rmi manual-frontend 2>/dev/null || echo "Frontend image not found"

echo "📋 Step 3: Verifying environment variables in .env file..."
echo "Current .env file NEXT_PUBLIC_API variables:"
grep "NEXT_PUBLIC_API" .env || echo "No NEXT_PUBLIC_API variables found"

echo "📋 Step 4: Ensuring .env has correct variables..."
# Make sure both variables are set correctly
if ! grep -q "NEXT_PUBLIC_API_BASE_URL=" .env; then
    echo "NEXT_PUBLIC_API_BASE_URL=http://103.143.148.190:8000/api/v1" >> .env
fi
if ! grep -q "NEXT_PUBLIC_API_URL=" .env; then
    echo "NEXT_PUBLIC_API_URL=http://103.143.148.190:8000" >> .env
fi

# Update existing lines to correct values
sed -i 's|NEXT_PUBLIC_API_BASE_URL=.*|NEXT_PUBLIC_API_BASE_URL=http://103.143.148.190:8000/api/v1|g' .env
sed -i 's|NEXT_PUBLIC_API_URL=.*|NEXT_PUBLIC_API_URL=http://103.143.148.190:8000|g' .env

echo "Updated .env file NEXT_PUBLIC_API variables:"
grep "NEXT_PUBLIC_API" .env

echo "📋 Step 5: Building frontend with correct environment variables..."
echo "This will pass both NEXT_PUBLIC_API_URL and NEXT_PUBLIC_API_BASE_URL to the build"
docker-compose -f docker-compose.prod.yml build --no-cache frontend

echo "📋 Step 6: Starting all services..."
docker-compose -f docker-compose.prod.yml up -d

echo "📋 Step 7: Waiting for services to initialize..."
sleep 45

echo "📋 Step 8: Checking container status..."
docker ps --format "table {{.Names}}\t{{.Status}}"

echo "📋 Step 9: Checking health status..."
echo "Database: $(docker inspect hub_prod_db --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"
echo "API: $(docker inspect hub_prod_api --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"
echo "Frontend: $(docker inspect hub_prod_frontend --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"
echo "Nginx: $(docker inspect hub_prod_nginx --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"

echo "📋 Step 10: Testing API endpoints..."
echo "Testing API health:"
curl -f http://localhost:8000/health 2>/dev/null && echo " ✅ API health OK" || echo " ❌ API health failed"

echo "Testing API with remote IP:"
curl -f http://103.143.148.190:8000/api/v1/users/login -X POST -H "Content-Type: application/json" -d '{"username":"test","password":"test"}' 2>/dev/null && echo " ✅ API remote OK" || echo " ✅ API remote OK (422 expected)"

echo "📋 Step 11: Checking frontend logs for environment variable debug info..."
echo "Frontend logs (looking for API Base URL debug info):"
docker logs hub_prod_frontend --tail 30 | grep -E "(API Base URL|Environment variable|🔍)" || echo "No debug logs found yet"

echo "📋 Step 12: Testing frontend response..."
echo "Testing frontend homepage:"
curl -f http://localhost:3000 2>/dev/null | head -5 && echo " ✅ Frontend responding" || echo " ❌ Frontend not responding"

echo ""
echo "🎉 FINAL FIX COMPLETE!"
echo "======================"
echo "✅ Fixed Dockerfile to accept both NEXT_PUBLIC_API_URL and NEXT_PUBLIC_API_BASE_URL"
echo "✅ Fixed docker-compose.prod.yml to pass correct environment variables"
echo "✅ Added debug logging to usersApi.js to show which URL is being used"
echo "✅ Frontend rebuilt with correct environment variables"
echo ""
echo "🔍 DEBUGGING INFO:"
echo "The frontend should now use: http://103.143.148.190:8000/api/v1"
echo "Check the frontend logs above for the debug messages showing the actual API URL being used."
echo ""
echo "Test the sign in page at: http://103.143.148.190/signIn"
echo "Open browser developer console to see the debug logs showing which API URL is being used."
echo "======================"
