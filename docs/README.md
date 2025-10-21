# OVU System Documentation 📚

**Comprehensive documentation for the OVU (User Login Manager & Admin Area Manager) system.**

---

## 🎯 Quick Links

- **[📖 Complete Documentation](./OVU_README.md)** - Full system documentation (900+ lines)
- **[🚀 Quick Start Guide](./QUICKSTART.md)** - Get started in 5 minutes
- **[✅ Deployment Checklist](./OVU_DEPLOYMENT_CHECKLIST.md)** - Production deployment steps

---

## 📋 What's Included

### 📚 Documentation Files:
- **OVU_README.md** - Complete system documentation
  - Architecture overview
  - Access credentials
  - Features list
  - Database schema
  - API documentation
  - Troubleshooting guide

- **QUICKSTART.md** - Quick start guide
  - Common operations
  - Quick troubleshooting
  - Essential commands

- **OVU_SYSTEM_README.md** - System overview
- **OVU_DEPLOYMENT_CHECKLIST.md** - Deployment checklist

### 🛠️ Setup Scripts:
- **ploi-setup-backend.sh** - Backend setup automation
- **ploi-setup-frontend.sh** - Frontend setup automation
- **ploi-database-setup.sql** - Database initialization
- **ploi-nginx-configs.md** - Nginx configurations
- **ploi-supervisor-config.md** - Supervisor configurations

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     OVU System                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Frontend Apps:                                         │
│  ├─ Main Portal (ovu.co.il)                            │
│  ├─ ULM React (ulm-rct.ovu.co.il)                      │
│  ├─ ULM Flutter (ulm-flt.ovu.co.il)                    │
│  ├─ AAM React (aam-rct.ovu.co.il)                      │
│  └─ AAM Flutter (aam-flt.ovu.co.il)                    │
│                                                         │
│  Backend Services:                                      │
│  ├─ ULM API (64.176.171.223:8001) - FastAPI            │
│  └─ AAM API (64.176.171.223:8002) - FastAPI            │
│                                                         │
│  Database:                                              │
│  └─ PostgreSQL (64.177.67.215:5432)                    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## ✨ Key Features

- ✅ **JWT Authentication** with role-based access control
- ✅ **Advanced User Management** with CRUD operations
- ✅ **Per-column Search & Filtering** in tables
- ✅ **Phone Number Support** for users
- ✅ **Created By Tracking** for audit trails
- ✅ **Password Reset** (admin only)
- ✅ **Light/Dark Mode** toggle
- ✅ **RTL/LTR Support** (Hebrew, English, Arabic)
- ✅ **Modern 2025 Design** with smooth animations
- ✅ **Responsive Layout** (mobile, tablet, desktop)

---

## 🚀 Getting Started

### Quick Access:
```bash
# Frontend Server
ssh -i ~/.ssh/ovu_key ploi@64.176.173.105

# Backend Server
ssh -i ~/.ssh/ovu_key ploi@64.176.171.223

# Database Server
ssh -i ~/.ssh/ovu_key ploi@64.177.67.215
```

### Quick Deploy:
```bash
# Deploy ULM Frontend
ssh -i ~/.ssh/ovu_key ploi@64.176.173.105 "
cd /home/ploi/ulm-react && 
npm run build && 
rm -rf /home/ploi/ulm-rct.ovu.co.il/public/* && 
cp -r dist/* /home/ploi/ulm-rct.ovu.co.il/public/
"

# Restart ULM Backend
ssh -i ~/.ssh/ovu_key ploi@64.176.171.223 "
pkill -f 'uvicorn.*8001' && 
cd /home/ploi/ovu-ulm/backend && 
source venv/bin/activate && 
nohup uvicorn app.main_simple:app --host 0.0.0.0 --port 8001 > /tmp/ulm_backend.log 2>&1 &
"
```

---

## 📊 Recent Updates

### Session 76 (Oct 5, 2025):
- ✅ Added `phone` field to users table
- ✅ Added `created_by_id` tracking
- ✅ Implemented AddUserModal component
- ✅ Implemented ResetPasswordModal component
- ✅ Fixed table column ordering
- ✅ Updated GET /users endpoint
- ✅ Enhanced UsersTable with advanced filtering
- ✅ Improved UI/UX with animations

### Session 75 (Oct 4, 2025):
- ✅ Fixed AAM production deployment
- ✅ Restored Nginx configs
- ✅ All 3 AAM services working (base, main, roleinstaller)
- ✅ HTTPS/SSL working correctly

---

## 📞 Support & Contact

**Developer:** Noam Broner  
**Email:** noam@datapc.co.il  
**GitHub:** [@noambroner](https://github.com/noambroner)

---

## 📄 License

Proprietary - All rights reserved

---

**Last Updated:** October 5, 2025  
**Version:** 2.0  
**Status:** Production Ready ✅
