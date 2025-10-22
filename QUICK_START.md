# 🚀 OVU System - Quick Start Guide

## ⚡ התחלה מהירה

### 📍 איפה אני עובד?

**תמיד עבוד כאן:**
```bash
cd /home/noam/projects/dev/ovu-system/
```

זה ה-**Monorepo** - Single Source of Truth שלך!

---

## 🎯 פקודות מרכזיות

### 1. בדיקת סטטוס
```bash
./scripts/sync.sh status
```

### 2. משיכת עדכונים מ-GitHub
```bash
./scripts/sync.sh pull
```

### 3. דחיפת שינויים ל-GitHub
```bash
./scripts/sync.sh push "הודעת commit"
```

### 4. סנכרון מלא
```bash
./scripts/sync.sh auto
```

---

## 🗂️ מבנה המערכת

```
ovu-system/
├── services/
│   ├── ulm/          ← עובד כאן ל-ULM
│   └── aam/          ← עובד כאן ל-AAM
├── shared/           ← רכיבים משותפים
├── infrastructure/   ← Docker, PLOI
├── docs/            ← תיעוד
└── scripts/         ← סקריפטי סנכרון
```

---

## 🔄 Workflow יומי

### בוקר:
```bash
cd /home/noam/projects/dev/ovu-system
./scripts/sync.sh pull
```

### עבודה:
- עבוד בתוך `ovu-system/`
- שנה קבצים כרגיל
- הכל נשמר מקומית

### ערב:
```bash
cd /home/noam/projects/dev/ovu-system
./scripts/sync.sh push "סיכום העבודה"
```

---

## 🌐 GitHub Repositories

כל השינויים מסונכרנים אוטומטית ל:
- https://github.com/noambroner/ovu-ulm
- https://github.com/noambroner/ovu-aam
- https://github.com/noambroner/ovu-shared
- https://github.com/noambroner/ovu-deployment
- https://github.com/noambroner/ovu-docs

---

## ⚠️ חשוב!

✅ **לעשות:**
- עבוד רק ב-`ovu-system/`
- sync לפני כל עבודה
- sync אחרי כל שינוי גדול

❌ **לא לעשות:**
- לא לעבוד ב-`ovu-ulm/`, `ovu-aam/` וכו'
- לא לשכוח לעשות sync

---

## 📚 מדריכים מפורטים

- **Workflow מלא:** [SYNC_WORKFLOW.md](SYNC_WORKFLOW.md)
- **README:** [README.md](README.md)
- **תיעוד מערכת:** [docs/](docs/)

---

**זהו! פשוט כמו שצריך 🎉**


