#!/bin/bash

# Simple Server-Side Deployment Script for Hub Application
# Run this script directly on the server after copying the /manual folder

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
APP_NAME="hub"
CURRENT_DIR=$(pwd)

echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    HUB APPLICATION DEPLOYMENT                ║"
echo "║                     Server-Side Setup                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

print_status "Starting deployment in directory: $CURRENT_DIR"

# Check if we're in the right directory
check_directory() {
    print_status "Checking if we're in the correct directory..."
    
    required_files=(
        "docker-compose.prod.yml"
        ".env.prod"
        "onchain_fastapi"
        "hub_nextjs"
        "nginx"
    )
    
    missing_files=()
    
    for file in "${required_files[@]}"; do
        if [[ ! -e "$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -eq 0 ]]; then
        print_success "All required files found!"
    else
        print_error "Missing files/directories:"
        for file in "${missing_files[@]}"; do
            echo "   - $file"
        done
        print_error "Please make sure you're in the /manual directory with all files copied."
        exit 1
    fi
}

# Check Docker installation
check_docker() {
    print_status "Checking Docker installation..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Check if user can run docker without sudo
    if ! docker ps &> /dev/null; then
        print_warning "Cannot run Docker without sudo. Adding current user to docker group..."
        sudo usermod -aG docker $USER
        print_warning "Please log out and log back in, then run this script again."
        exit 1
    fi
    
    print_success "Docker and Docker Compose are installed and accessible!"
}

# Setup environment file
setup_environment() {
    print_status "Setting up environment file..."
    
    if [[ ! -f ".env" ]]; then
        if [[ -f ".env.prod" ]]; then
            cp .env.prod .env
            print_success "Created .env from .env.prod template"
        else
            print_error ".env.prod template not found!"
            exit 1
        fi
    else
        print_warning ".env file already exists, keeping current configuration"
    fi
}

# Stop existing containers
stop_existing() {
    print_status "Stopping any existing containers..."
    
    if docker-compose -f docker-compose.prod.yml ps -q 2>/dev/null | grep -q .; then
        docker-compose -f docker-compose.prod.yml down --remove-orphans
        print_success "Stopped existing containers"
    else
        print_status "No existing containers found"
    fi
}

# Clean up Docker resources
cleanup_docker() {
    print_status "Cleaning up Docker resources..."
    
    # Remove unused images and containers
    docker system prune -f
    
    print_success "Docker cleanup completed"
}

# Build and start application
build_and_start() {
    print_status "Building application images..."
    
    # Build with no cache to ensure fresh build
    docker-compose -f docker-compose.prod.yml build --no-cache
    
    print_success "Build completed successfully!"
    
    print_status "Starting application containers..."
    
    # Start containers in detached mode
    docker-compose -f docker-compose.prod.yml up -d
    
    print_success "Application containers started!"
}

# Wait for services to be ready
wait_for_services() {
    print_status "Waiting for services to be ready..."
    
    # Wait for database to be ready
    print_status "Waiting for database..."
    for i in {1..30}; do
        if docker-compose -f docker-compose.prod.yml exec -T db pg_isready -U postgres &>/dev/null; then
            print_success "Database is ready!"
            break
        fi
        if [[ $i -eq 30 ]]; then
            print_warning "Database health check timeout"
        fi
        sleep 2
    done
    
    # Wait for API to be ready
    print_status "Waiting for API..."
    for i in {1..30}; do
        if curl -f http://localhost:8000/health &>/dev/null; then
            print_success "API is ready!"
            break
        fi
        if [[ $i -eq 30 ]]; then
            print_warning "API health check timeout"
        fi
        sleep 2
    done
    
    # Wait for frontend to be ready
    print_status "Waiting for frontend..."
    for i in {1..30}; do
        if curl -f http://localhost:3000 &>/dev/null; then
            print_success "Frontend is ready!"
            break
        fi
        if [[ $i -eq 30 ]]; then
            print_warning "Frontend health check timeout"
        fi
        sleep 2
    done
}

# Check application status
check_status() {
    print_status "Checking application status..."
    
    echo ""
    print_status "Container Status:"
    docker-compose -f docker-compose.prod.yml ps
    
    echo ""
    print_status "Service Health Checks:"
    
    # Check API
    if curl -f http://localhost:8000/health &>/dev/null; then
        print_success "✅ API is healthy (http://localhost:8000)"
    else
        print_error "❌ API health check failed"
    fi
    
    # Check Frontend
    if curl -f http://localhost:3000 &>/dev/null; then
        print_success "✅ Frontend is healthy (http://localhost:3000)"
    else
        print_error "❌ Frontend health check failed"
    fi
    
    # Check Database
    if docker-compose -f docker-compose.prod.yml exec -T db pg_isready -U postgres &>/dev/null; then
        print_success "✅ Database is healthy"
    else
        print_error "❌ Database health check failed"
    fi
}

# Show final information
show_final_info() {
    echo ""
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    DEPLOYMENT COMPLETE!                      ║"
    echo "║                                                              ║"
    echo "║  Your application is now running and available at:           ║"
    echo "║                                                              ║"
    echo "║  🌐 Frontend: http://103.143.148.190                        ║"
    echo "║  🔧 API: http://103.143.148.190:8000                        ║"
    echo "║  📚 API Docs: http://103.143.148.190:8000/docs              ║"
    echo "║  🎯 Direct Frontend: http://103.143.148.190:3000            ║"
    echo "║                                                              ║"
    echo "║  Management Commands:                                        ║"
    echo "║  📊 View logs: docker-compose -f docker-compose.prod.yml logs ║"
    echo "║  🔄 Restart: docker-compose -f docker-compose.prod.yml restart ║"
    echo "║  🛑 Stop: docker-compose -f docker-compose.prod.yml down    ║"
    echo "║  📈 Status: docker-compose -f docker-compose.prod.yml ps    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Main deployment function
main() {
    check_directory
    check_docker
    setup_environment
    stop_existing
    cleanup_docker
    build_and_start
    wait_for_services
    check_status
    show_final_info
}

# Run main function
main "$@"
