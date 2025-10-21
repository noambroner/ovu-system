# 🎯 OVU System - Simple 3-Server Architecture

## 📊 Overview - Exactly 3 Servers

```
┌─────────────────────────────────────────┐
│              Internet Users             │
└──────────────────┬──────────────────────┘
                   │
                   │ HTTPS
                   ▼
        ┌──────────────────────┐
        │   SERVER 1: FRONTEND │
        │   frontend.ovu.co.il │
        │   ----------------   │
        │   • Nginx             │
        │   • Flutter Web Apps  │
        │   • Static Files       │
        │   • SSL Certificates  │
        └──────────┬───────────┘
                   │
                   │ REST API (HTTP)
                   ▼
        ┌──────────────────────┐
        │   SERVER 2: BACKEND  │
        │   api.ovu.co.il      │
        │   ----------------   │
        │   • FastAPI (Python)  │
        │   • ULM Service       │
        │   • AAM Service       │
        │   • Business Logic    │
        └──────────┬───────────┘
                   │
                   │ PostgreSQL Protocol
                   ▼
        ┌──────────────────────┐
        │   SERVER 3: DATABASE │
        │   db.ovu.co.il       │
        │   ----------------   │
        │   • PostgreSQL        │
        │   • Redis Cache       │
        │   • Data Storage      │
        │   • Backups           │
        └──────────────────────┘
```

## 🖥️ Server Specifications

### Server 1: Frontend Server
**Purpose**: Serve web applications and static files
```yaml
Hostname: frontend.ovu.co.il
CPU: 2-4 cores
RAM: 8GB
Storage: 100GB SSD
OS: Ubuntu 22.04 LTS
Software:
  - Nginx (web server)
  - SSL certificates (Let's Encrypt)
  - Flutter web builds
```

### Server 2: Backend Server
**Purpose**: Run Python FastAPI applications
```yaml
Hostname: api.ovu.co.il
CPU: 4-8 cores
RAM: 16GB
Storage: 200GB SSD
OS: Ubuntu 22.04 LTS
Software:
  - Python 3.11
  - FastAPI
  - Docker
  - Supervisor (process manager)
```

### Server 3: Database Server
**Purpose**: Store all data
```yaml
Hostname: db.ovu.co.il
CPU: 4-8 cores
RAM: 32GB
Storage: 500GB SSD (or more)
OS: Ubuntu 22.04 LTS
Software:
  - PostgreSQL 16
  - Redis 7
  - Automated backup scripts
```

## 🔧 FastAPI Backend Structure

### Why FastAPI (Not Django)?
```python
# FastAPI - Modern, Fast, Simple
@app.get("/api/users/{user_id}")
async def get_user(user_id: int):
    user = await db.fetch_user(user_id)
    return user  # Auto JSON, Auto validation!

# Django - Old, Slow, Complex
class UserView(View):
    def get(self, request, user_id):
        try:
            user = User.objects.get(pk=user_id)
            return JsonResponse({
                'id': user.id,
                'name': user.name,
                # Manual serialization...
            })
        except User.DoesNotExist:
            return JsonResponse({'error': 'Not found'}, status=404)
```

### Performance Comparison
```
FastAPI:  35,000 requests/second
Flask:    15,000 requests/second  
Django:    7,000 requests/second
```

## 🚀 Installation Guide

### Step 1: Setup Database Server
```bash
# On db.ovu.co.il
sudo apt update && sudo apt upgrade -y

# Install PostgreSQL
sudo apt install postgresql-16 postgresql-contrib-16
sudo systemctl enable postgresql

# Install Redis
sudo apt install redis-server
sudo systemctl enable redis

# Configure PostgreSQL for remote access
sudo nano /etc/postgresql/16/main/postgresql.conf
# Set: listen_addresses = '*'

sudo nano /etc/postgresql/16/main/pg_hba.conf
# Add: host all all 0.0.0.0/0 md5

# Create databases
sudo -u postgres psql
CREATE USER ovu_user WITH PASSWORD 'strong_password_here';
CREATE DATABASE ulm_db OWNER ovu_user;
CREATE DATABASE aam_db OWNER ovu_user;
GRANT ALL PRIVILEGES ON DATABASE ulm_db TO ovu_user;
GRANT ALL PRIVILEGES ON DATABASE aam_db TO ovu_user;
\q

# Restart PostgreSQL
sudo systemctl restart postgresql
```

### Step 2: Setup Backend Server
```bash
# On api.ovu.co.il
sudo apt update && sudo apt upgrade -y

# Install Python and dependencies
sudo apt install python3.11 python3.11-venv python3-pip nginx supervisor

# Create application directory
sudo mkdir -p /opt/ovu
cd /opt/ovu

# Clone your repository
git clone https://github.com/your-repo/ovu-system.git .

# Setup Python virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r services/ulm/backend/requirements.txt
pip install -r services/aam/backend/requirements.txt

# Create systemd services
sudo tee /etc/systemd/system/ulm.service << EOF
[Unit]
Description=ULM FastAPI Service
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/ovu/services/ulm/backend
Environment="PATH=/opt/ovu/venv/bin"
Environment="DATABASE_URL=postgresql://ovu_user:password@db.ovu.co.il/ulm_db"
ExecStart=/opt/ovu/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8001
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/aam.service << EOF
[Unit]
Description=AAM FastAPI Service
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/ovu/services/aam/backend
Environment="PATH=/opt/ovu/venv/bin"
Environment="DATABASE_URL=postgresql://ovu_user:password@db.ovu.co.il/aam_db"
ExecStart=/opt/ovu/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8002
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Start services
sudo systemctl daemon-reload
sudo systemctl enable ulm aam
sudo systemctl start ulm aam
```

### Step 3: Setup Frontend Server
```bash
# On frontend.ovu.co.il
sudo apt update && sudo apt upgrade -y

# Install Nginx
sudo apt install nginx certbot python3-certbot-nginx

# Build Flutter apps (do this on your local machine first)
cd services/ulm/frontend/flutter
flutter build web --release --base-href /

cd services/aam/frontend/flutter
flutter build web --release --base-href /

# Copy built files to server
scp -r services/ulm/frontend/flutter/build/web/* root@frontend.ovu.co.il:/var/www/ulm/
scp -r services/aam/frontend/flutter/build/web/* root@frontend.ovu.co.il:/var/www/aam/

# Configure Nginx
sudo tee /etc/nginx/sites-available/ovu << 'EOF'
# Main site redirect
server {
    listen 80;
    server_name ovu.co.il www.ovu.co.il;
    return 301 https://ovu.co.il$request_uri;
}

# ULM Frontend
server {
    listen 80;
    server_name ulm.ovu.co.il;
    root /var/www/ulm;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # API Proxy to Backend Server
    location /api/ {
        proxy_pass http://api.ovu.co.il:8001/api/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS headers
        add_header Access-Control-Allow-Origin $http_origin always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Authorization, Content-Type" always;
        add_header Access-Control-Allow-Credentials true always;
    }
}

# AAM Frontend
server {
    listen 80;
    server_name aam.ovu.co.il;
    root /var/www/aam;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://api.ovu.co.il:8002/api/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# API Documentation (optional)
server {
    listen 80;
    server_name api.ovu.co.il;
    
    location / {
        proxy_pass http://api.ovu.co.il:8001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/ovu /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Setup SSL certificates
sudo certbot --nginx -d ovu.co.il -d www.ovu.co.il -d ulm.ovu.co.il -d aam.ovu.co.il -d api.ovu.co.il
```

## 📝 Environment Configuration

### Backend Server (.env)
```bash
# /opt/ovu/.env on api.ovu.co.il
NODE_ENV=production
DEBUG=false

# Database Connection (to db.ovu.co.il)
DATABASE_HOST=db.ovu.co.il
DATABASE_PORT=5432
DATABASE_USER=ovu_user
DATABASE_PASSWORD=your_strong_password
DATABASE_NAME=ovu_db

# Redis Connection
REDIS_HOST=db.ovu.co.il
REDIS_PORT=6379
REDIS_PASSWORD=redis_password

# API Configuration
API_HOST=0.0.0.0
API_PORT=8001
API_WORKERS=4

# Security
SECRET_KEY=generate_64_char_random_string_here
JWT_SECRET=another_random_string

# Frontend URLs
FRONTEND_URL=https://ulm.ovu.co.il
CORS_ORIGINS=https://ulm.ovu.co.il,https://aam.ovu.co.il
```

## 🔒 Security Configuration

### Firewall Rules
```bash
# Database Server (db.ovu.co.il)
sudo ufw allow from api.ovu.co.il to any port 5432  # PostgreSQL
sudo ufw allow from api.ovu.co.il to any port 6379  # Redis
sudo ufw allow ssh
sudo ufw enable

# Backend Server (api.ovu.co.il)  
sudo ufw allow from frontend.ovu.co.il to any port 8001  # ULM API
sudo ufw allow from frontend.ovu.co.il to any port 8002  # AAM API
sudo ufw allow ssh
sudo ufw enable

# Frontend Server (frontend.ovu.co.il)
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw allow ssh
sudo ufw enable
```

## 📊 Monitoring

### Simple Health Checks
```bash
# Check all services
curl https://ulm.ovu.co.il/api/health
curl https://aam.ovu.co.il/api/health
curl https://api.ovu.co.il/health

# Database check
ssh db.ovu.co.il "psql -U ovu_user -d ulm_db -c 'SELECT 1'"

# Service status
ssh api.ovu.co.il "systemctl status ulm aam"
```

## 💰 Cost Estimation

### Monthly Server Costs
```
Frontend Server (2 cores, 8GB):   $40-60
Backend Server (4 cores, 16GB):   $80-120  
Database Server (4 cores, 32GB):  $160-240
-----------------------------------------
Total:                            $280-420/month
```

### Providers Comparison
```
DigitalOcean: $280/month (cheapest)
AWS EC2:      $350/month (with reserved instances)
Azure:        $380/month
Google Cloud: $360/month
```

## 🚀 Deployment Script

### Simple Deploy Script
```bash
#!/bin/bash
# deploy.sh - Deploy to 3 servers

# Build Flutter
echo "Building Flutter apps..."
cd services/ulm/frontend/flutter && flutter build web
cd services/aam/frontend/flutter && flutter build web

# Deploy to Frontend Server
echo "Deploying frontend..."
rsync -avz services/ulm/frontend/flutter/build/web/ root@frontend.ovu.co.il:/var/www/ulm/
rsync -avz services/aam/frontend/flutter/build/web/ root@frontend.ovu.co.il:/var/www/aam/

# Deploy to Backend Server
echo "Deploying backend..."
ssh root@api.ovu.co.il << EOF
  cd /opt/ovu
  git pull
  source venv/bin/activate
  pip install -r services/ulm/backend/requirements.txt
  pip install -r services/aam/backend/requirements.txt
  sudo systemctl restart ulm aam
EOF

echo "Deployment complete!"
```

## ✅ Advantages of This Architecture

1. **Simple** - Only 3 servers to manage
2. **Clear Separation** - Each server has one job
3. **Cost Effective** - ~$300/month total
4. **Easy to Scale** - Just upgrade server specs
5. **No Load Balancer Needed** - Direct connections
6. **Fast** - FastAPI gives excellent performance

## ⚠️ When You'll Need to Scale

When you reach:
- 10,000+ daily active users
- 100+ requests per second
- Database size > 100GB

Then add:
- Load balancer
- Additional backend servers
- Database replication
- CDN for static files

## 📋 Checklist

- [ ] Order 3 servers from provider
- [ ] Setup DNS records for all domains
- [ ] Configure Database Server
- [ ] Deploy Backend Server
- [ ] Deploy Frontend Server
- [ ] Setup SSL certificates
- [ ] Configure firewall rules
- [ ] Test all endpoints
- [ ] Setup monitoring
- [ ] Configure backups
