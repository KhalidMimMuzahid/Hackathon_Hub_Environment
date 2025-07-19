# 🚀 Simple Deployment Instructions

## Quick Deployment Steps

### Step 1: Copy Files to Server
Copy the entire `/manual` folder to your server:

```bash
# From your local machine
scp -r /path/to/manual onchain@103.143.148.190:/home/onchain/
```

### Step 2: Connect to Server
```bash
ssh onchain@103.143.148.190
# Password: onchain@321#
```

### Step 3: Navigate to Project Directory
```bash
cd /home/onchain/manual
```

### Step 4: Run Deployment Script
```bash
chmod +x deploy-server.sh
./deploy-server.sh
```

That's it! The script will:
- ✅ Check all required files
- ✅ Verify Docker installation
- ✅ Setup environment variables
- ✅ Build and start all containers
- ✅ Perform health checks
- ✅ Show you the final URLs

## Your Application URLs

After deployment, access your application at:
- **Frontend**: http://103.143.148.190
- **API**: http://103.143.148.190:8000
- **API Documentation**: http://103.143.148.190:8000/docs

## Management Commands

```bash
# View logs
docker-compose -f docker-compose.prod.yml logs

# Check status
docker-compose -f docker-compose.prod.yml ps

# Restart services
docker-compose -f docker-compose.prod.yml restart

# Stop application
docker-compose -f docker-compose.prod.yml down

# Update application (after copying new files)
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
```

## Troubleshooting

If something goes wrong:

1. **Check logs**: `docker-compose -f docker-compose.prod.yml logs`
2. **Check container status**: `docker-compose -f docker-compose.prod.yml ps`
3. **Restart everything**: `./deploy-server.sh`

## File Structure Required

Make sure your `/manual` folder contains:
```
manual/
├── docker-compose.prod.yml
├── .env.prod
├── deploy-server.sh
├── onchain_fastapi/
├── hub_nextjs/
└── nginx/
```
