#!/bin/bash

# Quick redeploy script after fixing build issues
# Run this on the server

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    QUICK REDEPLOY                            ║"
echo "║                  After Build Fixes                           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

print_status "Stopping existing containers..."
docker-compose -f docker-compose.prod.yml down

print_status "Removing old images to force rebuild..."
docker-compose -f docker-compose.prod.yml build --no-cache frontend

print_status "Starting all services..."
docker-compose -f docker-compose.prod.yml up -d

print_status "Waiting for services to be ready..."
sleep 30

print_status "Checking service health..."

# Check API
if curl -f http://localhost:8000/health &>/dev/null; then
    print_success "✅ API is healthy"
else
    print_error "❌ API health check failed"
fi

# Check Frontend
if curl -f http://localhost:3000 &>/dev/null; then
    print_success "✅ Frontend is healthy"
else
    print_error "❌ Frontend health check failed"
fi

print_status "Checking container status:"
docker-compose -f docker-compose.prod.yml ps

echo ""
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    REDEPLOY COMPLETE!                        ║"
echo "║                                                              ║"
echo "║  Your application should now be available at:                ║"
echo "║  🌐 Frontend: http://103.143.148.190                        ║"
echo "║  🔧 API: http://103.143.148.190:8000                        ║"
echo "║  📚 API Docs: http://103.143.148.190:8000/docs              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
