# 🚀 OVU Management System

<div align="center">
  <h3>מערכת ניהול מתקדמת לצוותי פיתוח</h3>
  <p>ארכיטקטורת מיקרו-שירותים | Python Backend | Flutter Frontend</p>
  
  [![GitHub](https://img.shields.io/github/license/YOUR_USERNAME/ovu-system)](LICENSE)
  [![Python](https://img.shields.io/badge/Python-3.11+-blue)](https://www.python.org)
  [![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-green)](https://fastapi.tiangolo.com)
  [![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue)](https://flutter.dev)
  [![Docker](https://img.shields.io/badge/Docker-Ready-blue)](https://www.docker.com)
  [![PLOI](https://img.shields.io/badge/PLOI-Ready-purple)](https://ploi.io)
</div>

---

## 📋 סקירה כללית

OVU Management System היא פלטפורמה מודולרית לניהול צוותי פיתוח, תמיכה ואפיון. המערכת בנויה בארכיטקטורת מיקרו-שירותים המאפשרת סקלביליות, גמישות ותחזוקה קלה.

## 🏗️ ארכיטקטורה

```
┌─────────────────────────────────────────┐
│              NGINX Gateway              │
└─────────┬───────────────────┬───────────┘
          │                   │
     ┌────▼────┐         ┌───▼────┐
     │   ULM   │         │  AAM   │
     │ Service │         │Service │
     └────┬────┘         └───┬────┘
          │                   │
     ┌────▼───────────────────▼────┐
     │      PostgreSQL + Redis      │
     └──────────────────────────────┘
```

## 🔧 טכנולוגיות

### Backend
- **Python 3.11** + **FastAPI** - Framework מהיר ומודרני
- **PostgreSQL** - מסד נתונים ראשי
- **Redis** - Cache ו-Session Management
- **SQLAlchemy** - ORM
- **Alembic** - Database Migrations
- **JWT** - Authentication

### Frontend
- **Flutter** - Cross-platform UI (Web, Mobile, Desktop)
- **React** - Web Admin Interface (עתידי)
- **Shared UI Components** - ספריית רכיבים משותפת

### Infrastructure
- **Docker** + **Docker Compose** - Containerization
- **NGINX** - Reverse Proxy & Load Balancer
- **RabbitMQ** - Message Queue
- **Git** - Version Control

## 📦 שירותים

### 🔐 ULM - User Login Manager
ניהול משתמשים, אימות והרשאות
- רישום והתחברות
- ניהול פרופילים
- מערכת הרשאות RBAC
- Multi-Factor Authentication
- API Keys Management

### 🎛️ AAM - Admin Area Manager
פאנל ניהול מרכזי
- Dashboard מרכזי
- ניהול משתמשים
- הגדרות מערכת
- מוניטורינג ולוגים
- Analytics ודוחות

## 🚀 Quick Start

### Clone & Run:
```bash
# Clone
git clone https://github.com/YOUR_USERNAME/ovu-system.git
cd ovu-system

# Run with Docker
docker-compose up

# Or with Make
make dev
```

Services:
- 🌐 Frontend: http://localhost:3001
- 🔧 ULM API: http://localhost:8001/docs
- 🔧 AAM API: http://localhost:8002/docs
- 📊 Database: localhost:5432

## 🚀 התחלה מהירה

### דרישות מקדימות
- Docker & Docker Compose
- Python 3.11+
- Flutter SDK 3.0+
- Git
- Make (אופציונלי)

### התקנה

1. **Clone the repository:**
```bash
git clone https://github.com/your-org/ovu-system.git
cd ovu-system
```

2. **הגדר Environment Variables:**
```bash
cp .env.example .env
# ערוך את .env עם הערכים שלך
```

3. **הרץ עם Docker Compose:**
```bash
# עם Make
make dev

# או ישירות עם Docker Compose
docker-compose up -d
```

4. **גש למערכת:**
- Main Portal: http://localhost
- ULM Service: http://ulm.localhost
- AAM Service: http://aam.localhost
- Database Admin: http://localhost:8080
- RabbitMQ Admin: http://localhost:15672
- Mail Testing: http://localhost:8025

## 💻 פיתוח

### מבנה הפרויקט
```
ovu-system/
├── services/              # מיקרו-שירותים
│   ├── ulm/              # User Login Manager
│   └── aam/              # Admin Area Manager
├── shared/               # משאבים משותפים
│   ├── interface-resources/  # UI Components
│   └── api-contracts/    # API Schemas
├── infrastructure/       # תשתית
│   └── docker/          # Docker configs
├── docs/                # תיעוד
└── tools/              # כלי פיתוח
```

### פקודות שימושיות

```bash
# בניית השירותים
make build

# הרצת השירותים
make up

# צפייה בלוגים
make logs

# כניסה ל-shell של שירות
make ulm-shell
make aam-shell

# הרצת בדיקות
make test

# ניקוי
make clean
```

### עבודה בין מחשבים

1. **במחשב הראשון - Push changes:**
```bash
git add .
git commit -m "תיאור השינויים"
git push origin main
```

2. **במחשב השני - Pull changes:**
```bash
git pull origin main
docker-compose down
docker-compose build
docker-compose up -d
```

### סקריפט סנכרון אוטומטי
השתמש ב-`sync.sh` לסנכרון מהיר:
```bash
./scripts/sync.sh pull  # למשוך שינויים
./scripts/sync.sh push  # לדחוף שינויים
```

## 🧪 בדיקות

```bash
# כל הבדיקות
make test

# בדיקות ספציפיות
make test-ulm
make test-aam

# Coverage Report
docker-compose exec ulm_backend pytest --cov=app tests/
```

## 📊 ניטור ולוגים

### Logs
```bash
# כל הלוגים
docker-compose logs -f

# לוגים של שירות ספציפי
docker-compose logs -f ulm_backend
```

### Health Checks
- ULM: http://ulm.localhost/health
- AAM: http://aam.localhost/health

## 🔒 אבטחה

- JWT Authentication עם refresh tokens
- RBAC - Role-Based Access Control
- Rate Limiting על endpoints רגישים
- Password Policy חזקה
- MFA/2FA Support
- API Keys לגישה programmatic
- HTTPS בפרודקשן

## 📝 רישיון

Proprietary - All rights reserved

## 👥 צוות

- **Noam** - Lead Developer

## 🤝 תרומה

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📞 תמיכה

לשאלות ותמיכה:
- Email: support@ovu.co.il
- Documentation: [docs.ovu.co.il](https://docs.ovu.co.il)

---

<div align="center">
  Made with ❤️ by OVU Team
</div>
