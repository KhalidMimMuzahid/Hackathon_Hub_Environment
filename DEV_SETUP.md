# Development Environment Setup

This guide will help you set up the dockerized application for local development with PostgreSQL.

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed on your system
- Git (to clone the repository)

### Starting the Development Environment

1. **Clone the repository** (if you haven't already):
   ```bash
   git clone <your-repo-url>
   cd manual
   ```

2. **Start the development environment**:
   ```bash
   ./start-dev.sh
   ```

   Or manually:
   ```bash
   docker-compose -f docker-compose.dev.yml up -d
   ```

3. **Access your application**:
   - **Frontend**: http://localhost:3001
   - **Backend API**: http://localhost:8000
   - **API Documentation**: http://localhost:8000/docs
   - **Health Check**: http://localhost:8000/health

## 🗄️ Database Information

- **Host**: localhost
- **Port**: 5432
- **Database**: hub
- **Username**: postgres
- **Password**: devpass123

You can connect to the database using any PostgreSQL client with these credentials.

## 📋 Services Overview

### Backend (FastAPI)
- **Port**: 8000
- **Technology**: Python FastAPI with PostgreSQL
- **Features**: 
  - Automatic database table creation
  - API documentation at `/docs`
  - Health check endpoint at `/health`
  - Hot reload for development

### Frontend (Next.js)
- **Port**: 3001
- **Technology**: Next.js React application
- **Features**:
  - Hot reload for development
  - Automatic API connection to backend

### Database (PostgreSQL)
- **Port**: 5432
- **Technology**: PostgreSQL 15 Alpine
- **Features**:
  - Persistent data storage
  - Automatic initialization

## 🛠️ Development Commands

### View logs
```bash
# All services
docker-compose -f docker-compose.dev.yml logs -f

# Specific service
docker-compose -f docker-compose.dev.yml logs -f backend-dev
docker-compose -f docker-compose.dev.yml logs -f frontend-dev
docker-compose -f docker-compose.dev.yml logs -f db
```

### Check service status
```bash
docker-compose -f docker-compose.dev.yml ps
```

### Stop the environment
```bash
docker-compose -f docker-compose.dev.yml down
```

### Stop and remove volumes (fresh start)
```bash
docker-compose -f docker-compose.dev.yml down -v
```

### Rebuild containers
```bash
docker-compose -f docker-compose.dev.yml up --build -d
```

## 🔧 Configuration

The development environment is configured through:
- `.env` - Environment variables for all services
- `docker-compose.dev.yml` - Docker services configuration

### Key Environment Variables
- `POSTGRES_DB=hub` - Database name
- `POSTGRES_USER=postgres` - Database user
- `POSTGRES_PASSWORD=devpass123` - Database password
- `DB_HOST=db` - Database host (container name)
- `DB_PORT=5432` - Database port

## 🐛 Troubleshooting

### Backend won't start
1. Check if database is healthy: `docker-compose -f docker-compose.dev.yml ps`
2. Check backend logs: `docker-compose -f docker-compose.dev.yml logs backend-dev`
3. Restart services: `docker-compose -f docker-compose.dev.yml restart`

### Database connection issues
1. Ensure database container is running and healthy
2. Check if password matches in `.env` file
3. Try recreating with fresh volumes: `docker-compose -f docker-compose.dev.yml down -v && docker-compose -f docker-compose.dev.yml up -d`

### Port conflicts
If ports 3001, 8000, or 5432 are already in use:
1. Stop other services using those ports
2. Or modify the ports in `docker-compose.dev.yml`

## 📝 Notes

- The development environment uses PostgreSQL instead of SQLite for better production parity
- All services run in Docker containers for consistency across different development machines
- Database data persists between container restarts unless volumes are explicitly removed
- The backend automatically creates database tables on startup
- Both frontend and backend support hot reload for faster development
