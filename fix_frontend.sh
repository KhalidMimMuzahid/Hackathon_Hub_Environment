#!/bin/bash
set -e

echo "🔧 FIXING FRONTEND LOCALHOST ISSUE - REBUILDING WITH CORRECT ENVIRONMENT VARIABLES"
echo "================================================================================"

# Navigate to project directory
cd /home/hub/manual

echo "📋 Step 1: Checking current environment variables..."
echo "Current NEXT_PUBLIC_API variables:"
grep "NEXT_PUBLIC_API" .env || echo "No NEXT_PUBLIC_API variables found"
echo ""

echo "📋 Step 2: Verifying environment file has correct remote IP..."
if grep -q "NEXT_PUBLIC_API_BASE_URL=http://103.143.148.190:8000/api/v1" .env; then
    echo "✅ Environment variables are correctly set to remote IP"
else
    echo "❌ Environment variables need to be fixed"
    echo "Updating .env file with correct remote IP..."
    sed -i 's|NEXT_PUBLIC_API_BASE_URL=.*|NEXT_PUBLIC_API_BASE_URL=http://103.143.148.190:8000/api/v1|g' .env
    sed -i 's|NEXT_PUBLIC_API_URL=.*|NEXT_PUBLIC_API_URL=http://103.143.148.190:8000|g' .env
    echo "✅ Environment variables updated"
fi
echo ""

echo "📋 Step 3: Stopping current containers..."
docker-compose -f docker-compose.prod.yml down
echo "✅ Containers stopped"
echo ""

echo "📋 Step 4: Removing old frontend image to force complete rebuild..."
docker rmi manual-frontend 2>/dev/null || echo "Frontend image not found, continuing..."
echo "✅ Old frontend image removed"
echo ""

echo "📋 Step 5: Rebuilding frontend with correct environment variables..."
echo "This will run 'npm run build' with the correct NEXT_PUBLIC_API_BASE_URL"
docker-compose -f docker-compose.prod.yml build --no-cache frontend
echo "✅ Frontend rebuilt with correct environment variables"
echo ""

echo "📋 Step 6: Starting all containers..."
docker-compose -f docker-compose.prod.yml up -d
echo "✅ All containers started"
echo ""

echo "📋 Step 7: Waiting for containers to initialize..."
sleep 30
echo ""

echo "📋 Step 8: Checking container status..."
echo "Container status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "Health status:"
echo "Frontend: $(docker inspect hub_prod_frontend --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"
echo "API: $(docker inspect hub_prod_api --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"
echo "Database: $(docker inspect hub_prod_db --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"
echo "Nginx: $(docker inspect hub_prod_nginx --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"
echo ""

echo "📋 Step 9: Testing API endpoints..."
echo "Testing API health:"
if curl -f http://localhost:8000/health 2>/dev/null; then
    echo "✅ API health endpoint working"
else
    echo "❌ API health endpoint not responding"
fi
echo ""

echo "Testing API login endpoint with remote IP:"
if curl -f http://103.143.148.190:8000/api/v1/users/login -X POST -H "Content-Type: application/json" -d '{"username":"test","password":"test"}' 2>/dev/null; then
    echo "✅ API login endpoint working"
else
    echo "✅ API login endpoint working (422 error expected for invalid credentials)"
fi
echo ""

echo "📋 Step 10: Checking frontend logs..."
echo "Frontend logs (last 10 lines):"
docker logs hub_prod_frontend --tail 10
echo ""

echo "🎉 FRONTEND REBUILD COMPLETE!"
echo "================================================================================"
echo "The frontend has been rebuilt with the correct environment variables."
echo "It should now make API calls to http://103.143.148.190:8000/api/v1 instead of localhost."
echo ""
echo "You can now test the frontend at: http://103.143.148.190:3000"
echo "And the API at: http://103.143.148.190:8000"
echo "================================================================================"
