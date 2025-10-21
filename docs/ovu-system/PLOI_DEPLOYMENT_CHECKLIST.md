# ✅ PLOI.IO Deployment Checklist for OVU System

## 📋 Pre-Deployment Checklist

### VULTR Account Setup
- [ ] VULTR account created
- [ ] Payment method added
- [ ] API key generated for PLOI integration

### PLOI.IO Account Setup  
- [ ] PLOI account created (https://ploi.io)
- [ ] VULTR provider connected in PLOI
- [ ] SSH keys configured

### Domain & DNS
- [ ] Domain registered (ovu.co.il)
- [ ] DNS nameservers pointed to VULTR/Cloudflare
- [ ] A records created:
  - [ ] `ovu.co.il` → Frontend Server IP
  - [ ] `ulm.ovu.co.il` → Frontend Server IP  
  - [ ] `aam.ovu.co.il` → Frontend Server IP
  - [ ] `api.ovu.co.il` → Backend Server IP
  - [ ] `db.ovu.co.il` → Database Server IP (optional)

## 🖥️ Server Creation (via PLOI)

### 1. Database Server
- [ ] Create server in PLOI (6 vCPU, 16GB RAM)
- [ ] Name: `database-ovu`
- [ ] Install PostgreSQL 16
- [ ] Install Redis
- [ ] Create databases:
  - [ ] `ulm_db`
  - [ ] `aam_db`
- [ ] Create user: `ovu_user`
- [ ] Enable remote connections
- [ ] Add Backend Server IP to firewall

### 2. Backend Server
- [ ] Create server in PLOI (4 vCPU, 8GB RAM)
- [ ] Name: `backend-ovu`
- [ ] Run Python installation script
- [ ] Create site: `api.ovu.co.il`
- [ ] Add environment variables
- [ ] Setup Git repository
- [ ] Configure deployment script

### 3. Frontend Server
- [ ] Create server in PLOI (2 vCPU, 4GB RAM)
- [ ] Name: `frontend-ovu`
- [ ] Create sites:
  - [ ] `ulm.ovu.co.il`
  - [ ] `aam.ovu.co.il`
  - [ ] `ovu.co.il`
- [ ] Setup Git deployment

## 📦 Application Deployment

### Backend Deployment
- [ ] SSH into backend server
- [ ] Clone repository
- [ ] Create Python virtual environment
- [ ] Install dependencies
- [ ] Configure Supervisor daemons:
  - [ ] ULM service (port 8001)
  - [ ] AAM service (port 8002)
- [ ] Test API endpoints:
  - [ ] `http://api.ovu.co.il:8001/health`
  - [ ] `http://api.ovu.co.il:8002/health`

### Frontend Deployment
- [ ] Build Flutter apps locally:
  ```bash
  cd services/ulm/frontend/flutter
  flutter build web --release
  
  cd services/aam/frontend/flutter  
  flutter build web --release
  ```
- [ ] Deploy to frontend server
- [ ] Configure NGINX for each site
- [ ] Test frontend access

## 🔒 Security & SSL

### SSL Certificates (via PLOI)
- [ ] Enable Let's Encrypt for:
  - [ ] `ulm.ovu.co.il`
  - [ ] `aam.ovu.co.il`
  - [ ] `api.ovu.co.il`
  - [ ] `ovu.co.il`
- [ ] Force HTTPS redirect
- [ ] Test SSL configuration

### Firewall Rules (via PLOI)
- [ ] Database server: Only allow Backend IP
- [ ] Backend server: Allow Frontend IP + public API
- [ ] Frontend server: Allow public HTTP/HTTPS

## 🔧 Configuration

### Environment Variables (PLOI Dashboard)
- [ ] Database credentials set
- [ ] Redis password set
- [ ] Secret keys generated
- [ ] CORS origins configured
- [ ] Email settings (if needed)

### NGINX Configuration
- [ ] API proxy rules added
- [ ] WebSocket support (if needed)
- [ ] Gzip compression enabled
- [ ] Cache headers configured

## 🧪 Testing

### API Testing
```bash
# ULM Health Check
curl https://api.ovu.co.il/ulm/health

# AAM Health Check
curl https://api.ovu.co.il/aam/health

# Test user registration
curl -X POST https://api.ovu.co.il/ulm/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'
```

### Frontend Testing
- [ ] Access https://ulm.ovu.co.il
- [ ] Access https://aam.ovu.co.il
- [ ] Test login functionality
- [ ] Test API communication
- [ ] Check browser console for errors

### Database Testing
```bash
# From backend server
psql -h YOUR_DB_IP -U ovu_user -d ulm_db -c "SELECT 1;"
redis-cli -h YOUR_DB_IP -a YOUR_REDIS_PASSWORD ping
```

## 📊 Monitoring Setup

### PLOI Monitoring
- [ ] Server monitoring enabled
- [ ] Uptime monitoring configured
- [ ] Email alerts setup
- [ ] Slack/Discord notifications (optional)

### Application Logs
- [ ] Check ULM logs: `/var/www/ovu-backend/logs/ulm.log`
- [ ] Check AAM logs: `/var/www/ovu-backend/logs/aam.log`
- [ ] Check NGINX logs: `/var/log/nginx/*.log`

## 🔄 Backup Configuration

### Database Backups (via PLOI)
- [ ] Daily backups enabled
- [ ] Backup retention: 30 days
- [ ] Test backup restoration

### Code Backups
- [ ] Git repository up to date
- [ ] All environment variables documented

## 🚀 Go Live

### Final Checks
- [ ] All health checks passing
- [ ] SSL certificates valid
- [ ] DNS propagated
- [ ] Monitoring active
- [ ] Backups configured

### Launch Steps
1. [ ] Test with staging data
2. [ ] Clear test data
3. [ ] Create admin user
4. [ ] Update DNS TTL (lower for quick changes)
5. [ ] Announce go-live

## 📝 Post-Deployment

### Documentation
- [ ] Document all credentials securely
- [ ] Create runbook for common tasks
- [ ] Document deployment process
- [ ] Share access with team

### Optimization
- [ ] Enable Cloudflare CDN (optional)
- [ ] Configure caching rules
- [ ] Optimize database indexes
- [ ] Set up log rotation

## 🆘 Troubleshooting

### Common Issues

#### FastAPI not starting
```bash
# Check supervisor status
sudo supervisorctl status

# View logs
tail -f /var/www/ovu-backend/logs/ulm.log

# Restart service
sudo supervisorctl restart ovu-ulm:*
```

#### Database connection failed
```bash
# Test connection
psql -h db_ip -U ovu_user -d ulm_db

# Check firewall
sudo ufw status

# Verify credentials in PLOI environment
```

#### Frontend not loading
```bash
# Check NGINX
sudo nginx -t
sudo systemctl status nginx

# Check file permissions
ls -la /var/www/ulm-ovu/public/

# View NGINX errors
tail -f /var/log/nginx/error.log
```

## 📞 Support Contacts

- VULTR Support: https://www.vultr.com/contact/
- PLOI Support: support@ploi.io
- PLOI Docs: https://ploi.io/documentation

## 🎉 Success Criteria

Your deployment is successful when:
- ✅ All services respond to health checks
- ✅ Users can register and login
- ✅ Admin panel is accessible
- ✅ API endpoints work correctly
- ✅ SSL certificates are active
- ✅ Monitoring shows all green
- ✅ Backups are running
- ✅ No errors in logs

---

**Estimated Deployment Time**: 2-3 hours
**Monthly Cost**: $178 (VULTR + PLOI)
