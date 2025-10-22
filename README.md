# 🏢 OVU Management System - Monorepo

מערכת ניהול OVU משולבת - Multi-service Architecture עם תמיכה מלאה ב-RTL ו-3 שפות.

## 📦 מבנה הפרויקט

```
ovu-system/
├── services/
│   ├── ulm/          # User Login Manager (FastAPI + Flutter)
│   └── aam/          # Admin Area Manager (FastAPI)
├── shared/           # Shared Resources (UI + Localization)
├── infrastructure/   # Docker, PLOI, Infrastructure
└── docs/            # Documentation
```

## 🚀 GitHub Repositories

הפרויקט מסונכרן עם 5 repositories נפרדים ב-GitHub:

- **ovu-ulm** - https://github.com/noambroner/ovu-ulm
- **ovu-aam** - https://github.com/noambroner/ovu-aam
- **ovu-shared** - https://github.com/noambroner/ovu-shared
- **ovu-deployment** - https://github.com/noambroner/ovu-deployment
- **ovu-docs** - https://github.com/noambroner/ovu-docs

## 🔄 סנכרון

### משיכת שינויים מ-GitHub:
```bash
./scripts/sync-from-github.sh
```

### דחיפת שינויים ל-GitHub:
```bash
./scripts/sync-to-github.sh
```

### סנכרון אוטומטי מלא:
```bash
./scripts/sync.sh auto
```

## 🌍 תמיכה רב-לשונית

- 🇮🇱 עברית (RTL)
- 🇬🇧 English (LTR)
- 🇵🇸 العربية (RTL)

## 🏗️ Development

### התקנה מקומית:
```bash
# Clone monorepo
git clone <monorepo-url> ovu-system
cd ovu-system

# התקן dependencies
make install

# הרצת Docker
make up
```

### Deployment:
```bash
# PLOI.IO Ready
# כל שירות deployed בנפרד מה-repository שלו
```

## 📚 Documentation

ראה תיקיית `docs/` למידע מפורט.

---

**Created with ❤️ by Noam Broner**


