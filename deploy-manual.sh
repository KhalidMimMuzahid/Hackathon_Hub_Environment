#!/bin/bash

# Manual Deployment Script - Run this on your local machine
# This script will guide you through the deployment process step by step

set -e

# Configuration
SERVER_IP="103.143.148.190"
SERVER_USER="onchain"
APP_NAME="hub"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo -e "\n${BLUE}==== STEP: $1 ====${NC}"
}

print_command() {
    echo -e "${YELLOW}Run this command:${NC}"
    echo -e "${GREEN}$1${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    HUB APPLICATION DEPLOYMENT                ║"
echo "║                     Manual Deployment Guide                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

print_step "1. Connect to your server"
print_info "Use SSH to connect to your server:"
print_command "ssh onchain@103.143.148.190"
print_info "Password: onchain@321#"
echo ""
read -p "Press Enter after you've connected to the server..."

print_step "2. Update system and install Docker"
print_info "Run these commands on your server:"
print_command "sudo apt-get update"
print_command "sudo apt-get install -y curl"
print_command "curl -fsSL https://get.docker.com -o get-docker.sh"
print_command "sudo sh get-docker.sh"
print_command "sudo usermod -aG docker \$USER"
print_command "sudo curl -L \"https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-\$(uname -s)-\$(uname -m)\" -o /usr/local/bin/docker-compose"
print_command "sudo chmod +x /usr/local/bin/docker-compose"
print_command "newgrp docker"
echo ""
read -p "Press Enter after installing Docker..."

print_step "3. Create application directory"
print_info "Create the application directory:"
print_command "mkdir -p /home/onchain/hub"
print_command "cd /home/onchain/hub"
echo ""
read -p "Press Enter after creating the directory..."

print_step "4. Upload application files"
print_info "Open a new terminal on your LOCAL machine and run:"
print_command "scp -r onchain_fastapi onchain@103.143.148.190:/home/onchain/hub/"
print_command "scp -r hub_nextjs onchain@103.143.148.190:/home/onchain/hub/"
print_command "scp -r nginx onchain@103.143.148.190:/home/onchain/hub/"
print_command "scp docker-compose.prod.yml onchain@103.143.148.190:/home/onchain/hub/"
print_command "scp .env.prod onchain@103.143.148.190:/home/onchain/hub/.env"
echo ""
read -p "Press Enter after uploading all files..."

print_step "5. Start the application"
print_info "Back on your server, run:"
print_command "cd /home/onchain/hub"
print_command "docker-compose -f docker-compose.prod.yml build"
print_command "docker-compose -f docker-compose.prod.yml up -d"
echo ""
read -p "Press Enter after starting the application..."

print_step "6. Check application status"
print_info "Verify everything is running:"
print_command "docker-compose -f docker-compose.prod.yml ps"
print_command "docker-compose -f docker-compose.prod.yml logs"
echo ""
read -p "Press Enter to continue..."

print_step "7. Test the application"
print_info "Test your application:"
print_command "curl http://localhost:8000/health"
print_command "curl http://localhost:3000"
echo ""
print_info "If both commands return successful responses, your deployment is complete!"

echo -e "\n${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    DEPLOYMENT COMPLETE!                      ║"
echo "║                                                              ║"
echo "║  Your application should now be available at:                ║"
echo "║  Frontend: http://103.143.148.190                           ║"
echo "║  API: http://103.143.148.190:8000                           ║"
echo "║  API Docs: http://103.143.148.190:8000/docs                 ║"
echo "║                                                              ║"
echo "║  To manage your application:                                 ║"
echo "║  - View logs: docker-compose logs                           ║"
echo "║  - Restart: docker-compose restart                          ║"
echo "║  - Stop: docker-compose down                                ║"
echo "║  - Update: docker-compose pull && docker-compose up -d      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
