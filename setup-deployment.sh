#!/bin/bash

# Setup script to prepare deployment files
# Run this script before deploying

echo "🚀 Setting up deployment files..."

# Make scripts executable
chmod +x deploy-server.sh
chmod +x deploy-manual.sh
chmod +x setup-deployment.sh

# Create necessary directories
mkdir -p nginx/conf.d

# Check if required files exist
echo "📋 Checking required files..."

required_files=(
    "docker-compose.prod.yml"
    ".env.prod"
    "nginx/nginx.conf"
    "nginx/conf.d/default.conf"
    "onchain_fastapi/Dockerfile.prod"
    "hub_nextjs/Dockerfile.prod"
    "deploy-server.sh"
    "deploy-manual.sh"
    "DEPLOYMENT_GUIDE.md"
    "SIMPLE_DEPLOYMENT.md"
)

missing_files=()

for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        missing_files+=("$file")
    fi
done

if [[ ${#missing_files[@]} -eq 0 ]]; then
    echo "✅ All required files are present!"
else
    echo "❌ Missing files:"
    for file in "${missing_files[@]}"; do
        echo "   - $file"
    done
    echo ""
    echo "Please ensure all files are created before deployment."
    exit 1
fi

echo ""
echo "🎉 Deployment setup complete!"
echo ""
echo "Next steps:"
echo "1. Review and update .env.prod with your production settings"
echo "2. Choose your deployment method:"
echo "   - Copy /manual folder to server and run: ./deploy-server.sh (RECOMMENDED)"
echo "   - Manual step-by-step: ./deploy-manual.sh"
echo "   - Read simple guide: cat SIMPLE_DEPLOYMENT.md"
echo "   - Read full guide: cat DEPLOYMENT_GUIDE.md"
echo ""
echo "Your application will be available at:"
echo "  Frontend: http://103.143.148.190"
echo "  API: http://103.143.148.190:8000"
echo "  API Docs: http://103.143.148.190:8000/docs"
