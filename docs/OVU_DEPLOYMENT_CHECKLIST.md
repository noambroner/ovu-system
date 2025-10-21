# 🚀 OVU System Complete Deployment Checklist

## 📌 Quick Reference
- **Total Cost:** ~$178/month (VULTR + PLOI)
- **Time Required:** 2-3 hours
- **Servers Needed:** 3 (Frontend, Backend, Database)
- **GitHub Repos:** Already created ✅

---

## ✅ Phase 1: Account Setup (15 minutes)

### VULTR Account
- [ ] Sign up at [vultr.com](https://www.vultr.com)
- [ ] Add payment method
- [ ] Get API key from Account → API

### PLOI.IO Account
- [ ] Sign up at [ploi.io](https://ploi.io)
- [ ] Choose plan: "Unlimited" ($10/month)
- [ ] Connect VULTR API key in Providers section

---

## ✅ Phase 2: Server Creation (20 minutes)

### In PLOI Dashboard → Servers → Create Server

#### 1. Database Server
- [ ] **Name:** database-ovu
- [ ] **Provider:** VULTR
- [ ] **Region:** Choose closest to users
- [ ] **Size:** 6 vCPU / 16GB RAM ($96/month)
- [ ] **OS:** Ubuntu 22.04
- [ ] **Database:** PostgreSQL 16
- [ ] **Additional:** Redis
- [ ] Click "Create Server"

#### 2. Backend Server
- [ ] **Name:** backend-ovu
- [ ] **Provider:** VULTR
- [ ] **Region:** Same as database
- [ ] **Size:** 4 vCPU / 8GB RAM ($48/month)
- [ ] **OS:** Ubuntu 22.04
- [ ] **PHP Version:** None (we'll use Python)
- [ ] Click "Create Server"

#### 3. Frontend Server
- [ ] **Name:** frontend-ovu
- [ ] **Provider:** VULTR
- [ ] **Region:** Same as others
- [ ] **Size:** 2 vCPU / 4GB RAM ($24/month)
- [ ] **OS:** Ubuntu 22.04
- [ ] **PHP Version:** None
- [ ] Click "Create Server"

### Wait for servers to provision (~5-10 minutes)

---

## ✅ Phase 3: Database Setup (15 minutes)

### On database-ovu server in PLOI:

#### PostgreSQL Setup
- [ ] Server → Database → Create Database
  - [ ] Database name: `ulm_db`
  - [ ] Username: `ovu_user`
  - [ ] Password: Generate strong password (SAVE IT!)
- [ ] Create second database:
  - [ ] Database name: `aam_db`
  - [ ] Same user: `ovu_user`

#### Redis Setup
- [ ] Server → Services → Install Redis
- [ ] Set Redis password (SAVE IT!)

#### Network Configuration
- [ ] Server → Network → Firewall Rules
- [ ] Add rule: Allow from backend-ovu IP on port 5432 (PostgreSQL)
- [ ] Add rule: Allow from backend-ovu IP on port 6379 (Redis)

#### Run Database Schema
- [ ] SSH to database server or use PLOI's Database Manager
- [ ] Run the SQL from `ploi-database-setup.sql`
- [ ] Change default admin password!

---

## ✅ Phase 4: Backend Setup (30 minutes)

### On backend-ovu server in PLOI:

#### Run Setup Script
- [ ] Server → Scripts → New Script
- [ ] Name: "Backend Setup"
- [ ] User: root
- [ ] Paste content from `ploi-setup-backend.sh`
- [ ] Run script

#### Configure Environment
- [ ] Copy `/var/www/ovu-backend/.env.example` to `.env`
- [ ] Update with your values:
  ```env
  DB_HOST=YOUR_DATABASE_SERVER_IP
  DB_PASSWORD=YOUR_DB_PASSWORD
  REDIS_HOST=YOUR_DATABASE_SERVER_IP
  REDIS_PASSWORD=YOUR_REDIS_PASSWORD
  SECRET_KEY=GENERATE_RANDOM_64_CHARS
  JWT_SECRET=GENERATE_RANDOM_64_CHARS
  ```

#### Create Supervisor Daemons
- [ ] Server → Daemons → Create (ULM Service)
  - Command: `/var/www/ovu-backend/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8001`
  - Directory: `/var/www/ovu-backend/ulm/backend`
  - User: ploi
- [ ] Server → Daemons → Create (AAM Service)
  - Command: `/var/www/ovu-backend/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8002`
  - Directory: `/var/www/ovu-backend/aam/backend`
  - User: ploi

#### Test APIs
- [ ] Check ULM: `curl http://BACKEND_IP:8001/docs`
- [ ] Check AAM: `curl http://BACKEND_IP:8002/docs`

---

## ✅ Phase 5: Frontend Setup (30 minutes)

### On frontend-ovu server in PLOI:

#### Run Setup Script
- [ ] Server → Scripts → New Script
- [ ] Name: "Frontend Setup"
- [ ] User: root
- [ ] Paste content from `ploi-setup-frontend.sh`
- [ ] Run script (this will take ~10 minutes)

#### Create Sites in PLOI

##### Site 1: ULM
- [ ] Sites → Create Site
- [ ] Domain: `ulm.ovu.co.il`
- [ ] Web directory: `/ulm-frontend`
- [ ] Project type: HTML
- [ ] After creation: Update web directory to `/var/www/ulm-frontend`

##### Site 2: AAM
- [ ] Sites → Create Site
- [ ] Domain: `aam.ovu.co.il`
- [ ] Web directory: `/aam-frontend`
- [ ] Project type: HTML
- [ ] After creation: Update web directory to `/var/www/aam-frontend`

##### Site 3: Main
- [ ] Sites → Create Site
- [ ] Domain: `ovu.co.il`
- [ ] Web directory: `/ovu-main`
- [ ] Project type: HTML
- [ ] After creation: Update web directory to `/var/www/ovu-main`

---

## ✅ Phase 6: NGINX Configuration (15 minutes)

### For each site in PLOI:

#### ULM Site
- [ ] Sites → ulm.ovu.co.il → NGINX Configuration
- [ ] Replace with config from `ploi-nginx-configs.md`
- [ ] Update `BACKEND_SERVER_IP` with actual IP
- [ ] Save and reload NGINX

#### AAM Site
- [ ] Sites → aam.ovu.co.il → NGINX Configuration
- [ ] Replace with config from `ploi-nginx-configs.md`
- [ ] Update `BACKEND_SERVER_IP` with actual IP
- [ ] Save and reload NGINX

#### Main Site
- [ ] Sites → ovu.co.il → NGINX Configuration
- [ ] Replace with config from `ploi-nginx-configs.md`
- [ ] Save and reload NGINX

---

## ✅ Phase 7: SSL Certificates (10 minutes)

### For each site:
- [ ] Sites → [site] → SSL → Let's Encrypt
- [ ] Enable SSL
- [ ] Force HTTPS redirect
- [ ] Wait for certificate generation

---

## ✅ Phase 8: DNS Configuration (10 minutes)

### In your DNS provider:

```dns
# A Records
ovu.co.il         → FRONTEND_SERVER_IP
www.ovu.co.il     → FRONTEND_SERVER_IP
ulm.ovu.co.il     → FRONTEND_SERVER_IP
aam.ovu.co.il     → FRONTEND_SERVER_IP
api.ovu.co.il     → BACKEND_SERVER_IP (optional)
```

---

## ✅ Phase 9: Testing (15 minutes)

### Basic Tests
- [ ] Visit https://ovu.co.il - Should show landing page
- [ ] Visit https://ulm.ovu.co.il - Should show ULM app
- [ ] Visit https://aam.ovu.co.il - Should show AAM app
- [ ] Test language switching on landing page
- [ ] Test API: `curl https://ulm.ovu.co.il/api/health`
- [ ] Test API: `curl https://aam.ovu.co.il/api/health`

### Login Test
- [ ] Try login at AAM with default admin
- [ ] **IMMEDIATELY CHANGE DEFAULT PASSWORD**

---

## ✅ Phase 10: Security & Monitoring (15 minutes)

### Security
- [ ] Change all default passwords
- [ ] Enable 2FA in PLOI account
- [ ] Server → Security → Enable Fail2ban
- [ ] Server → Security → Enable Firewall
- [ ] Server → Security → Enable automatic updates

### Monitoring
- [ ] Server → Monitoring → Enable monitoring
- [ ] Sites → [each site] → Uptime monitoring
- [ ] Set up alert notifications

### Backups
- [ ] Server → Backups → Configure daily backups
- [ ] Especially important for database server

---

## 📝 Post-Deployment Tasks

### Immediate
- [ ] Change default admin password
- [ ] Document all passwords securely
- [ ] Test all functionality
- [ ] Set up email service (if needed)

### Within 24 Hours
- [ ] Configure backup retention policy
- [ ] Set up monitoring alerts
- [ ] Review server logs for errors
- [ ] Performance testing

### Within 1 Week
- [ ] Security audit
- [ ] Load testing
- [ ] Documentation update
- [ ] Team training (if applicable)

---

## 🆘 Troubleshooting

### API Not Responding
```bash
# Check daemon status in PLOI
Server → Daemons → Check status

# Or SSH and check
sudo supervisorctl status
tail -f /var/log/supervisor/*.log
```

### Database Connection Failed
```bash
# Test connection
psql -h DATABASE_IP -U ovu_user -d ulm_db

# Check firewall
Server → Network → Firewall Rules
```

### Frontend Not Loading
```bash
# Check NGINX
nginx -t
systemctl status nginx

# Check build files exist
ls -la /var/www/ulm-frontend/
ls -la /var/www/aam-frontend/
```

---

## 📞 Support Resources

- **PLOI Support:** support@ploi.io
- **VULTR Support:** Through dashboard ticket
- **OVU GitHub:** https://github.com/noambroner/ovu-*
- **FastAPI Docs:** https://fastapi.tiangolo.com
- **Flutter Docs:** https://flutter.dev/docs

---

## 🎉 Congratulations!

Your OVU system should now be live and running on:
- Main: https://ovu.co.il
- ULM: https://ulm.ovu.co.il
- AAM: https://aam.ovu.co.il

Total deployment time: ~2-3 hours
Monthly cost: $178

**Remember to monitor your servers and keep everything updated!**







