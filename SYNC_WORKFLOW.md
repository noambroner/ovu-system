# 🔄 OVU System - Sync Workflow Guide

## 📋 סקירה כללית

המערכת עובדת בשיטת **Hybrid: Monorepo + Multi-repo**:
- **פיתוח מקומי**: Monorepo אחד עם כל השירותים
- **GitHub**: 5 repositories נפרדים לכל שירות
- **סנכרון**: סקריפטים אוטומטיים שמבטיחים אחידות

## 🏗️ מבנה המערכת

```
/home/noam/projects/dev/
├── ovu-system/            # 🏠 Monorepo (מקומי - Single Source of Truth)
│   ├── services/
│   │   ├── ulm/          # User Login Manager
│   │   └── aam/          # Admin Area Manager
│   ├── shared/           # Shared Resources
│   ├── infrastructure/   # Docker, PLOI configs
│   ├── docs/            # Documentation
│   └── scripts/         # ✨ סקריפטי סנכרון
│
├── ovu-ulm/              # 📦 GitHub sync dir
├── ovu-aam/              # 📦 GitHub sync dir
├── ovu-shared/           # 📦 GitHub sync dir
├── ovu-deployment/       # 📦 GitHub sync dir
└── ovu-docs/             # 📦 GitHub sync dir
```

## ⚡ סקריפטי סנכרון

### 1️⃣ משיכת שינויים מ-GitHub
```bash
cd /home/noam/projects/dev/ovu-system
./scripts/sync.sh pull
```

**מה זה עושה:**
- מושך עדכונים מכל 5 repositories
- מעדכן את הMonorepo המקומי

**מתי להשתמש:**
- בתחילת יום עבודה
- לפני התחלת feature חדש
- אחרי push ממחשב אחר

---

### 2️⃣ דחיפת שינויים ל-GitHub
```bash
cd /home/noam/projects/dev/ovu-system
./scripts/sync.sh push "הודעת commit שלך"
```

**מה זה עושה:**
- מעתיק שינויים מהMonorepo לכל repository נפרד
- עושה commit ו-push לכל אחד

**מתי להשתמש:**
- אחרי סיום feature
- בסוף יום עבודה
- לפני מעבר למחשב אחר

---

### 3️⃣ סנכרון אוטומטי מלא
```bash
cd /home/noam/projects/dev/ovu-system
./scripts/sync.sh auto
```

**מה זה עושה:**
1. Pull מכל repositories
2. Push שינויים מקומיים
3. מבטיח שהכל מסונכרן

**מתי להשתמש:**
- לפני תחילת עבודה במחשב אחר
- כשרוצה להבטיח סנכרון מלא

---

### 4️⃣ בדיקת סטטוס
```bash
cd /home/noam/projects/dev/ovu-system
./scripts/sync.sh status
```

**מה זה מציג:**
- סטטוס Git של כל repository
- האם יש שינויים לא שמורים
- commits ahead/behind

---

## 🔄 Workflow יומי מומלץ

### בוקר (תחילת עבודה):
```bash
cd /home/noam/projects/dev/ovu-system
./scripts/sync.sh pull
```

### במהלך היום:
- עבוד בתוך `/home/noam/projects/dev/ovu-system/`
- כל השינויים נשמרים במקום אחד

### סוף יום (או לפני push):
```bash
cd /home/noam/projects/dev/ovu-system
./scripts/sync.sh push "סיכום העבודה של היום"
```

---

## 🚀 תרחישים נפוצים

### תרחיש 1: עבודה על ULM בלבד
```bash
# עבוד ב:
cd /home/noam/projects/dev/ovu-system/services/ulm/

# בסוף:
cd /home/noam/projects/dev/ovu-system
./scripts/sync.sh push "Updated ULM authentication"
```

### תרחיש 2: שינויים ב-Shared Components
```bash
# עבוד ב:
cd /home/noam/projects/dev/ovu-system/shared/

# בסוף - יתעדכן גם ב-ovu-shared:
./scripts/sync.sh push "Added new React components"
```

### תרחיש 3: מעבר בין מחשבים
**במחשב בעבודה:**
```bash
cd /home/noam/projects/dev/ovu-system
./scripts/sync.sh push "Work from office"
```

**במחשב בבית:**
```bash
cd /home/noam/projects/dev/ovu-system
./scripts/sync.sh pull
```

---

## ⚠️ חשוב לדעת

### ✅ יתרונות הגישה
1. **Single Source of Truth** - הMonorepo הוא המקור היחיד
2. **קל לפתח** - הכל במקום אחד, קל לעבור בין שירותים
3. **CI/CD נפרד** - כל repo ב-GitHub עצמאי
4. **אין פערים** - הסקריפטים מבטיחים סנכרון

### ⚠️ כללי זהב
1. **תמיד pull לפני push**
2. **עבוד רק בMonorepo** (`/home/noam/projects/dev/ovu-system/`)
3. **אל תעבוד ישירות ב-repositories הנפרדים** (ovu-ulm, ovu-aam וכו')
4. **sync בסוף כל יום עבודה**

### 🔴 מה לא לעשות
- ❌ לא לעבוד ישירות ב-`ovu-ulm/`, `ovu-aam/` וכו'
- ❌ לא לעשות commit ישירות ב-repositories הנפרדים
- ❌ לא לשכוח לעשות sync לפני מעבר למחשב אחר

---

## 🆘 פתרון בעיות

### בעיה: "יש שינויים לא שמורים"
```bash
cd /home/noam/projects/dev/ovu-system
git status
git add .
git commit -m "Save local changes"
```

### בעיה: "Merge conflicts"
```bash
# 1. בדוק איפה הקונפליקט:
cd /home/noam/projects/dev/ovu-ulm
git status

# 2. פתור את הקונפליקט ידנית
# 3. commit ו-push
git add .
git commit -m "Resolved conflict"
git push

# 4. sync חזרה לMonorepo:
cd /home/noam/projects/dev/ovu-system
./scripts/sync.sh pull
```

### בעיה: "Repository לא מעודכן"
```bash
# Force pull:
cd /home/noam/projects/dev/ovu-ulm
git fetch origin
git reset --hard origin/main

# sync:
cd /home/noam/projects/dev/ovu-system
./scripts/sync.sh pull
```

---

## 📊 מבנה ה-Repositories ב-GitHub

| Repository | תיקייה במונורפו | תיאור |
|-----------|----------------|--------|
| `ovu-ulm` | `services/ulm/` | User Login Manager |
| `ovu-aam` | `services/aam/` | Admin Area Manager |
| `ovu-shared` | `shared/` | Shared Resources |
| `ovu-deployment` | `infrastructure/` | Docker & PLOI configs |
| `ovu-docs` | `docs/` | Documentation |

---

## 🎯 Best Practices

1. **Commit Messages:**
   ```bash
   # טוב:
   ./scripts/sync.sh push "Added user authentication endpoint in ULM"
   
   # לא טוב:
   ./scripts/sync.sh push "update"
   ```

2. **תדירות Sync:**
   - Pull: לפחות פעם ביום
   - Push: אחרי כל feature גדול

3. **ניהול Branches:**
   - עבוד על `main` בMonorepo
   - אם צריך feature branch - צור אותו ב-GitHub repositories

---

## 🔐 Security

- קבצי `.env` **לא** מסונכרנים (ב-`.gitignore`)
- Secrets נמצאים ב-GitHub Secrets בכל repo
- Database backups לא מעלים ל-GitHub

---

## 📚 מידע נוסף

- **אסטרטגיה מלאה:** `docs/GITHUB_STRATEGY.md`
- **Deployment:** `infrastructure/PLOI_DEPLOYMENT_CHECKLIST.md`
- **תיעוד API:** `docs/ovu-system/`

---

**נוצר ב-❤️ עבור OVU System**
**תאריך עדכון אחרון:** 21 אוקטובר 2025


