# AAM - Admin Area Manager

## 📋 תיאור
פאנל ניהול מרכזי למערכת OVU - מספק ממשק ניהול מתקדם לכל המיקרו-שירותים.

## 🎯 פונקציונליות
- ✅ Dashboard מרכזי עם סטטיסטיקות real-time
- ✅ ניהול משתמשים (דרך ULM API)
- ✅ ניהול הגדרות מערכת
- ✅ מוניטורינג ולוגים
- ✅ ניהול מיקרו-שירותים
- ✅ Analytics ודוחות
- ✅ ניהול הרשאות מתקדם
- ✅ Service Health Monitoring
- ✅ Audit Logs

## 🏗️ ארכיטקטורה

### Backend (FastAPI)
```
backend/
├── app/
│   ├── api/
│   │   ├── v1/
│   │   │   ├── endpoints/
│   │   │   │   ├── dashboard.py
│   │   │   │   ├── users.py
│   │   │   │   ├── settings.py
│   │   │   │   ├── services.py
│   │   │   │   ├── logs.py
│   │   │   │   └── analytics.py
│   │   │   └── router.py
│   │   └── deps.py
│   ├── core/
│   │   ├── config.py
│   │   ├── security.py
│   │   ├── database.py
│   │   └── ulm_client.py
│   ├── models/
│   │   ├── dashboard.py
│   │   ├── settings.py
│   │   └── analytics.py
│   ├── schemas/
│   │   ├── dashboard.py
│   │   ├── settings.py
│   │   └── analytics.py
│   ├── services/
│   │   ├── dashboard_service.py
│   │   ├── analytics_service.py
│   │   ├── monitoring_service.py
│   │   └── ulm_proxy_service.py
│   └── main.py
├── tests/
├── alembic/
├── requirements.txt
└── Dockerfile
```

### Frontend (Flutter)
```
frontend/flutter/
├── lib/
│   ├── api/
│   │   ├── aam_api.dart
│   │   └── ulm_api.dart
│   ├── models/
│   │   ├── dashboard.dart
│   │   ├── user.dart
│   │   └── service.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   └── dashboard_provider.dart
│   ├── screens/
│   │   ├── dashboard/
│   │   ├── users/
│   │   ├── settings/
│   │   ├── services/
│   │   └── analytics/
│   ├── widgets/
│   │   ├── charts/
│   │   ├── tables/
│   │   └── cards/
│   └── main.dart
├── test/
└── pubspec.yaml
```

## 📊 Database Schema

### Settings Table
```sql
CREATE TABLE settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category VARCHAR(100) NOT NULL,
    key VARCHAR(255) NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    is_sensitive BOOLEAN DEFAULT false,
    updated_by UUID,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(category, key)
);
```

### Audit_Logs Table
```sql
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    action VARCHAR(100) NOT NULL,
    resource VARCHAR(100),
    resource_id VARCHAR(255),
    old_value JSONB,
    new_value JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

### Service_Health Table
```sql
CREATE TABLE service_health (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    service_name VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,
    response_time FLOAT,
    error_message TEXT,
    checked_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    details JSONB
);
```

### Dashboard_Widgets Table
```sql
CREATE TABLE dashboard_widgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    widget_type VARCHAR(100) NOT NULL,
    position INT NOT NULL,
    size VARCHAR(20) NOT NULL,
    config JSONB,
    is_visible BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

## 🔗 API Endpoints

### Dashboard
- `GET /api/v1/dashboard/stats` - Get dashboard statistics
- `GET /api/v1/dashboard/widgets` - Get user widgets
- `PUT /api/v1/dashboard/widgets` - Update widget configuration
- `GET /api/v1/dashboard/activity` - Get recent activity

### User Management (Proxy to ULM)
- `GET /api/v1/users` - List all users
- `GET /api/v1/users/{id}` - Get user details
- `PUT /api/v1/users/{id}` - Update user
- `DELETE /api/v1/users/{id}` - Delete user
- `POST /api/v1/users/{id}/roles` - Assign roles
- `POST /api/v1/users/{id}/suspend` - Suspend user
- `POST /api/v1/users/{id}/activate` - Activate user

### Settings Management
- `GET /api/v1/settings` - Get all settings
- `GET /api/v1/settings/{category}` - Get category settings
- `PUT /api/v1/settings/{category}/{key}` - Update setting
- `POST /api/v1/settings/reset` - Reset to defaults

### Service Management
- `GET /api/v1/services/status` - Get all services status
- `GET /api/v1/services/{name}/health` - Get service health
- `POST /api/v1/services/{name}/restart` - Restart service
- `GET /api/v1/services/{name}/logs` - Get service logs
- `GET /api/v1/services/{name}/metrics` - Get service metrics

### Monitoring & Logs
- `GET /api/v1/logs` - Get system logs
- `GET /api/v1/logs/audit` - Get audit logs
- `GET /api/v1/logs/errors` - Get error logs
- `GET /api/v1/logs/export` - Export logs
- `GET /api/v1/alerts` - Get active alerts
- `POST /api/v1/alerts/{id}/acknowledge` - Acknowledge alert

### Analytics
- `GET /api/v1/analytics/users` - User analytics
- `GET /api/v1/analytics/usage` - Usage analytics
- `GET /api/v1/analytics/performance` - Performance metrics
- `GET /api/v1/analytics/reports` - Generate reports

## 🎨 Dashboard Features

### Real-time Widgets
- **User Statistics** - Total, active, new users
- **Service Health** - Status of all microservices
- **Activity Feed** - Recent system activities
- **Performance Metrics** - CPU, Memory, Response times
- **Error Rate** - System errors and warnings
- **API Usage** - API calls and rate limits

### Management Panels
- **User Management** - Full CRUD operations
- **Role Management** - Define and assign roles
- **Settings Panel** - System configuration
- **Service Control** - Start/stop/restart services
- **Log Viewer** - Real-time log streaming
- **Report Generator** - Custom analytics reports

## 🔐 Security Features

### Authentication
- JWT-based authentication (via ULM)
- Admin-only access control
- Session management
- Activity tracking

### Authorization
- Role-based permissions
- Resource-level access control
- Action audit logging
- IP whitelisting (optional)

## 🚀 Running the Service

### Development
```bash
# Backend
cd services/aam/backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8002

# Frontend (Flutter)
cd services/aam/frontend/flutter
flutter pub get
flutter run -d web --web-port 3002
```

### Production (Docker)
```bash
docker-compose up aam
```

## 🧪 Testing

```bash
# Backend tests
cd services/aam/backend
pytest tests/ -v --cov=app

# Frontend tests
cd services/aam/frontend/flutter
flutter test
```

## 📝 Environment Variables

```env
# Database
DATABASE_URL=postgresql://user:pass@localhost/aam_db

# Security
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256

# ULM Service
ULM_SERVICE_URL=http://ulm_backend:8001

# Redis
REDIS_URL=redis://localhost:6379/1

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=admin@ovu.co.il
SMTP_PASSWORD=your-password

# Service Configuration
SERVICE_NAME=AAM
SERVICE_URL=https://aam.ovu.co.il
CORS_ORIGINS=["https://aam.ovu.co.il", "https://ovu.co.il"]

# Dashboard
DASHBOARD_REFRESH_INTERVAL=30
MAX_CHART_POINTS=100
DEFAULT_DATE_RANGE=7

# Features
ENABLE_USER_IMPERSONATION=false
ENABLE_DATABASE_ADMIN=false
ENABLE_LOG_VIEWER=true
ENABLE_SERVICE_MANAGER=true
```

## 📚 Dependencies

### Backend
- FastAPI
- SQLAlchemy
- httpx (for service communication)
- pandas & numpy (for analytics)
- prometheus-client (for metrics)
- matplotlib (for charts)
- reportlab (for PDF reports)

### Frontend
- dio (HTTP client)
- provider/riverpod (State management)
- fl_chart (Charts)
- data_table_2 (Advanced tables)
- go_router (Navigation)
