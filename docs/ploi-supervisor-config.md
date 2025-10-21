# 🎯 PLOI Supervisor Daemons Configuration

## ULM API Service Daemon

**In PLOI Dashboard → Server → Daemons → Create New Daemon:**

### Settings:
- **Command:** `/var/www/ovu-backend/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8001 --workers 2`
- **Directory:** `/var/www/ovu-backend/ulm/backend`
- **User:** `ploi`
- **Processes:** `1`
- **Start Seconds:** `1`
- **Stop Wait Seconds:** `10`
- **Stop Signal:** `TERM`

### Environment Variables:
```
DB_HOST=YOUR_DATABASE_SERVER_IP
DB_NAME=ulm_db
DB_USER=ovu_user
DB_PASSWORD=YOUR_PASSWORD
REDIS_HOST=YOUR_DATABASE_SERVER_IP
```

---

## AAM API Service Daemon

**In PLOI Dashboard → Server → Daemons → Create New Daemon:**

### Settings:
- **Command:** `/var/www/ovu-backend/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8002 --workers 2`
- **Directory:** `/var/www/ovu-backend/aam/backend`
- **User:** `ploi`
- **Processes:** `1`
- **Start Seconds:** `1`
- **Stop Wait Seconds:** `10`
- **Stop Signal:** `TERM`

### Environment Variables:
```
DB_HOST=YOUR_DATABASE_SERVER_IP
DB_NAME=aam_db
DB_USER=ovu_user
DB_PASSWORD=YOUR_PASSWORD
REDIS_HOST=YOUR_DATABASE_SERVER_IP
```

---

## Manual Supervisor Configuration (Alternative)

If you prefer manual configuration, SSH to server and create:

### `/etc/supervisor/conf.d/ulm-api.conf`:
```ini
[program:ulm-api]
command=/var/www/ovu-backend/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8001 --workers 2
directory=/var/www/ovu-backend/ulm/backend
user=ploi
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/supervisor/ulm-api.log
environment=PATH="/var/www/ovu-backend/venv/bin",DB_HOST="YOUR_DATABASE_IP",DB_NAME="ulm_db",DB_USER="ovu_user",DB_PASSWORD="YOUR_PASSWORD"
```

### `/etc/supervisor/conf.d/aam-api.conf`:
```ini
[program:aam-api]
command=/var/www/ovu-backend/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8002 --workers 2
directory=/var/www/ovu-backend/aam/backend
user=ploi
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/supervisor/aam-api.log
environment=PATH="/var/www/ovu-backend/venv/bin",DB_HOST="YOUR_DATABASE_IP",DB_NAME="aam_db",DB_USER="ovu_user",DB_PASSWORD="YOUR_PASSWORD"
```

### Apply configuration:
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start all
```

---

## Check Service Status

### Via PLOI:
- Go to Server → Daemons
- Check status indicators

### Via SSH:
```bash
sudo supervisorctl status
# Should show:
# ulm-api                          RUNNING   pid 1234, uptime 0:05:42
# aam-api                          RUNNING   pid 1235, uptime 0:05:42
```

### Check logs:
```bash
# PLOI logs
tail -f /home/ploi/.ploi/daemon-*.log

# Supervisor logs
tail -f /var/log/supervisor/ulm-api.log
tail -f /var/log/supervisor/aam-api.log
```







