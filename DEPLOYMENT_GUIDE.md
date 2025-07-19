# 🚀 Hub Application Deployment Guide

This guide will help you deploy your Hub application to the production server at `103.143.148.190`.

## 📋 Prerequisites

- Server: `103.143.148.190`
- Username: `onchain`
- Password: `onchain@321#`
- Local machine with SSH access

## 🛠 Deployment Options

### Option 1: Automated Deployment (Recommended)

1. **Install sshpass on your local machine:**
   ```bash
   # macOS
   brew install sshpass
   
   # Ubuntu/Debian
   sudo apt-get install sshpass
   ```

2. **Run the automated deployment script:**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

### Option 2: Manual Deployment (Step by Step)

1. **Run the manual deployment guide:**
   ```bash
   chmod +x deploy-manual.sh
   ./deploy-manual.sh
   ```

## 🔧 Manual Setup Instructions

If you prefer to do everything manually, follow these steps:

### Step 1: Connect to Server
```bash
ssh onchain@103.143.148.190
# Password: onchain@321#
```

### Step 2: Install Docker and Docker Compose
```bash
# Update system
sudo apt-get update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Reload group membership
newgrp docker
```

### Step 3: Create Application Directory
```bash
mkdir -p /home/onchain/hub
cd /home/onchain/hub
```

### Step 4: Upload Files (from your local machine)
```bash
# Upload application files
scp -r onchain_fastapi onchain@103.143.148.190:/home/onchain/hub/
scp -r hub_nextjs onchain@103.143.148.190:/home/onchain/hub/
scp -r nginx onchain@103.143.148.190:/home/onchain/hub/
scp docker-compose.prod.yml onchain@103.143.148.190:/home/onchain/hub/
scp .env.prod onchain@103.143.148.190:/home/onchain/hub/.env
```

### Step 5: Configure Environment
```bash
# Edit environment variables if needed
nano .env
```

### Step 6: Build and Start Application
```bash
cd /home/onchain/hub

# Build the application
docker-compose -f docker-compose.prod.yml build

# Start the application
docker-compose -f docker-compose.prod.yml up -d
```

### Step 7: Verify Deployment
```bash
# Check container status
docker-compose -f docker-compose.prod.yml ps

# Check logs
docker-compose -f docker-compose.prod.yml logs

# Test API health
curl http://localhost:8000/health

# Test frontend
curl http://localhost:3000
```

## 🌐 Access Your Application

After successful deployment, your application will be available at:

- **Frontend**: http://103.143.148.190
- **API**: http://103.143.148.190:8000
- **API Documentation**: http://103.143.148.190:8000/docs
- **Direct Frontend Access**: http://103.143.148.190:3000

## 🔧 Application Management

### View Logs
```bash
cd /home/onchain/hub
docker-compose -f docker-compose.prod.yml logs
docker-compose -f docker-compose.prod.yml logs -f  # Follow logs
```

### Restart Services
```bash
docker-compose -f docker-compose.prod.yml restart
```

### Stop Application
```bash
docker-compose -f docker-compose.prod.yml down
```

### Update Application
```bash
# Pull latest changes and rebuild
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
```

### Check Resource Usage
```bash
docker stats
docker system df
```

## 🛡 Security Considerations

1. **Change default passwords** in `.env` file
2. **Configure firewall** if needed:
   ```bash
   sudo ufw allow 22    # SSH
   sudo ufw allow 80    # HTTP
   sudo ufw allow 8000  # API
   sudo ufw allow 3000  # Frontend (optional)
   sudo ufw enable
   ```

## 🐛 Troubleshooting

### Container Won't Start
```bash
# Check logs for specific service
docker-compose -f docker-compose.prod.yml logs api
docker-compose -f docker-compose.prod.yml logs frontend
docker-compose -f docker-compose.prod.yml logs db
```

### Database Issues
```bash
# Connect to database
docker-compose -f docker-compose.prod.yml exec db psql -U postgres -d hub

# Reset database (WARNING: This will delete all data)
docker-compose -f docker-compose.prod.yml down -v
docker-compose -f docker-compose.prod.yml up -d
```

### Port Conflicts
```bash
# Check what's using ports
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :8000
sudo netstat -tulpn | grep :3000
```

### Free Up Space
```bash
# Remove unused Docker resources
docker system prune -a
docker volume prune
```

## 📊 Monitoring

### Health Checks
```bash
# API health
curl http://103.143.148.190:8000/health

# Frontend health
curl http://103.143.148.190:3000

# Database health
docker-compose -f docker-compose.prod.yml exec db pg_isready -U postgres
```

### Performance Monitoring
```bash
# Container resource usage
docker stats

# System resources
htop
df -h
free -h
```

## 🔄 Backup and Recovery

### Database Backup
```bash
# Create backup
docker-compose -f docker-compose.prod.yml exec db pg_dump -U postgres hub > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore backup
docker-compose -f docker-compose.prod.yml exec -T db psql -U postgres hub < backup_file.sql
```

### Application Backup
```bash
# Backup entire application directory
tar -czf hub_backup_$(date +%Y%m%d_%H%M%S).tar.gz /home/onchain/hub
```

## 📞 Support

If you encounter any issues during deployment, check:

1. **Container logs**: `docker-compose logs`
2. **System resources**: `df -h` and `free -h`
3. **Network connectivity**: `curl` tests
4. **Port availability**: `netstat -tulpn`

For additional help, refer to the application logs and Docker documentation.
