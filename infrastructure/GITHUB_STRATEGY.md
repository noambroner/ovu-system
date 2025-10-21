# 📚 GitHub Strategy for OVU System

## 🤔 מה עדיף - Repository אחד או הרבה?

### 📊 השוואה מהירה:

| קריטריון | Monorepo (אחד) | Multi-repo (הרבה) | המלצה שלי |
|----------|----------------|-------------------|------------|
| **קלות פיתוח** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Monorepo |
| **עצמאות שירותים** | ⭐⭐ | ⭐⭐⭐⭐⭐ | Multi-repo |
| **ניהול הרשאות** | ⭐⭐ | ⭐⭐⭐⭐⭐ | Multi-repo |
| **CI/CD** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Multi-repo |
| **קלות תחזוקה** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Monorepo |
| **Scalability** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Multi-repo |

## 🎯 ההמלצה שלי לך:

### **התחל עם Monorepo** 🏆
**למה?**
- אתה בתחילת הדרך
- קל יותר לפתח ולבדוק
- קל לשתף קוד בין השירותים
- PLOI יודע לעבוד עם monorepo

**מתי לעבור ל-Multi-repo?**
- כשיהיו לך 3+ מפתחים
- כשתרצה CI/CD נפרד לכל שירות
- כשתצטרך הרשאות שונות לכל שירות

---

## 📝 אופציה 1: Monorepo (מומלץ להתחלה)

### מבנה:
```
github.com/YOUR_USERNAME/ovu-system/
├── services/
│   ├── ulm/
│   └── aam/
├── shared/
├── infrastructure/
└── .ploi/
```

### איך להעלות:
```bash
# 1. התקן GitHub CLI (אם אין לך)
# Mac:
brew install gh

# Linux:
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Windows:
winget install --id GitHub.cli

# 2. התחבר ל-GitHub
gh auth login

# 3. הרץ את הסקריפט
chmod +x scripts/github-monorepo.sh
./scripts/github-monorepo.sh
```

### או ידנית:
```bash
# 1. Initialize Git
git init
git add .
git commit -m "Initial commit - OVU Management System"

# 2. Create repo on GitHub (בדפדפן)
# Go to: https://github.com/new

# 3. Push
git remote add origin https://github.com/YOUR_USERNAME/ovu-system.git
git branch -M main
git push -u origin main
```

### הגדרות PLOI:
```yaml
# ב-PLOI Dashboard:
Repository: github.com/YOUR_USERNAME/ovu-system
Branch: main
Deploy Script: .ploi/deploy.sh
```

---

## 📦 אופציה 2: Multi-repo (לפרויקט בוגר)

### מבנה:
```
GitHub Organization: ovu-system/
├── ovu-ulm/          # User Login Manager
├── ovu-aam/          # Admin Area Manager
├── ovu-shared/       # Shared Resources
└── ovu-deployment/   # Orchestration
```

### איך להעלות:
```bash
# 1. עדכן את הסקריפט עם השם שלך
nano scripts/github-split.sh
# שנה את GITHUB_ORG="your-username"

# 2. הרץ
chmod +x scripts/github-split.sh
./scripts/github-split.sh
```

### הגדרות PLOI (לכל repo):
```yaml
# ULM Service:
Repository: github.com/YOUR_ORG/ovu-ulm
Deploy Path: /var/www/ulm

# AAM Service:
Repository: github.com/YOUR_ORG/ovu-aam
Deploy Path: /var/www/aam
```

---

## 🔄 אופציה 3: Hybrid (הכי גמיש)

### מבנה:
```
# Main orchestration repo
github.com/YOUR_USERNAME/ovu-system/
├── .gitmodules
├── services/
│   ├── ulm/ -> submodule
│   └── aam/ -> submodule
└── deployment/

# Service repos
github.com/YOUR_USERNAME/ovu-ulm/
github.com/YOUR_USERNAME/ovu-aam/
```

### איך ליצור:
```bash
# 1. צור repos נפרדים לשירותים
./scripts/github-split.sh

# 2. צור main repo עם submodules
git init ovu-main
cd ovu-main
git submodule add https://github.com/YOUR_USERNAME/ovu-ulm.git services/ulm
git submodule add https://github.com/YOUR_USERNAME/ovu-aam.git services/aam
git add .
git commit -m "Add submodules"
git push
```

---

## 🚀 המלצת Action Plan:

### Phase 1 (עכשיו) - Monorepo
```bash
# פשוט הרץ:
./scripts/github-monorepo.sh
```
**יתרונות:**
- מהיר להתחיל
- קל לפיתוח
- PLOI יעבוד מיד

### Phase 2 (בעוד 3-6 חודשים) - הערכה
- יש יותר מ-2 מפתחים? ✓
- צריך CI/CD נפרד? ✓
- צריך הרשאות שונות? ✓

אם כן → עבור ל-Multi-repo

### Phase 3 (אם צריך) - Migration
```bash
# הסקריפט כבר מוכן:
./scripts/github-split.sh
```

---

## 📋 Checklist להעלאה:

### לפני ההעלאה:
- [ ] מחק קבצים רגישים (.env עם passwords)
- [ ] בדוק שאין secrets ב-code
- [ ] וודא ש-.gitignore מעודכן

### אחרי ההעלאה:
- [ ] הוסף README עם badges
- [ ] הגדר branch protection
- [ ] הוסף LICENSE file
- [ ] הגדר GitHub Actions (CI/CD)
- [ ] הזמן collaborators
- [ ] חבר ל-PLOI

---

## 🔐 Security Tips:

1. **אל תעלה .env אמיתי!**
```bash
# וודא שזה ב-.gitignore:
echo ".env" >> .gitignore
```

2. **השתמש ב-GitHub Secrets:**
```yaml
# ב-GitHub → Settings → Secrets
DATABASE_PASSWORD=xxx
JWT_SECRET=xxx
```

3. **הפעל 2FA ב-GitHub**

---

## 🎯 ההחלטה שלך:

### אם אתה:
- **מפתח יחיד** → Monorepo ✅
- **צוות קטן (2-5)** → Monorepo ✅
- **צוות גדול (5+)** → Multi-repo ✅
- **חברה/Enterprise** → Multi-repo ✅

### המלצה אישית:
**התחל עם Monorepo!** זה יותר פשוט ותמיד תוכל לפצל אחר כך.

```bash
# Just run:
./scripts/github-monorepo.sh

# Done! 🎉
```

---

## 🆘 בעיות נפוצות:

### "Permission denied"
```bash
# GitHub CLI:
gh auth refresh

# או עם SSH:
git remote set-url origin git@github.com:USER/REPO.git
```

### "Repository already exists"
```bash
# מחק את הישן:
gh repo delete YOUR_USERNAME/ovu-system --confirm

# או שנה שם:
gh repo rename new-name
```

### "Large files warning"
```bash
# הוסף ל-.gitignore:
*.log
*.sql
node_modules/
venv/
```

**בהצלחה!** 🚀
