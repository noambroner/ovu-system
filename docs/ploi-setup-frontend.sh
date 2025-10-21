#!/bin/bash
# PLOI Frontend Server Setup Script
# Run this script in PLOI Scripts section for the Frontend Server

set -e

echo "🚀 Setting up OVU Frontend Server..."

# Install Node.js and build tools
echo "📦 Installing Node.js and system dependencies..."
apt update && apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs git build-essential

# Install Flutter (for building)
echo "📦 Installing Flutter SDK..."
cd /opt
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:/opt/flutter/bin"
flutter doctor --android-licenses || true
flutter doctor

# Create application directories
echo "📁 Creating application directories..."
mkdir -p /var/www/{ulm-frontend,aam-frontend,ovu-main,temp-build}
chown -R ploi:ploi /var/www/

# Clone repositories
echo "📥 Cloning frontend code from GitHub..."
cd /var/www/temp-build

# Clone ULM repository (contains Flutter app)
git clone https://github.com/noambroner/ovu-ulm.git
cd ovu-ulm/frontend/flutter

# Build ULM Flutter Web App
echo "🔨 Building ULM Flutter Web App..."
/opt/flutter/bin/flutter pub get
/opt/flutter/bin/flutter build web --release --web-renderer html --base-href /

# Copy build to frontend directory
cp -r build/web/* /var/www/ulm-frontend/

cd /var/www/temp-build

# Clone AAM repository (contains Flutter app)
git clone https://github.com/noambroner/ovu-aam.git
cd ovu-aam/frontend/flutter

# Build AAM Flutter Web App
echo "🔨 Building AAM Flutter Web App..."
/opt/flutter/bin/flutter pub get
/opt/flutter/bin/flutter build web --release --web-renderer html --base-href /

# Copy build to frontend directory
cp -r build/web/* /var/www/aam-frontend/

# Create main landing page
echo "📄 Creating main landing page..."
cat > /var/www/ovu-main/index.html << 'HTML'
<!DOCTYPE html>
<html dir="rtl" lang="he">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OVU Management System</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            text-align: center;
            background: white;
            padding: 3rem;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 600px;
            margin: 2rem;
        }
        h1 {
            color: #333;
            margin-bottom: 1rem;
            font-size: 2.5rem;
        }
        p {
            color: #666;
            margin-bottom: 2rem;
            font-size: 1.2rem;
        }
        .buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            flex-wrap: wrap;
        }
        .btn {
            padding: 1rem 2rem;
            background: #667eea;
            color: white;
            text-decoration: none;
            border-radius: 10px;
            font-size: 1.1rem;
            transition: all 0.3s ease;
            display: inline-block;
        }
        .btn:hover {
            background: #5a67d8;
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
        }
        .btn.admin {
            background: #f56565;
        }
        .btn.admin:hover {
            background: #e53e3e;
        }
        .features {
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #e2e8f0;
        }
        .feature {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin: 0.5rem 0;
            color: #4a5568;
        }
        .lang-switcher {
            position: absolute;
            top: 20px;
            left: 20px;
            display: flex;
            gap: 10px;
        }
        .lang-btn {
            padding: 5px 10px;
            background: white;
            border: 1px solid #ddd;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.3s;
        }
        .lang-btn:hover {
            background: #f0f0f0;
        }
        .lang-btn.active {
            background: #667eea;
            color: white;
        }
    </style>
</head>
<body>
    <div class="lang-switcher">
        <button class="lang-btn active" onclick="setLang('he')">עברית</button>
        <button class="lang-btn" onclick="setLang('en')">English</button>
        <button class="lang-btn" onclick="setLang('ar')">العربية</button>
    </div>
    
    <div class="container">
        <h1 id="title">מערכת ניהול OVU</h1>
        <p id="subtitle">פלטפורמת ניהול מתקדמת עם תמיכה מלאה בריבוי שפות</p>
        
        <div class="buttons">
            <a href="https://ulm.ovu.co.il" class="btn" id="ulm-btn">כניסת משתמשים</a>
            <a href="https://aam.ovu.co.il" class="btn admin" id="aam-btn">פאנל ניהול</a>
        </div>
        
        <div class="features">
            <div class="feature">
                <span>✓</span>
                <span id="feat1">תמיכה מלאה בעברית, אנגלית וערבית</span>
            </div>
            <div class="feature">
                <span>✓</span>
                <span id="feat2">ממשק RTL מותאם לשפות ימין-לשמאל</span>
            </div>
            <div class="feature">
                <span>✓</span>
                <span id="feat3">אבטחה מתקדמת עם JWT</span>
            </div>
            <div class="feature">
                <span>✓</span>
                <span id="feat4">ביצועים מהירים עם FastAPI</span>
            </div>
        </div>
    </div>
    
    <script>
        const translations = {
            he: {
                title: 'מערכת ניהול OVU',
                subtitle: 'פלטפורמת ניהול מתקדמת עם תמיכה מלאה בריבוי שפות',
                ulmBtn: 'כניסת משתמשים',
                aamBtn: 'פאנל ניהול',
                feat1: 'תמיכה מלאה בעברית, אנגלית וערבית',
                feat2: 'ממשק RTL מותאם לשפות ימין-לשמאל',
                feat3: 'אבטחה מתקדמת עם JWT',
                feat4: 'ביצועים מהירים עם FastAPI',
                dir: 'rtl'
            },
            en: {
                title: 'OVU Management System',
                subtitle: 'Advanced management platform with full multilingual support',
                ulmBtn: 'User Login',
                aamBtn: 'Admin Panel',
                feat1: 'Full support for Hebrew, English and Arabic',
                feat2: 'RTL interface adapted for right-to-left languages',
                feat3: 'Advanced security with JWT',
                feat4: 'Fast performance with FastAPI',
                dir: 'ltr'
            },
            ar: {
                title: 'نظام إدارة OVU',
                subtitle: 'منصة إدارة متقدمة مع دعم كامل متعدد اللغات',
                ulmBtn: 'دخول المستخدم',
                aamBtn: 'لوحة الإدارة',
                feat1: 'دعم كامل للعبرية والإنجليزية والعربية',
                feat2: 'واجهة RTL مُكيفة للغات من اليمين إلى اليسار',
                feat3: 'أمان متقدم مع JWT',
                feat4: 'أداء سريع مع FastAPI',
                dir: 'rtl'
            }
        };
        
        function setLang(lang) {
            const t = translations[lang];
            document.documentElement.dir = t.dir;
            document.documentElement.lang = lang;
            
            document.getElementById('title').textContent = t.title;
            document.getElementById('subtitle').textContent = t.subtitle;
            document.getElementById('ulm-btn').textContent = t.ulmBtn;
            document.getElementById('aam-btn').textContent = t.aamBtn;
            document.getElementById('feat1').textContent = t.feat1;
            document.getElementById('feat2').textContent = t.feat2;
            document.getElementById('feat3').textContent = t.feat3;
            document.getElementById('feat4').textContent = t.feat4;
            
            document.querySelectorAll('.lang-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            event.target.classList.add('active');
        }
    </script>
</body>
</html>
HTML

# Create deployment script
echo "📜 Creating deployment script..."
cat > /var/www/deploy-frontend.sh << 'DEPLOY'
#!/bin/bash
# OVU Frontend Deployment Script

set -e

echo "🚀 Deploying OVU Frontend..."

cd /var/www/temp-build

# Pull latest changes
echo "📥 Pulling latest code..."
rm -rf ovu-ulm ovu-aam
git clone https://github.com/noambroner/ovu-ulm.git
git clone https://github.com/noambroner/ovu-aam.git

# Build ULM
echo "🔨 Building ULM..."
cd ovu-ulm/frontend/flutter
/opt/flutter/bin/flutter pub get
/opt/flutter/bin/flutter build web --release --web-renderer html --base-href /
cp -r build/web/* /var/www/ulm-frontend/

# Build AAM
echo "🔨 Building AAM..."
cd /var/www/temp-build/ovu-aam/frontend/flutter
/opt/flutter/bin/flutter pub get
/opt/flutter/bin/flutter build web --release --web-renderer html --base-href /
cp -r build/web/* /var/www/aam-frontend/

# Fix permissions
chown -R ploi:ploi /var/www/ulm-frontend
chown -R ploi:ploi /var/www/aam-frontend

echo "✅ Frontend deployment complete!"
DEPLOY

chmod +x /var/www/deploy-frontend.sh

# Fix permissions
chown -R ploi:ploi /var/www/

echo "✅ Frontend server setup complete!"
echo ""
echo "📋 Next steps in PLOI:"
echo "1. Create 3 sites: ulm.ovu.co.il, aam.ovu.co.il, ovu.co.il"
echo "2. Point each site to correct directory:"
echo "   - ulm.ovu.co.il → /var/www/ulm-frontend"
echo "   - aam.ovu.co.il → /var/www/aam-frontend"
echo "   - ovu.co.il → /var/www/ovu-main"
echo "3. Configure NGINX proxy rules for API calls"
echo "4. Enable SSL certificates for all sites"







