# 🏢 OVU Management System - תיעוד מלא

## 📋 תוכן עניינים
1. [סקירה כללית](#סקירה-כללית)
2. [ארכיטקטורה](#ארכיטקטורה)
3. [שרתים ופרטי גישה](#שרתים-ופרטי-גישה)
4. [URLs ואתרים](#urls-ואתרים)
5. [מסד נתונים](#מסד-נתונים)
6. [פרטי התחברות למערכות](#פרטי-התחברות-למערכות)
7. [טכנולוגיות](#טכנולוגיות)
8. [מבנה תיקיות](#מבנה-תיקיות)
9. [מצב נוכחי](#מצב-נוכחי)
10. [צעדים הבאים](#צעדים-הבאים)
11. [פתרון בעיות](#פתרון-בעיות)

---

## 🎯 סקירה כללית

מערכת OVU היא מערכת ניהול ארגונית המורכבת משני מודולים עיקריים:
- **ULM** (User Login Manager) - מערכת ניהול משתמשים
- **AAM** (Admin Area Manager) - מערכת ניהול מנהלים

כל מודול זמין בשתי טכנולוגיות Frontend:
- **React** (Vite + TypeScript)
- **Flutter Web**

---

## 🏗️ ארכיטקטורה

המערכת מורכבת מ-3 שרתים נפרדים:

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│  Frontend       │◄────────│  Backend        │◄────────│  Database       │
│  Server         │         │  Server         │         │  Server         │
├─────────────────┤         ├─────────────────┤         ├─────────────────┤
│ • React Apps    │         │ • FastAPI       │         │ • PostgreSQL 17 │
│ • Flutter Apps  │         │ • ULM API :8001 │         │ • ulm_db (8)    │
│ • Nginx         │         │ • AAM API :8002 │         │ • aam_db (4)    │
│ • HTTPS/SSL     │         │ • Python 3.11   │         │ • Redis         │
│ • Git Repos     │         │ • Uvicorn       │         │ • (DB Only!)    │
└─────────────────┘         └─────────────────┘         └─────────────────┘
   64.176.173.105            64.176.171.223              64.177.67.215
```

---

## 🔐 שרתים ופרטי גישה

### 1️⃣ Frontend Server
```
IP: 64.176.173.105
OS: Ubuntu 24.04 LTS
User: ploi
Sudo Password: 43ACBUHlZWOxwAueKji8
SSH Key: ~/.ssh/ovu_key (ED25519)

Services:
- Nginx (web server)
- React Apps (Vite build)
- Flutter Apps (built web apps)

Ports:
- 80 (HTTP)
- 443 (HTTPS)
```

**התחברות SSH:**
```bash
ssh -i ~/.ssh/ovu_key ploi@64.176.173.105
```

### 2️⃣ Backend Server
```
IP: 64.176.171.223
OS: Ubuntu 24.04 LTS
User: ploi
Sudo Password: mb9z7KRSD9VVQLgpb596
SSH Key: ~/.ssh/ovu_key (ED25519)

Services:
- ULM Backend API (port 8001)
- AAM Backend API (port 8002)
- Supervisor (process manager)
- Python 3.11 + FastAPI

Ports:
- 8001 (ULM API)
- 8002 (AAM API)
- 8000 (Main API - legacy)
```

**התחברות SSH:**
```bash
ssh -i ~/.ssh/ovu_key ploi@64.176.171.223
```

**API Endpoints:**
- ULM: http://64.176.171.223:8001/health
- ULM Docs: http://64.176.171.223:8001/api/v1/docs
- AAM: http://64.176.171.223:8002/health
- AAM Architecture: Uses ULM API for authentication (microservice pattern)

### 3️⃣ Database Server
```
IP: 64.177.67.215
OS: Ubuntu 24.04 LTS
User: ploi
Sudo Password: 0BweAsz8ptKfsYuBt5Dy
SSH Key: ~/.ssh/ovu_key (ED25519)

Services:
- PostgreSQL 17
- Redis

Databases:
- ulm_db (User Login Manager) - 8 tables
- aam_db (Admin Area Manager) - 4 tables

DB User: ovu_user
DB Password: Ovu123456!!@@##

Port:
- 5432 (PostgreSQL)
- 6379 (Redis)

Note: אין Backend רץ בשרת זה!
Backend רץ רק בשרת 64.176.171.223
```

**התחברות SSH:**
```bash
ssh -i ~/.ssh/ovu_key ploi@64.177.67.215
```

**התחברות לPostgreSQL:**
```bash
# מהשרת עצמו
sudo -u postgres psql -d ulm_db
sudo -u postgres psql -d aam_db
```

---

## 🌐 URLs ואתרים

### אתר ראשי
- **Main Portal:** https://ovu.co.il
  - עיצוב: רקע gradient סגול, כרטיסיות לבנות
  - קישורים לכל המערכות

### ULM - User Login Manager
- **React:** https://ulm-rct.ovu.co.il
  - עיצוב: Split panel, gradient סגול
- **Flutter:** https://ulm-flt.ovu.co.il
  - עיצוב: Flutter Material Design

### AAM - Admin Area Manager
- **React:** https://aam-rct.ovu.co.il
  - עיצוב: Split panel, gradient אדום/כתום
- **Flutter:** https://aam-flt.ovu.co.il
  - עיצוב: Flutter Material Design

### DNS Configuration
```
Domain: ovu.co.il
Registrar: [מנוהל ידנית]
DNS: Cloudflare
Zone ID: d3a87a072374499a46c199b7a966f93e

DNS Records (all Proxied 🟠):
- ovu.co.il → 64.176.173.105
- ulm-rct.ovu.co.il → 64.176.173.105
- ulm-flt.ovu.co.il → 64.176.173.105
- aam-rct.ovu.co.il → 64.176.173.105
- aam-flt.ovu.co.il → 64.176.173.105

SSL Mode: Full (Strict)
SSL Certificate: Cloudflare Universal SSL (automatic)
```

### Cloudflare API
```
API Token: HcvQOe-t0pblxIG2IkRo_wJ2ppkxdOp1fEBrkpGS
Permissions: DNS Edit, Zone Read
```

---

## 💾 מסד נתונים

### ULM Database (ulm_db)

**טבלאות עיקריות:**
```sql
users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE,
  username VARCHAR(100) UNIQUE,
  hashed_password VARCHAR(255),
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  preferred_language VARCHAR(10) DEFAULT 'he',
  is_active BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

sessions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  session_token VARCHAR(255) UNIQUE,
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE,
  permissions JSONB
)
```

**משתמשים קיימים:**
- test@ovu.co.il / testuser / test123
- admin@ovu.co.il / admin / test123

### AAM Database (aam_db)

**טבלאות עיקריות:**
```sql
admins (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE,
  username VARCHAR(100) UNIQUE,
  hashed_password VARCHAR(255),
  full_name VARCHAR(200),
  role_id INTEGER,
  is_active BOOLEAN DEFAULT true,
  is_super_admin BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

admin_sessions (
  id SERIAL PRIMARY KEY,
  admin_id INTEGER REFERENCES admins(id),
  session_token VARCHAR(255) UNIQUE,
  ip_address VARCHAR(45),
  expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

activity_logs (
  id SERIAL PRIMARY KEY,
  admin_id INTEGER REFERENCES admins(id),
  action VARCHAR(255),
  details JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
```

**מנהלים קיימים:**
- admin@ovu.co.il / admin / [סיסמה לא ידועה - צריך reset]

---

## 🔑 פרטי התחברות למערכות

### ULM (User Login Manager)
```
URL: https://ulm-rct.ovu.co.il (React)
URL: https://ulm-flt.ovu.co.il (Flutter)

משתמש 1:
  Email: test@ovu.co.il
  Username: testuser
  Password: test123

משתמש 2:
  Email: admin@ovu.co.il
  Username: admin
  Password: test123
```

### AAM (Admin Area Manager)
```
URL: https://aam-rct.ovu.co.il (React)
URL: https://aam-flt.ovu.co.il (Flutter)

מנהל:
  Email: admin@ovu.co.il
  Username: admin
  Password: [צריך reset - הסיסמה לא עובדת כרגע]
```

### PLOI.io (Server Management)
```
URL: https://ploi.io
Email: [הדוא"ל שלך]

API Token: eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiNWIzMmYzNDg3YmM0ZjRlMjIwMDRiYzI3ZjlhMWVjMmE2NTUyMTk5NmY5NTllM2UzNGRmNThkOGU0MmNhNTg1YWMyYTFiODk5OGQ3YTBiYTkiLCJpYXQiOjE3NTk1Njk3OTEuMDkwMzMsIm5iZiI6MTc1OTU2OTc5MS4wOTAzMzIsImV4cCI6MTgyMjY0MTc5MS4wODc0OCwic3ViIjoiMjk2MzciLCJzY29wZXMiOlsic2VydmVycy1yZWFkIiwic2VydmVycy1jcmVhdGUiLCJzZXJ2ZXJzLWRlbGV0ZSIsImRhdGFiYXNlLXJlYWQiLCJkYXRhYmFzZS1jcmVhdGUiLCJkYXRhYmFzZS1kZWxldGUiLCJkYWVtb25zLXJlYWQiLCJkYWVtb25zLWNyZWF0ZSIsImRhZW1vbnMtZGVsZXRlIiwiY3JvbmpvYnMtcmVhZCIsImNyb25qb2JzLWNyZWF0ZSIsImNyb25qb2JzLWRlbGV0ZSIsIm5ldHdvcmstcnVsZXMtcmVhZCIsIm5ldHdvcmstcnVsZXMtY3JlYXRlIiwibmV0d29yay1ydWxlcy1kZWxldGUiLCJzeXN0ZW0tdXNlcnMtcmVhZCIsInN5c3RlbS11c2Vycy1jcmVhdGUiLCJzeXN0ZW0tdXNlcnMtZGVsZXRlIiwic3NoLWtleXMtcmVhZCIsInNzaC1rZXlzLWNyZWF0ZSIsInNzaC1rZXlzLWRlbGV0ZSIsInNpdGVzLXJlYWQiLCJzaXRlcy1jcmVhdGUiLCJzaXRlcy1kZWxldGUiLCJyZWRpcmVjdHMtcmVhZCIsInJlZGlyZWN0cy1jcmVhdGUiLCJyZWRpcmVjdHMtZGVsZXRlIiwiY2VydGlmaWNhdGVzLXJlYWQiLCJjZXJ0aWZpY2F0ZXMtY3JlYXRlIiwiY2VydGlmaWNhdGVzLWRlbGV0ZSIsImF1dGgtdXNlcnMtcmVhZCIsImF1dGgtdXNlcnMtY3JlYXRlIiwiYXV0aC11c2Vycy1kZWxldGUiLCJhbGlhc2VzLXJlYWQiLCJhbGlhc2VzLWNyZWF0ZSIsImFsaWFzZXMtZGVsZXRlIiwiZW1haWwiXX0.tnN3F-OmgSKJ_IN-wNUaEwgzGZcA06Xac0FY96ddHTAsTsjqTkWhx4ybZG1iH5KbXwMA9X5Guizmo5dJ-tmwjlqTgTEyBEA3BrUrmNC0uu0BMeBt-bZMB9GP9Ec7e1REo6OFu2cD-9M7omn4HicNpaSvwgq01J1fu4hb7_jAiP13TTmJNFTAeZCCBKbppCIoxSDDdqgoeWj9udKxtHD0G4h9ricUkBTwx6VEuPpNuOH62nVK3NoAFAoRkXtcguWcpkEWTujjhsOZBQpEWy0NHS4Iv5zafi-eQ5iV74O6ThhxahksZ4gbXZLJAbNGAd3xfJkxiqQqJXGvZYR9d3EBmXs9Cut-DkUoSDiQCBKkuq5fAAR51ybi9dfAbYI6FjGwDm6xXJbwywpyy47dEdf520c4LmFquK4f9nDhOMujfnutAcUeao-0T071Ewq7a-VVZA6jvg8ys10PkWBnbAcRP51fvouhJFfVDUZ21R7ecMsWCGRnrRwX6qDMWbhMghqp0kiy9SvVXraViMpl42gVHN90pL-Ngr4KNQDk5I2XuQFM68CyGRyV0IZjhP5ZwW0dfDeIkFI2KtW1kIzrqWXhBnem8vfJfWPU13qzoIjgSBKSxv2KsHBfkmLw_-aVEkIp3MPy1G0LBRXy4taJZKeUrUeiPH8SEVUr554T-rzAlR0

Servers:
- Frontend: Server ID 100381
- Backend: Server ID 100374
- Database: Server ID 100375
```

---

## 💻 טכנולוגיות

### Frontend
```yaml
React:
  - Framework: React 18
  - Build Tool: Vite 7
  - Language: TypeScript
  - Styling: Pure CSS (no framework)
  - Features:
    - RTL Support (Hebrew)
    - Responsive Design
    - Modern Gradient Design
    - White Background Theme

Flutter:
  - Version: Latest stable
  - Build: Flutter Web
  - Features:
    - Material Design
    - RTL Support
    - Multi-language (he, en, ar)
```

### Backend
```yaml
FastAPI:
  - Python: 3.11
  - Framework: FastAPI
  - Server: Uvicorn
  - Process Manager: Supervisor
  - Features:
    - RESTful API
    - JWT Authentication
    - CORS Enabled
    - Health Check Endpoints
    - Simple main_simple.py (current)
    - Full main.py (in development)
```

### Database
```yaml
PostgreSQL:
  - Version: 17
  - Databases: ulm_db, aam_db
  - User: ovu_user
  - Features:
    - Multi-database architecture
    - User authentication tables
    - Session management
    - Activity logging
    
Redis:
  - Version: Latest
  - Purpose: Session storage, caching
```

### Infrastructure
```yaml
Hosting:
  - Provider: VULTR
  - Management: PLOI.io
  - OS: Ubuntu 24.04 LTS
  - Web Server: Nginx
  - SSL: Cloudflare Universal SSL
  - CDN: Cloudflare
  - DDoS Protection: Cloudflare Proxy
```

---

## 📁 מבנה תיקיות

### Frontend Server (64.176.173.105)
```
/home/ploi/
├── ovu-react-main/           # Main portal React app
│   ├── src/
│   │   ├── App.tsx
│   │   └── App.css
│   ├── dist/                 # Built files
│   └── package.json
│
├── ulm-react/                # ULM React app
│   ├── src/
│   │   ├── App.tsx
│   │   └── App.css
│   └── dist/
│
├── aam-react/                # AAM React app
│   ├── src/
│   │   ├── App.tsx
│   │   └── App.css
│   └── dist/
│
├── www/
│   ├── ulm_simple/           # ULM Flutter built app
│   └── aam_simple/           # AAM Flutter built app
│
├── ovu.co.il/www/ovu/        # Deployed main site
├── ulm-rct.ovu.co.il/public/ # Deployed ULM React
├── ulm-flt.ovu.co.il/public/ # Deployed ULM Flutter
├── aam-rct.ovu.co.il/public/ # Deployed AAM React
└── aam-flt.ovu.co.il/public/ # Deployed AAM Flutter
```

### Backend Server (64.176.171.223)
```
/home/ploi/
├── ovu-ulm/
│   └── backend/
│       ├── app/
│       │   ├── main_simple.py    # Current running app
│       │   ├── main.py           # Full app (not used)
│       │   └── core/
│       │       └── config.py
│       ├── venv/
│       ├── requirements.txt
│       └── .env
│
├── ovu-aam/
│   └── backend/
│       ├── app/
│       │   ├── main_simple.py
│       │   ├── main.py
│       │   └── core/
│       ├── venv/
│       └── .env
│
└── api.ovu.co.il/
    └── (legacy main API)
```

### Database Server (64.177.67.215)
```
PostgreSQL Data:
/var/lib/postgresql/17/main/
```

---

## 📊 מצב נוכחי

### ✅ מה עובד:

1. **Infrastructure:**
   - ✅ 3 שרתים פועלים
   - ✅ HTTPS/SSL פעיל (Cloudflare Universal SSL)
   - ✅ DNS מוגדר נכון
   - ✅ DDoS Protection פעיל

2. **Backend:**
   - ✅ FastAPI רץ על שני השרתים (ULM, AAM)
   - ✅ Health endpoints עובדים
   - ✅ PostgreSQL פעיל עם 2 databases
   - ✅ משתמשים נוצרו ב-ulm_db

3. **Frontend:**
   - ✅ כל 5 האתרים חיים ונגישים
   - ✅ עיצוב מודרני ויפה
   - ✅ RTL Support
   - ✅ Responsive Design

### ⚠️ מה חסר/לא עובד:

1. **Frontend ↔ Backend Connection:**
   - ❌ React/Flutter לא שולחים API calls
   - ❌ כפתור "התחבר" לא מחובר לBackend
   - ❌ אין session management בFrontend
   - ❌ אין error handling

2. **Authentication Flow:**
   - ❌ Login לא עובד (UI בלבד)
   - ❌ אין JWT token management
   - ❌ אין session cookies

3. **AAM:**
   - ❌ סיסמת admin לא עובדת (צריך reset)

4. **Code Repository:**
   - ❌ הקוד לא הועלה ל-GitHub
   - ❌ אין גיבוי של הקוד
   - ❌ קיים רק בשרתים

---

## 🚀 צעדים הבאים

### Priority 1: חיבור Frontend ל-Backend
```
1. הוסף API client ל-React (axios/fetch)
2. צור login function שקוראת ל-Backend
3. הוסף JWT token management
4. צור protected routes
5. הוסף session management
```

### Priority 2: השלם AAM
```
1. Reset סיסמת admin
2. צור endpoint ל-password reset
3. בדוק authentication flow
```

### Priority 3: גיבוי וניהול קוד
```
1. צור GitHub repositories
2. העלה את כל הקוד
3. הוסף .gitignore
4. תעד שינויים
```

### Priority 4: שיפורים
```
1. הוסף loading states
2. הוסף error messages
3. שפר UX
4. הוסף form validation
5. הוסף "remember me"
6. הוסף "forgot password"
```

---

## 🔧 פתרון בעיות

### Backend לא עונה
```bash
# התחבר לשרת Backend
ssh -i ~/.ssh/ovu_key ploi@64.176.171.223

# בדוק סטטוס
ps aux | grep uvicorn

# בדוק logs
tail -f /var/log/supervisor/*.log

# אתחל את השירות
sudo supervisorctl restart ulm-backend
sudo supervisorctl restart aam-backend
```

### Frontend לא נטען
```bash
# התחבר לשרת Frontend
ssh -i ~/.ssh/ovu_key ploi@64.176.173.105

# בדוק Nginx
sudo systemctl status nginx

# בדוק logs
sudo tail -f /var/log/nginx/error.log

# אתחל Nginx
sudo systemctl reload nginx
```

### Database לא מגיב
```bash
# התחבר לשרת Database
ssh -i ~/.ssh/ovu_key ploi@64.177.67.215

# בדוק PostgreSQL
sudo systemctl status postgresql

# בדוק אם הDB פעיל
sudo -u postgres psql -c '\l'

# התחבר ל-DB
sudo -u postgres psql -d ulm_db
```

### SSL Issues
```
1. בדוק Cloudflare SSL Mode = "Full (Strict)"
2. ודא ש-DNS records ב-Proxied mode (🟠)
3. נקה cache ב-Cloudflare
4. המתן 5-10 דקות לpropagation
```

### לא זוכר סיסמה
```
כל הסיסמאות מתועדות בקובץ זה.
חפש בקובץ את השרת/שירות הספציפי.
```

---

## 📞 איך לעבוד עם AI Agents

כשאתה עובד עם AI agent חדש, תן לו:

1. **קובץ README זה** - כל המידע הנחוץ
2. **הקשר:** "אני עובד על מערכת OVU - קרא את OVU_SYSTEM_README.md"
3. **המטרה הספציפית:** מה אתה רוצה לעשות
4. **פרטי גישה:** SSH keys נמצאים ב-~/.ssh/ovu_key

**דוגמה:**
```
"אני עובד על מערכת OVU. קרא את OVU_SYSTEM_README.md.
אני רוצה לחבר את React Frontend ל-Backend API.
ה-Frontend נמצא בשרת 64.176.173.105 והBackend בשרת 64.176.171.223."
```

---

## 📝 הערות חשובות

1. **כל השרתים מנוהלים דרך PLOI.io** - זה מקל על ניהול
2. **Cloudflare מנהל DNS + SSL** - אוטומטי
3. **הקוד נמצא בשרתים בלבד** - אין גיבוי!
4. **Frontend עדיין לא מחובר לBackend** - זה הצעד הבא
5. **העיצוב מושלם אבל הפונקציונליות חסרה** - UI ready, backend ready, אבל לא מחוברים

---

## 📅 תאריך עדכון אחרון
**4 באוקטובר 2025**

---

**🎉 המערכת מוכנה ל-production מבחינת infrastructure!**
**🚧 נותר רק לחבר את Frontend ל-Backend ואז הכל יעבוד!**


