# 📚 OVU System Documentation Index
**Last Updated:** October 5, 2025, 19:35 UTC

---

## 🎯 מדריך תיעוד מהיר

### להתחלה מהירה:
1. קרא את [FINAL_AUDIT_SUMMARY.md](./FINAL_AUDIT_SUMMARY.md) - סיכום מצב המערכת
2. עבור ל-[QUICKSTART.md](./QUICKSTART.md) - פעולות יומיומיות
3. במידת הצורך, צלול ל-[OVU_SYSTEM_README.md](./OVU_SYSTEM_README.md) - מידע מפורט

---

## 📋 כל קבצי התיעוד

### 🎯 מסמכי ליבה (התחל כאן)

| קובץ | תיאור | גודל | מתי להשתמש |
|------|--------|------|------------|
| [FINAL_AUDIT_SUMMARY.md](./FINAL_AUDIT_SUMMARY.md) | סיכום ביקורת מלא | 11KB | **קרא קודם!** סקירה מהירה של כל המערכת |
| [QUICKSTART.md](./QUICKSTART.md) | מדריך התחלה מהירה | 5KB | פעולות יומיומיות, פקודות נפוצות |
| [README.md](./README.md) | README ראשי | 5KB | מבוא כללי לפרויקט |

### 🏗️ תיעוד ארכיטקטורה

| קובץ | תיאור | גודל | תוכן |
|------|--------|------|------|
| [ARCHITECTURE_AUDIT_REPORT.md](./ARCHITECTURE_AUDIT_REPORT.md) | דוח ביקורת מקיף | 17KB | סקירה מלאה של כל שרת, בדיקות, ממצאים |
| [OVU_SYSTEM_README.md](./OVU_SYSTEM_README.md) | תיעוד מערכת מפורט | 18KB | פרטי גישה, URLs, database schemas, troubleshooting |
| [OVU_README.md](./OVU_README.md) | מדריך מפתח מקיף | 21KB | כל המידע הטכני, API docs, feature list |

### 📜 תיעוד התפתחות

| קובץ | תיאור | גודל | תוכן |
|------|--------|------|------|
| [DEVELOPMENT_LOG.md](./DEVELOPMENT_LOG.md) | לוג התפתחות מלא | 20KB | Timeline, decisions, deployments, lessons learned |
| [USER_STATUS_UPDATE_SUMMARY.md](./USER_STATUS_UPDATE_SUMMARY.md) | עדכון מערכת סטטוס | 9KB | תיעוד Feature: User Status Management (Oct 5) |
| [GITHUB_SYNC_COMPLETE.md](./GITHUB_SYNC_COMPLETE.md) | דוח סנכרון GitHub | 5KB | Multi-repo sync report |

### 🚀 deployment & Setup

| קובץ | תיאור | תוכן |
|------|--------|------|
| [OVU_DEPLOYMENT_CHECKLIST.md](./OVU_DEPLOYMENT_CHECKLIST.md) | checklist פריסה | צעדי deployment מלאים |
| [ploi-setup-frontend.sh](./ploi-setup-frontend.sh) | סקריפט Frontend | התקנה אוטומטית Frontend |
| [ploi-setup-backend.sh](./ploi-setup-backend.sh) | סקריפט Backend | התקנה אוטומטית Backend |
| [ploi-database-setup.sql](./ploi-database-setup.sql) | SQL Setup | יצירת databases וטבלאות |
| [ploi-nginx-configs.md](./ploi-nginx-configs.md) | Nginx Configs | קונפיגורציות Nginx |
| [ploi-supervisor-config.md](./ploi-supervisor-config.md) | Supervisor Configs | ניהול תהליכים |

---

## 🗂️ תיעוד לפי נושא

### אם אתה רוצה...

#### 🔍 להבין את המערכת
1. [FINAL_AUDIT_SUMMARY.md](./FINAL_AUDIT_SUMMARY.md) - סקירה כללית
2. [ARCHITECTURE_AUDIT_REPORT.md](./ARCHITECTURE_AUDIT_REPORT.md) - פירוט טכני
3. [DEVELOPMENT_LOG.md](./DEVELOPMENT_LOG.md) - איך הגענו לכאן

#### 🚀 לעשות Deployment
1. [OVU_DEPLOYMENT_CHECKLIST.md](./OVU_DEPLOYMENT_CHECKLIST.md) - checklist
2. [ploi-setup-*.sh](./ploi-setup-frontend.sh) - סקריפטים
3. [OVU_SYSTEM_README.md](./OVU_SYSTEM_README.md) - פרטי גישה

#### 🔧 לתקן בעיות
1. [OVU_SYSTEM_README.md](./OVU_SYSTEM_README.md#פתרון-בעיות) - מדריך troubleshooting
2. [QUICKSTART.md](./QUICKSTART.md) - פקודות שימושיות
3. [ARCHITECTURE_AUDIT_REPORT.md](./ARCHITECTURE_AUDIT_REPORT.md) - הבנת המבנה

#### 💻 לפתח תכונות
1. [OVU_README.md](./OVU_README.md) - API documentation
2. [DEVELOPMENT_LOG.md](./DEVELOPMENT_LOG.md) - best practices
3. [USER_STATUS_UPDATE_SUMMARY.md](./USER_STATUS_UPDATE_SUMMARY.md) - דוגמה לfeature

#### 🗄️ לעבוד עם Database
1. [ploi-database-setup.sql](./ploi-database-setup.sql) - schema
2. [OVU_SYSTEM_README.md](./OVU_SYSTEM_README.md#מסד-נתונים) - פרטים
3. [ARCHITECTURE_AUDIT_REPORT.md](./ARCHITECTURE_AUDIT_REPORT.md) - מבנה טבלאות

---

## 📊 מידע מהיר

### פרטי חיבור
```bash
# Frontend Server
ssh -i ~/.ssh/ovu_key ploi@64.176.173.105

# Backend Server
ssh -i ~/.ssh/ovu_key ploi@64.176.171.223

# Database Server
ssh -i ~/.ssh/ovu_key ploi@64.177.67.215

# Database
PGPASSWORD='Ovu123456!!@@##' psql -h 64.177.67.215 -U ovu_user -d ulm_db
```

### URLs פרודקשן
```
Main:    https://ovu.co.il
ULM:     https://ulm-rct.ovu.co.il
AAM:     https://aam-rct.ovu.co.il
ULM API: http://64.176.171.223:8001/api/v1/docs
AAM API: http://64.176.171.223:8002/health
```

### Git Repositories
```bash
git clone https://github.com/noambroner/ovu-ulm.git
git clone https://github.com/noambroner/ovu-aam.git
git clone https://github.com/noambroner/ovu-shared.git
git clone https://github.com/noambroner/ovu-docs.git
```

---

## 🔄 עדכונים אחרונים

### October 5, 2025
- ✅ ביקורת מלאה של המערכת
- ✅ תיעוד ארכיטקטורה מקיף
- ✅ לוג התפתחות מלא
- ✅ תיקון סתירות בתיעוד
- ✅ הבהרת מבנה שרתים

### October 4, 2025
- ✅ AAM Production Deployment
- ✅ כל 5 האתרים חיים

### October 3-5, 2025
- ✅ User Status Management System
- ✅ Scheduled Deactivations
- ✅ Activity History
- ✅ APScheduler Integration

---

## 📱 קבל עזרה

### לשאלות טכניות:
1. חפש ב-[OVU_SYSTEM_README.md](./OVU_SYSTEM_README.md) - יש מדריך troubleshooting
2. עיין ב-[DEVELOPMENT_LOG.md](./DEVELOPMENT_LOG.md) - lessons learned
3. בדוק [ARCHITECTURE_AUDIT_REPORT.md](./ARCHITECTURE_AUDIT_REPORT.md) - ממצאים

### ליצור קשר:
**Developer:** Noam Broner
**Email:** noam@datapc.co.il
**GitHub:** [@noambroner](https://github.com/noambroner)

---

## 🎯 מעקב אחר שינויים

כל עדכון משמעותי במערכת צריך להיות מתועד ב:
1. [DEVELOPMENT_LOG.md](./DEVELOPMENT_LOG.md) - עדכון timeline
2. [Git Commits](https://github.com/noambroner) - commit messages
3. קובץ README המתאים - עדכון תיעוד טכני

---

**נוצר:** October 5, 2025
**גרסה:** 1.0
**סטטוס:** ✅ Complete & Up-to-date








