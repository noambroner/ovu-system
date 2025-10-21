#!/bin/bash
# PLOI Backend Server Setup Script
# Run this script in PLOI Scripts section for the Backend Server

set -e

echo "🚀 Setting up OVU Backend Server..."

# Install Python 3.11 and dependencies
echo "📦 Installing Python and system dependencies..."
apt update && apt upgrade -y
apt install -y python3.11 python3.11-venv python3-pip
apt install -y supervisor nginx
apt install -y postgresql-client redis-tools
apt install -y git curl build-essential

# Create application directories
echo "📁 Creating application directories..."
mkdir -p /var/www/ovu-backend/{ulm,aam,shared}
chown -R ploi:ploi /var/www/ovu-backend

# Clone repositories
echo "📥 Cloning OVU repositories from GitHub..."
cd /var/www/ovu-backend

# Clone ULM service
if [ ! -d "ulm/.git" ]; then
    git clone https://github.com/noambroner/ovu-ulm.git ulm
else
    cd ulm && git pull origin main && cd ..
fi

# Clone AAM service
if [ ! -d "aam/.git" ]; then
    git clone https://github.com/noambroner/ovu-aam.git aam
else
    cd aam && git pull origin main && cd ..
fi

# Clone shared resources
if [ ! -d "shared/.git" ]; then
    git clone https://github.com/noambroner/ovu-shared.git shared
else
    cd shared && git pull origin main && cd ..
fi

# Setup Python virtual environment
echo "🐍 Setting up Python virtual environment..."
cd /var/www/ovu-backend
python3.11 -m venv venv
source venv/bin/activate

# Install Python dependencies
echo "📦 Installing Python packages..."
pip install --upgrade pip setuptools wheel

# Install ULM requirements
if [ -f "ulm/backend/requirements.txt" ]; then
    pip install -r ulm/backend/requirements.txt
fi

# Install AAM requirements
if [ -f "aam/backend/requirements.txt" ]; then
    pip install -r aam/backend/requirements.txt
fi

# Create environment file template
echo "📝 Creating environment configuration template..."
cat > /var/www/ovu-backend/.env.example << 'EOF'
# Database Configuration
DB_HOST=YOUR_DATABASE_SERVER_IP
DB_PORT=5432
DB_USER=ovu_user
DB_PASSWORD=YOUR_DB_PASSWORD
ULM_DB_NAME=ulm_db
AAM_DB_NAME=aam_db

# Redis Configuration
REDIS_HOST=YOUR_DATABASE_SERVER_IP
REDIS_PORT=6379
REDIS_PASSWORD=YOUR_REDIS_PASSWORD

# API Configuration
API_HOST=0.0.0.0
DEBUG=false
API_WORKERS=4

# Security
SECRET_KEY=GENERATE_64_CHAR_RANDOM_STRING
JWT_SECRET=ANOTHER_64_CHAR_RANDOM_STRING
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24

# CORS Configuration
CORS_ORIGINS=["https://ulm.ovu.co.il", "https://aam.ovu.co.il", "https://ovu.co.il"]

# Localization
DEFAULT_LANGUAGE=he
SUPPORTED_LANGUAGES=["he", "en", "ar"]
RTL_LANGUAGES=["he", "ar"]
EOF

# Create deployment script
echo "📜 Creating deployment script..."
cat > /var/www/ovu-backend/deploy.sh << 'DEPLOY'
#!/bin/bash
# OVU Backend Deployment Script

set -e

echo "🚀 Deploying OVU Backend Services..."

cd /var/www/ovu-backend

# Pull latest changes
echo "📥 Pulling latest code..."
cd ulm && git pull origin main && cd ..
cd aam && git pull origin main && cd ..
cd shared && git pull origin main && cd ..

# Activate virtual environment
source venv/bin/activate

# Update dependencies
echo "📦 Updating dependencies..."
pip install --upgrade -r ulm/backend/requirements.txt
pip install --upgrade -r aam/backend/requirements.txt

# Run database migrations (if using Alembic)
# echo "🗃️ Running database migrations..."
# cd ulm/backend && alembic upgrade head && cd ../..
# cd aam/backend && alembic upgrade head && cd ../..

# Restart services
echo "🔄 Restarting services..."
sudo supervisorctl restart ulm-api
sudo supervisorctl restart aam-api

echo "✅ Deployment complete!"
echo "Check service status:"
echo "  sudo supervisorctl status"
DEPLOY

chmod +x /var/www/ovu-backend/deploy.sh

# Fix permissions
chown -R ploi:ploi /var/www/ovu-backend

echo "✅ Backend server setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Copy .env.example to .env and fill in your values"
echo "2. Create supervisor daemons in PLOI for ULM and AAM"
echo "3. Configure NGINX proxy rules"
echo "4. Run deployment: /var/www/ovu-backend/deploy.sh"







