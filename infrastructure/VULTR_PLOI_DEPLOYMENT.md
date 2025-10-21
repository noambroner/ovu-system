# 🚀 OVU System - VULTR + PLOI.IO Deployment Guide

## 📊 Architecture for VULTR + PLOI.IO

### 3 VULTR Servers Setup:
1. **Frontend Server** - $24/month (2 vCPU, 4GB RAM, 80GB NVMe)
2. **Backend Server** - $48/month (4 vCPU, 8GB RAM, 160GB NVMe)
3. **Database Server** - $96/month (6 vCPU, 16GB RAM, 320GB NVMe)

**Total: ~$168/month** (Much cheaper than our initial estimate!)

## 🎯 Step 1: Setup VULTR Servers

### Create 3 Servers in VULTR:

1. **Login to VULTR** → Deploy New Server
2. **Choose Location**: Choose closest to your users
3. **Server Type**: Cloud Compute
4. **OS**: Ubuntu 22.04 LTS
5. **Server Sizes**:
   - Frontend: 2 vCPU / 4GB RAM ($24)
   - Backend: 4 vCPU / 8GB RAM ($48)
   - Database: 6 vCPU / 16GB RAM ($96)

### Server Naming:
```
frontend.ovu.co.il
backend.ovu.co.il
database.ovu.co.il
```

## 🔧 Step 2: Connect VULTR to PLOI.IO

### In PLOI.IO Dashboard:

1. **Add Provider**:
   - Go to Servers → Providers
   - Select VULTR
   - Add your VULTR API Key

2. **Create Servers via PLOI**:
   ```
   Server 1: frontend-ovu
   Server 2: backend-ovu
   Server 3: database-ovu
   ```

3. **PLOI will automatically**:
   - Install required software
   - Setup firewall
   - Configure SSH keys
   - Install monitoring

## 📦 Step 3: Database Server Setup (via PLOI)

### In PLOI for database-ovu server:

1. **Click on Server** → **Database**
2. **Install PostgreSQL 16**:
   ```sql
   Create Database: ulm_db
   Create Database: aam_db
   Username: ovu_user
   Password: [Generate Strong Password]
   ```

3. **Install Redis**:
   - Go to Server → Services
   - Install Redis
   - Set password

4. **Configure Remote Access**:
   - PLOI → Server → Database → Settings
   - Enable "Allow Remote Connections"
   - Add Backend Server IP to whitelist

## 🐍 Step 4: Backend Server Setup (Python/FastAPI)

### In PLOI for backend-ovu server:

1. **Install Python via PLOI Script**:
   - Server → Scripts → New Script
   - Run as root

```bash
#!/bin/bash
# Install Python 3.11 and dependencies
apt update && apt upgrade -y
apt install -y python3.11 python3.11-venv python3-pip
apt install -y supervisor nginx
apt install -y postgresql-client redis-tools

# Create app directory
mkdir -p /var/www/ovu-backend
chown -R ploi:ploi /var/www/ovu-backend
```

2. **Create Site in PLOI**:
   - Sites → Create Site
   - Domain: api.ovu.co.il
   - Web Directory: /public (we'll modify this)
   - Project Type: Generic PHP/HTML (we'll customize)

3. **Deploy Script** (PLOI → Site → Deployment Script):

```bash
#!/bin/bash
cd /var/www/ovu-backend

# Pull latest code
if [ ! -d ".git" ]; then
    git clone https://github.com/YOUR_REPO/ovu-system.git .
else
    git pull origin main
fi

# Setup Python environment
if [ ! -d "venv" ]; then
    python3.11 -m venv venv
fi

source venv/bin/activate

# Install/Update dependencies
pip install --upgrade pip
pip install -r services/ulm/backend/requirements.txt
pip install -r services/aam/backend/requirements.txt

# Run migrations
cd services/ulm/backend
alembic upgrade head
cd ../../../

cd services/aam/backend
alembic upgrade head
cd ../../../

# Restart services
sudo supervisorctl restart all
```

## ⚙️ Step 5: Supervisor Configuration (FastAPI)

### Create Supervisor configs via PLOI:

1. **ULM Service** (Server → Daemons → Create):
```
Command: /var/www/ovu-backend/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8001
Directory: /var/www/ovu-backend/services/ulm/backend
User: ploi
Processes: 2
```

2. **AAM Service** (Server → Daemons → Create):
```
Command: /var/www/ovu-backend/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8002
Directory: /var/www/ovu-backend/services/aam/backend
User: ploi
Processes: 2
```

## 🌐 Step 6: Frontend Server Setup

### In PLOI for frontend-ovu server:

1. **Create Sites**:
   - Site 1: ulm.ovu.co.il
   - Site 2: aam.ovu.co.il
   - Site 3: ovu.co.il (main)

2. **Build Flutter Apps Locally**:
```bash
# On your local machine
cd services/ulm/frontend/flutter
flutter build web --release --web-renderer html

cd services/aam/frontend/flutter
flutter build web --release --web-renderer html
```

3. **Deploy via PLOI Git**:
   - Connect your GitHub repo
   - Set deployment script:

```bash
#!/bin/bash
# Copy Flutter builds to correct locations
cp -r services/ulm/frontend/flutter/build/web/* /var/www/ulm-ovu/public/
cp -r services/aam/frontend/flutter/build/web/* /var/www/aam-ovu/public/

# Fix permissions
chown -R ploi:ploi /var/www/ulm-ovu/public
chown -R ploi:ploi /var/www/aam-ovu/public
```

## 🔒 Step 7: NGINX Configuration (via PLOI)

### Frontend NGINX (PLOI will manage this):

For each site in PLOI, update NGINX config:

**ulm.ovu.co.il**:
```nginx
location / {
    try_files $uri $uri/ /index.html;
}

location /api/ {
    proxy_pass http://backend.ovu.co.il:8001;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

## 🔐 Step 8: Environment Variables (via PLOI)

### In PLOI → Site → Environment:

```env
# Database Connection
DB_HOST=database.ovu.co.il
DB_PORT=5432
DB_NAME=ulm_db
DB_USER=ovu_user
DB_PASSWORD=your_password_here

# Redis
REDIS_HOST=database.ovu.co.il
REDIS_PORT=6379
REDIS_PASSWORD=redis_password_here

# Security
SECRET_KEY=generate_64_char_key
JWT_SECRET=another_64_char_key

# API Settings
DEBUG=false
API_HOST=0.0.0.0
API_WORKERS=4

# Frontend URLs
FRONTEND_URL=https://ulm.ovu.co.il
CORS_ORIGINS=https://ulm.ovu.co.il,https://aam.ovu.co.il
```

## 🚦 Step 9: SSL Certificates (Automatic with PLOI)

PLOI will automatically:
1. Install Let's Encrypt SSL
2. Auto-renew certificates
3. Configure NGINX for HTTPS

Just click: Site → SSL → Let's Encrypt → Activate

## 📊 Step 10: Monitoring (Built into PLOI)

PLOI provides:
- Server monitoring
- Uptime monitoring
- Log viewer
- Database backups
- Security updates

## 🎯 Quick Deployment Checklist

### VULTR Setup:
- [ ] Create 3 VULTR servers
- [ ] Note down server IPs
- [ ] Add servers to PLOI

### Database Server:
- [ ] Install PostgreSQL via PLOI
- [ ] Install Redis via PLOI
- [ ] Create databases (ulm_db, aam_db)
- [ ] Configure remote access
- [ ] Setup automated backups

### Backend Server:
- [ ] Install Python 3.11
- [ ] Create site in PLOI
- [ ] Setup Git deployment
- [ ] Configure Supervisor daemons
- [ ] Add environment variables
- [ ] Test API endpoints

### Frontend Server:
- [ ] Create 3 sites in PLOI
- [ ] Build Flutter apps locally
- [ ] Deploy via Git
- [ ] Configure NGINX proxy
- [ ] Install SSL certificates

### Final Steps:
- [ ] Update DNS records
- [ ] Test all services
- [ ] Setup monitoring alerts
- [ ] Configure backups
- [ ] Document credentials

## 💰 Cost Breakdown

### VULTR Servers:
- Frontend: $24/month
- Backend: $48/month
- Database: $96/month
- **VULTR Total: $168/month**

### PLOI.IO:
- Unlimited servers: $10/month

### Total Infrastructure Cost:
**$178/month** (Amazing value!)

## 🔥 Deployment Commands

### One-Click Deploy (after setup):
```bash
# In PLOI Dashboard
Sites → [Your Site] → Quick Deploy → Deploy Now
```

### Manual Deploy:
```bash
ssh ploi@backend.ovu.co.il
cd /var/www/ovu-backend
./deploy.sh
```

## ⚡ Performance Tips for VULTR

1. **Use NVMe SSDs** (included in price)
2. **Enable VULTR DDoS Protection** (free)
3. **Use VULTR Private Network** between servers
4. **Enable Auto-Backups** ($1.20/month per server)

## 🆘 Troubleshooting

### If FastAPI doesn't start:
```bash
# Check logs in PLOI
Servers → backend-ovu → Logs → Daemon Logs

# Or SSH and check
ssh ploi@backend.ovu.co.il
sudo supervisorctl status
tail -f /var/log/supervisor/ulm-stdout.log
```

### If database connection fails:
```bash
# Test connection
psql -h database.ovu.co.il -U ovu_user -d ulm_db

# Check firewall in PLOI
Servers → database-ovu → Network → Firewall Rules
```

## 📈 Scaling Strategy

When you need to scale:
1. **Vertical**: Resize VULTR server (1-click in PLOI)
2. **Horizontal**: Add more backend servers
3. **CDN**: Enable Cloudflare (free tier)
4. **Database**: Add read replicas

## ✅ Ready to Deploy!

Your system is optimized for VULTR + PLOI.IO deployment with:
- Automated deployments
- SSL certificates
- Monitoring
- Backups
- Easy scaling

Total setup time: ~2 hours
Monthly cost: $178 (vs $400+ elsewhere!)
