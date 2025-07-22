#!/bin/bash

# Development Environment Startup Script
# This script starts the dockerized application with PostgreSQL for local development

echo "🚀 Starting Development Environment..."
echo "📋 Configuration:"
echo "   - Backend: http://localhost:8000"
echo "   - Frontend: http://localhost:3001"
echo "   - Database: PostgreSQL on localhost:5432"
echo "   - Database Name: hub"
echo "   - Database User: postgres"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose -f docker-compose.dev.yml down

# Build and start the development environment
echo "🔨 Building and starting containers..."
docker-compose -f docker-compose.dev.yml up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check service status
echo "📊 Checking service status..."
docker-compose -f docker-compose.dev.yml ps

echo ""
echo "✅ Development environment is starting up!"
echo ""
echo "🌐 Access your application:"
echo "   Frontend: http://localhost:3001"
echo "   Backend API: http://localhost:8000"
echo "   API Documentation: http://localhost:8000/docs"
echo "   Health Check: http://localhost:8000/health"
echo ""
echo "🗄️  Database Connection:"
echo "   Host: localhost"
echo "   Port: 5432"
echo "   Database: hub"
echo "   Username: postgres"
echo "   Password: devpass123"
echo ""
echo "📝 To view logs:"
echo "   docker-compose -f docker-compose.dev.yml logs -f"
echo ""
echo "🛑 To stop the environment:"
echo "   docker-compose -f docker-compose.dev.yml down"
