# OVU System - Quick Start Guide

## 🚀 מדריך מהיר להתחלה

### 🔑 גישה למערכת

#### URLs:
- **Main Portal:** https://ovu.co.il
- **ULM React:** https://ulm-rct.ovu.co.il
- **AAM React:** https://aam-rct.ovu.co.il

#### Login Credentials:
```
Admin User:
  Username: admin
  Email: noam@datapc.co.il
  Password: [your password]

Test User:
  Username: testuser
  Email: test@ovu.co.il
  Password: [your password]
```

---

## 🖥️ גישה לשרתים

### Frontend Server:
```bash
ssh -i ~/.ssh/ovu_key ploi@64.176.173.105
```

### Backend Server:
```bash
ssh -i ~/.ssh/ovu_key ploi@64.176.171.223
```

### Database Server:
```bash
ssh -i ~/.ssh/ovu_key ploi@64.177.67.215
```

---

## 🔧 פעולות נפוצות

### 1. Deploy Frontend (ULM):
```bash
ssh -i ~/.ssh/ovu_key ploi@64.176.173.105 "
cd /home/ploi/ulm-react && 
npm run build && 
rm -rf /home/ploi/ulm-rct.ovu.co.il/public/* && 
cp -r dist/* /home/ploi/ulm-rct.ovu.co.il/public/
"
```

### 2. Deploy Frontend (AAM):
```bash
ssh -i ~/.ssh/ovu_key ploi@64.176.173.105 "
cd /home/ploi/aam-react && 
npm run build && 
rm -rf /home/ploi/aam-rct.ovu.co.il/public/* && 
cp -r dist/* /home/ploi/aam-rct.ovu.co.il/public/
"
```

### 3. Restart Backend (ULM):
```bash
ssh -i ~/.ssh/ovu_key ploi@64.176.171.223 "
pkill -f 'uvicorn.*8001' && 
cd /home/ploi/ovu-ulm/backend && 
source venv/bin/activate && 
nohup uvicorn app.main_simple:app --host 0.0.0.0 --port 8001 > /tmp/ulm_backend.log 2>&1 &
"
```

### 4. Check Backend Status:
```bash
ssh -i ~/.ssh/ovu_key ploi@64.176.171.223 "
ps aux | grep uvicorn && 
echo '---' && 
tail -20 /tmp/ulm_backend.log
"
```

### 5. Check Backend Health:
```bash
ssh -i ~/.ssh/ovu_key ploi@64.176.171.223 "curl -s http://localhost:8001/health"
```

### 6. Database Query:
```bash
ssh -i ~/.ssh/ovu_key ploi@64.177.67.215 "
PGPASSWORD='OvuDbUser2025Secure!Pass' psql -h localhost -U ovu_user -d ulm_db -c 'SELECT COUNT(*) FROM users;'
"
```

### 7. View All Users:
```bash
ssh -i ~/.ssh/ovu_key ploi@64.177.67.215 "
PGPASSWORD='OvuDbUser2025Secure!Pass' psql -h localhost -U ovu_user -d ulm_db -c 'SELECT id, username, email, role, phone FROM users ORDER BY id;'
"
```

### 8. Backup Database:
```bash
ssh -i ~/.ssh/ovu_key ploi@64.177.67.215 "
PGPASSWORD='OvuDbUser2025Secure!Pass' pg_dump -h localhost -U ovu_user ulm_db > /home/ploi/backups/ulm_db_\$(date +%Y%m%d_%H%M%S).sql
"
```

---

## 🐛 פתרון בעיות מהיר

### Backend לא עובד (502):
```bash
# בדוק לוג
ssh -i ~/.ssh/ovu_key ploi@64.176.171.223 "tail -50 /tmp/ulm_backend.log"

# הפעל מחדש
ssh -i ~/.ssh/ovu_key ploi@64.176.171.223 "
pkill -f 'uvicorn.*8001' && 
cd /home/ploi/ovu-ulm/backend && 
source venv/bin/activate && 
nohup uvicorn app.main_simple:app --host 0.0.0.0 --port 8001 > /tmp/ulm_backend.log 2>&1 &
"
```

### Frontend לא מתעדכן:
```bash
# נקה cache בדפדפן: Ctrl + Shift + R

# בנה מחדש
ssh -i ~/.ssh/ovu_key ploi@64.176.173.105 "
cd /home/ploi/ulm-react && 
npm run build && 
rm -rf /home/ploi/ulm-rct.ovu.co.il/public/* && 
cp -r dist/* /home/ploi/ulm-rct.ovu.co.il/public/
"
```

### בעיות התחברות:
```bash
# נקה sessions ישנים
ssh -i ~/.ssh/ovu_key ploi@64.177.67.215 "
PGPASSWORD='OvuDbUser2025Secure!Pass' psql -h localhost -U ovu_user -d ulm_db -c \"DELETE FROM sessions WHERE expires_at < NOW();\"
"
```

---

## 📊 מידע מהיר על המערכת

### Ports:
- ULM Backend: 8001
- AAM Backend: 8002
- PostgreSQL: 5432
- HTTP: 80
- HTTPS: 443

### Main Directories:
```
Frontend Server (64.176.173.105):
  /home/ploi/ulm-react/          - ULM React source
  /home/ploi/aam-react/          - AAM React source
  /home/ploi/ulm-rct.ovu.co.il/public/  - ULM deployed
  /home/ploi/aam-rct.ovu.co.il/public/  - AAM deployed
  /home/ploi/shared-components/  - Shared React components

Backend Server (64.176.171.223):
  /home/ploi/ovu-ulm/backend/    - ULM backend
  /home/ploi/ovu-aam/backend/    - AAM backend
  /tmp/ulm_backend.log           - ULM logs
  /tmp/aam_backend.log           - AAM logs
```

### Key Features:
- ✅ JWT Authentication
- ✅ Role-based Access (user, admin, super_admin)
- ✅ Advanced User Management
- ✅ Per-column Search & Filtering
- ✅ Phone Number Support
- ✅ Created By Tracking
- ✅ Password Reset
- ✅ Light/Dark Mode
- ✅ RTL/LTR Support
- ✅ 3 Languages (he/en/ar)

---

## 📞 צור קשר

**Developer:** Noam Broner  
**Email:** noam@datapc.co.il

---

**למידע מפורט, ראה:** [OVU_README.md](./OVU_README.md)
