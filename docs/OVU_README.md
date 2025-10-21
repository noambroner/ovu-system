# OVU System - מערכת ניהול משתמשים ומנהלים

## 📋 תוכן עניינים
- [סקירה כללית](#סקירה-כללית)
- [ארכיטקטורה](#ארכיטקטורה)
- [נתוני גישה](#נתוני-גישה)
- [פיצ'רים](#פיצרים)
- [מבנה מסד נתונים](#מבנה-מסד-נתונים)
- [התקנה ופריסה](#התקנה-ופריסה)
- [API Documentation](#api-documentation)
- [פתרון בעיות](#פתרון-בעיות)

---

## 🎯 סקירה כללית

**OVU** היא מערכת multi-repository לניהול משתמשים ומנהלים עם תמיכה מלאה ב-RTL, 3 שפות (עברית, אנגלית, ערבית), ו-light/dark mode.

### 📦 Repositories:
1. **ovu-ulm** (User Login Manager) - ניהול משתמשים ואימות
2. **ovu-aam** (Admin Area Manager) - אזור ניהול מנהלים
3. **ovu-shared** (Shared Resources) - קומפוננטים משותפים
4. **ovu-deployment** (Deployment configs) - תצורות פריסה

---

## 🏗️ ארכיטקטורה

### Frontend Applications:
- **Main Portal:** https://ovu.co.il
- **ULM React:** https://ulm-rct.ovu.co.il
- **ULM Flutter:** https://ulm-flt.ovu.co.il
- **AAM React:** https://aam-rct.ovu.co.il
- **AAM Flutter:** https://aam-flt.ovu.co.il

### Backend Services:
- **ULM Backend:** 64.176.171.223:8001 (FastAPI)
- **AAM Backend:** 64.176.171.223:8002 (FastAPI)

### Database:
- **PostgreSQL:** 64.177.67.215:5432
- **Database Name:** ulm_db

### Infrastructure:
- **Frontend Server:** 64.176.173.105
- **Backend Server:** 64.176.171.223
- **Database Server:** 64.177.67.215

---

## 🔐 נתוני גישה

### Frontend Server (64.176.173.105)
```
User: ploi
Sudo Password: 43ACBUHlZWOxwAueKji8
SSH Key: ~/.ssh/ovu_key
```

### Backend Server (64.176.171.223)
```
User: ploi
Sudo Password: 43ACBUHlZWOxwAueKji8
SSH Key: ~/.ssh/ovu_key
```

### Database Server (64.177.67.215)
```
User: ploi
Sudo Password: 0BweAsz8ptKfsYuBt5Dy
SSH Key: ~/.ssh/ovu_key

PostgreSQL:
  Superuser: postgres
  App User: ovu_user
  Password: Ovu123456!!@@##
  Databases: ulm_db (8 tables), aam_db (4 tables)
  Port: 5432
```

### Application Credentials

#### Default Admin User:
```
Username: admin
Email: noam@datapc.co.il
Password: [set by user]
Role: admin
```

#### Default Test User:
```
Username: testuser
Email: test@ovu.co.il
Password: [set by user]
Role: user
```

### Cloudflare:
- DNS management for ovu.co.il
- SSL certificates
- CDN caching

### GitHub:
```
Username: noambroner
Repositories:
  - github.com/noambroner/ovu-ulm
  - github.com/noambroner/ovu-aam
  - github.com/noambroner/ovu-shared
  - github.com/noambroner/ovu-deployment
```

---

## ✨ פיצ'רים

### 🔐 Authentication & Authorization
- [x] Login with JWT tokens
- [x] Session management (database + JWT)
- [x] Role-based access control (user, admin, super_admin)
- [x] Password hashing with bcrypt
- [x] Automatic session cleanup (30 days)
- [x] "Remember me" functionality

### 👥 User Management
- [x] Full CRUD operations
- [x] User search (global + per-column filtering)
- [x] User sorting (all columns)
- [x] Real-time field updates with animations
- [x] User roles management
- [x] Password reset (admin only)
- [x] Created by tracking
- [x] Phone number support
- [x] Email validation
- [x] Username uniqueness check

### 📊 Users Table Features
- [x] Advanced filtering per column
- [x] Smart search with auto-close
- [x] Multiple filters simultaneously
- [x] Clear all filters button
- [x] Sortable columns
- [x] Animated row highlighting
- [x] Field-level update animations
- [x] Compact header design
- [x] Light/Dark theme support
- [x] RTL/LTR support

### Columns:
1. **Actions (⋮)** - Edit, Reset Password
2. **מזהה (ID)** - User ID
3. **שם משתמש (Username)** - With search
4. **אימייל (Email)** - With search
5. **טלפון (Phone)** - Optional field
6. **תפקיד (Role)** - user/admin/super_admin
7. **נוצר ע"י (Created By)** - Username of creator
8. **תאריך יצירה (Created)** - Timestamp

### 🎨 UI/UX Features
- [x] Responsive design (mobile, tablet, desktop)
- [x] RTL full support (Hebrew, Arabic)
- [x] LTR support (English)
- [x] Light/Dark mode toggle
- [x] Language selector (he/en/ar)
- [x] Modern 2025 design
- [x] Smooth animations
- [x] Custom scrollbars
- [x] Toast notifications
- [x] Modal dialogs
- [x] Loading states
- [x] Error handling

### 📱 Components

#### Shared Components (`/home/ploi/shared-components/`):
- **LoginPage** - Unified login with show/hide password
- **Dashboard** - Statistics and activity display
- **Sidebar** - Navigation with current location
- **UsersTable** - Advanced table with filters
- **EditUserModal** - Edit user details
- **ResetPasswordModal** - Admin password reset
- **AddUserModal** - Create new users
- **Layout** - Page structure wrapper

### 🎯 Dashboard Features
- [x] User statistics
- [x] Recent activity
- [x] Role distribution
- [x] Session info
- [x] Quick actions
- [x] Responsive cards

### 🧭 Navigation Features
- [x] Sidebar navigation
- [x] Current page highlighting
- [x] Sub-pages support
- [x] Breadcrumbs
- [x] Fixed size (no reflow)
- [x] Collapse/Expand

---

## 💾 מבנה מסד נתונים

### Table: `users`

```sql
CREATE TABLE users (
    id                  SERIAL PRIMARY KEY,
    username            VARCHAR(100) UNIQUE NOT NULL,
    email               VARCHAR(255) UNIQUE NOT NULL,
    hashed_password     VARCHAR(255) NOT NULL,
    first_name          VARCHAR(100),
    last_name           VARCHAR(100),
    phone               VARCHAR(20),                      -- ✨ NEW
    role                VARCHAR(20) DEFAULT 'user',
    preferred_language  VARCHAR(10) DEFAULT 'he',
    is_active           BOOLEAN DEFAULT true,
    is_verified         BOOLEAN DEFAULT false,
    created_by_id       INTEGER,                          -- ✨ NEW
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_users_created_by 
        FOREIGN KEY (created_by_id) 
        REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_created_by ON users(created_by_id);
```

### Table: `sessions`

```sql
CREATE TABLE sessions (
    id              SERIAL PRIMARY KEY,
    user_id         INTEGER NOT NULL,
    session_token   VARCHAR(500) UNIQUE NOT NULL,
    expires_at      TIMESTAMP NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address      VARCHAR(45),
    user_agent      TEXT,
    
    CONSTRAINT sessions_user_id_fkey 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_token ON sessions(session_token);
CREATE INDEX idx_sessions_expires ON sessions(expires_at);
```

### Table: `user_sessions`

```sql
CREATE TABLE user_sessions (
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER NOT NULL,
    token       VARCHAR(500) NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at  TIMESTAMP NOT NULL,
    
    CONSTRAINT user_sessions_user_id_fkey 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE
);
```

### Table: `password_resets`

```sql
CREATE TABLE password_resets (
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER NOT NULL,
    token       VARCHAR(255) UNIQUE NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at  TIMESTAMP NOT NULL,
    used        BOOLEAN DEFAULT false,
    
    CONSTRAINT password_resets_user_id_fkey 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE
);
```

### Table: `user_roles`

```sql
CREATE TABLE user_roles (
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER NOT NULL,
    role_name   VARCHAR(50) NOT NULL,
    granted_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    granted_by  INTEGER,
    
    CONSTRAINT user_roles_user_id_fkey 
        FOREIGN KEY (user_id) 
        REFERENCES users(id) ON DELETE CASCADE
);
```

---

## 🚀 התקנה ופריסה

### Prerequisites:
- Node.js 18+
- Python 3.11+
- PostgreSQL 14+
- Nginx
- Git

### Frontend Setup:

#### 1. Clone Repositories:
```bash
cd /home/ploi
git clone https://github.com/noambroner/ovu-ulm.git
git clone https://github.com/noambroner/ovu-aam.git
git clone https://github.com/noambroner/ovu-shared.git
```

#### 2. Setup React Apps:
```bash
# ULM React
cd /home/ploi/ulm-react
npm install
npm run build
cp -r dist/* /home/ploi/ulm-rct.ovu.co.il/public/

# AAM React
cd /home/ploi/aam-react
npm install
npm run build
cp -r dist/* /home/ploi/aam-rct.ovu.co.il/public/
```

#### 3. Setup Flutter Apps:
```bash
# ULM Flutter
cd /home/ploi/ulm-flutter
flutter pub get
flutter build web
cp -r build/web/* /home/ploi/ulm-flt.ovu.co.il/public/

# AAM Flutter
cd /home/ploi/aam-flutter
flutter pub get
flutter build web
cp -r build/web/* /home/ploi/aam-flt.ovu.co.il/public/
```

### Backend Setup:

#### 1. Setup ULM Backend:
```bash
cd /home/ploi/ovu-ulm/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create .env file
cat > .env << 'ENV'
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=43200
DATABASE_URL=postgresql+asyncpg://ovu_user:OvuDbUser2025Secure!Pass@64.177.67.215:5432/ulm_db
ENV

# Run backend
nohup uvicorn app.main_simple:app --host 0.0.0.0 --port 8001 > /tmp/ulm_backend.log 2>&1 &
```

#### 2. Setup AAM Backend:
```bash
cd /home/ploi/ovu-aam/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create .env file (same as ULM)

# Run backend
nohup uvicorn app.main_simple:app --host 0.0.0.0 --port 8002 > /tmp/aam_backend.log 2>&1 &
```

### Database Setup:

```bash
# Connect to database server
ssh ploi@64.177.67.215

# Create database and user
sudo -u postgres psql << 'SQL'
CREATE DATABASE ulm_db;
CREATE USER ovu_user WITH PASSWORD 'OvuDbUser2025Secure!Pass';
GRANT ALL PRIVILEGES ON DATABASE ulm_db TO ovu_user;
\c ulm_db
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ovu_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ovu_user;
SQL

# Run migrations
sudo -u postgres psql -d ulm_db -f /path/to/migrations/
```

### Nginx Configuration:

```nginx
# /etc/nginx/sites-available/ulm-rct.ovu.co.il
server {
    listen 443 ssl http2;
    server_name ulm-rct.ovu.co.il;
    
    ssl_certificate /etc/ssl/certs/ovu.co.il.crt;
    ssl_certificate_key /etc/ssl/private/ovu.co.il.key;
    
    root /home/ploi/ulm-rct.ovu.co.il/public;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://64.176.171.223:8001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## 📡 API Documentation

### Base URL:
- ULM: `https://ulm-rct.ovu.co.il/api/v1`
- AAM: `https://aam-rct.ovu.co.il/api/v1`

### Authentication Endpoints:

#### POST `/auth/login`
```json
Request:
{
  "username": "admin",
  "password": "your-password"
}

Response:
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer",
  "user": {
    "id": 2,
    "username": "admin",
    "email": "admin@ovu.co.il",
    "role": "admin"
  }
}
```

#### GET `/auth/me`
```json
Headers:
  Authorization: Bearer <token>

Response:
{
  "id": 2,
  "username": "admin",
  "email": "admin@ovu.co.il",
  "role": "admin",
  "created_at": "2025-10-04T16:36:00"
}
```

#### POST `/auth/logout`
```json
Headers:
  Authorization: Bearer <token>

Response:
{
  "message": "Successfully logged out"
}
```

### User Management Endpoints:

#### GET `/users` (Admin only)
```json
Headers:
  Authorization: Bearer <token>

Query Parameters:
  skip: 0
  limit: 100

Response:
{
  "users": [
    {
      "id": 2,
      "username": "admin",
      "email": "admin@ovu.co.il",
      "role": "admin",
      "phone": "0528903533",
      "created_by_id": null,
      "created_by_username": null,
      "created_at": "2025-10-04T16:36:00"
    }
  ],
  "total": 2,
  "skip": 0,
  "limit": 100
}
```

#### POST `/users` (Admin only)
```json
Headers:
  Authorization: Bearer <token>

Request:
{
  "username": "newuser",
  "email": "newuser@ovu.co.il",
  "password": "securepass123",
  "phone": "0501234567",
  "role": "user"
}

Response:
{
  "id": 3,
  "username": "newuser",
  "email": "newuser@ovu.co.il",
  "phone": "0501234567",
  "role": "user",
  "created_at": "2025-10-05T11:00:00"
}
```

#### PUT `/users/{user_id}` (Admin only)
```json
Headers:
  Authorization: Bearer <token>

Request:
{
  "username": "updateduser",
  "email": "updated@ovu.co.il",
  "phone": "0509876543",
  "role": "admin"
}

Response:
{
  "id": 3,
  "username": "updateduser",
  "email": "updated@ovu.co.il",
  "phone": "0509876543",
  "role": "admin",
  "created_at": "2025-10-05T11:00:00"
}
```

#### PUT `/users/{user_id}/password` (Admin only)
```json
Headers:
  Authorization: Bearer <token>

Request:
{
  "password": "newpassword123"
}

Response:
{
  "message": "Password reset successfully"
}
```

---

## 🛠️ פתרון בעיות

### Backend לא עולה:

```bash
# Check logs
tail -100 /tmp/ulm_backend.log

# Check if port is in use
netstat -tulpn | grep 8001

# Kill existing process
pkill -f "uvicorn.*8001"

# Restart
cd /home/ploi/ovu-ulm/backend
source venv/bin/activate
nohup uvicorn app.main_simple:app --host 0.0.0.0 --port 8001 > /tmp/ulm_backend.log 2>&1 &
```

### Database connection issues:

```bash
# Test connection
PGPASSWORD='OvuDbUser2025Secure!Pass' psql -h 64.177.67.215 -U ovu_user -d ulm_db -c '\dt'

# Check database status
ssh ploi@64.177.67.215 "sudo systemctl status postgresql"
```

### Frontend not loading:

```bash
# Clear browser cache (Ctrl+Shift+R)

# Rebuild frontend
cd /home/ploi/ulm-react
npm run build
rm -rf /home/ploi/ulm-rct.ovu.co.il/public/*
cp -r dist/* /home/ploi/ulm-rct.ovu.co.il/public/

# Check Nginx
sudo nginx -t
sudo systemctl reload nginx
```

### 502 Bad Gateway:

```bash
# Usually means backend is down
# Check backend status
ps aux | grep uvicorn

# Check backend logs
tail -50 /tmp/ulm_backend.log

# Restart backend (see above)
```

### Session issues:

```sql
-- Clean expired sessions
DELETE FROM sessions WHERE expires_at < NOW();

-- Check active sessions
SELECT id, user_id, created_at, expires_at 
FROM sessions 
WHERE expires_at > NOW() 
ORDER BY created_at DESC;
```

---

## 📝 Development Commands

### Quick Deploy ULM:
```bash
ssh -i ~/.ssh/ovu_key ploi@64.176.173.105 "
cd /home/ploi/ulm-react && 
npm run build && 
rm -rf /home/ploi/ulm-rct.ovu.co.il/public/* && 
cp -r dist/* /home/ploi/ulm-rct.ovu.co.il/public/ && 
echo '✓ ULM deployed'
"
```

### Quick Deploy AAM:
```bash
ssh -i ~/.ssh/ovu_key ploi@64.176.173.105 "
cd /home/ploi/aam-react && 
npm run build && 
rm -rf /home/ploi/aam-rct.ovu.co.il/public/* && 
cp -r dist/* /home/ploi/aam-rct.ovu.co.il/public/ && 
echo '✓ AAM deployed'
"
```

### Restart ULM Backend:
```bash
ssh -i ~/.ssh/ovu_key ploi@64.176.171.223 "
pkill -f 'uvicorn.*8001' &&
cd /home/ploi/ovu-ulm/backend && 
source venv/bin/activate && 
nohup uvicorn app.main_simple:app --host 0.0.0.0 --port 8001 > /tmp/ulm_backend.log 2>&1 & 
echo '✓ ULM Backend restarted'
"
```

### Database Backup:
```bash
ssh -i ~/.ssh/ovu_key ploi@64.177.67.215 "
PGPASSWORD='OvuDbUser2025Secure!Pass' pg_dump -h localhost -U ovu_user ulm_db > /home/ploi/backups/ulm_db_\$(date +%Y%m%d_%H%M%S).sql
"
```

---

## 🔄 Recent Updates (Session 75+)

### Session 75 (Oct 4, 2025):
- ✅ Fixed AAM production deployment
- ✅ Restored Nginx configs
- ✅ All 3 AAM services working (base, main, roleinstaller)
- ✅ HTTPS/SSL working correctly

### Session 76 (Oct 5, 2025):
- ✅ Added phone field to users table
- ✅ Added created_by_id tracking
- ✅ Implemented AddUserModal
- ✅ Implemented ResetPasswordModal
- ✅ Fixed table column ordering
- ✅ Updated GET /users endpoint
- ✅ Enhanced UsersTable with advanced filtering
- ✅ Improved UI/UX with animations

---

## 📞 Support & Contact

**Developer:** Noam Broner  
**Email:** noam@datapc.co.il  
**GitHub:** @noambroner  

---

## 📄 License

Proprietary - All rights reserved

---

**Last Updated:** October 5, 2025  
**Version:** 2.0
**Status:** Production Ready ✅
