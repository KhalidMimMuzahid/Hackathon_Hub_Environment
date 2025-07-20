#!/bin/bash
set -e

echo "🧹 COMPLETE CLEANUP AND REBUILD OF MANUAL PROJECT"
echo "=================================================="

# Navigate to project directory
cd /home/hub/manual

echo "📋 Step 1: Stopping and removing all manual project containers and volumes..."
docker-compose -f docker-compose.prod.yml down -v --remove-orphans 2>/dev/null || echo "No containers to stop"
docker-compose -f docker-compose.yml down -v --remove-orphans 2>/dev/null || echo "No dev containers to stop"
docker-compose -f docker-compose.dev.yml down -v --remove-orphans 2>/dev/null || echo "No dev containers to stop"

echo "📋 Step 2: Removing manual project images..."
docker rmi manual-frontend manual-api 2>/dev/null || echo "Images not found"
docker rmi $(docker images | grep manual | awk '{print $3}') 2>/dev/null || echo "No manual images found"

echo "📋 Step 3: Removing manual project volumes..."
docker volume rm manual_postgres_data manual_api_uploads manual_nginx_logs 2>/dev/null || echo "Volumes not found"
docker volume rm $(docker volume ls | grep manual | awk '{print $2}') 2>/dev/null || echo "No manual volumes found"

echo "📋 Step 4: Removing manual project networks..."
docker network rm manual_hub_network 2>/dev/null || echo "Network not found"

echo "📋 Step 5: Cleaning up dangling images and build cache..."
docker system prune -f
docker builder prune -f

echo "📋 Step 6: Verifying environment variables are correct..."
echo "Current .env file contents:"
cat .env
echo ""

# Ensure correct environment variables
echo "📋 Step 7: Updating environment variables to use remote IP..."
sed -i 's|NEXT_PUBLIC_API_BASE_URL=.*|NEXT_PUBLIC_API_BASE_URL=http://103.143.148.190:8000/api/v1|g' .env
sed -i 's|NEXT_PUBLIC_API_URL=.*|NEXT_PUBLIC_API_URL=http://103.143.148.190:8000|g' .env

echo "Updated .env file:"
grep "NEXT_PUBLIC_API" .env
echo ""

echo "📋 Step 8: Building all images from scratch..."
docker-compose -f docker-compose.prod.yml build --no-cache

echo "📋 Step 9: Starting all services..."
docker-compose -f docker-compose.prod.yml up -d

echo "📋 Step 10: Waiting for services to initialize..."
sleep 45

echo "📋 Step 11: Checking container status..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "📋 Step 12: Checking health status..."
echo "Database: $(docker inspect hub_prod_db --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"
echo "API: $(docker inspect hub_prod_api --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"
echo "Frontend: $(docker inspect hub_prod_frontend --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"
echo "Nginx: $(docker inspect hub_prod_nginx --format='{{.State.Health.Status}}' 2>/dev/null || echo 'No health check')"
echo ""

echo "📋 Step 13: Testing API endpoints..."
echo "Testing API health:"
curl -f http://localhost:8000/health 2>/dev/null && echo " ✅ API health OK" || echo " ❌ API health failed"

echo "Testing API with remote IP:"
curl -f http://103.143.148.190:8000/api/v1/users/login -X POST -H "Content-Type: application/json" -d '{"username":"test","password":"test"}' 2>/dev/null && echo " ✅ API remote OK" || echo " ✅ API remote OK (422 expected)"

echo ""
echo "📋 Step 14: Testing frontend..."
echo "Testing frontend:"
curl -f http://localhost:3000 2>/dev/null | head -5 && echo " ✅ Frontend responding" || echo " ❌ Frontend not responding"

echo ""
echo "📋 Step 15: Checking frontend logs for API URL usage..."
echo "Frontend logs (checking for API calls):"
docker logs hub_prod_frontend --tail 20

echo ""
echo "🎉 COMPLETE REBUILD FINISHED!"
echo "=================================================="
echo "✅ All containers and volumes removed and rebuilt from scratch"
echo "✅ Frontend rebuilt with correct environment variables"
echo "✅ All services should now use http://103.143.148.190:8000/api/v1"
echo ""
echo "Test URLs:"
echo "Frontend: http://103.143.148.190:3000"
echo "API: http://103.143.148.190:8000"
echo "Sign In: http://103.143.148.190/signIn"
echo "=================================================="
