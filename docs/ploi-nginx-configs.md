# 🔧 NGINX Configurations for PLOI Sites

## 1. ULM Site Configuration
**Site: ulm.ovu.co.il**  
**In PLOI: Sites → ulm.ovu.co.il → NGINX Configuration**

```nginx
# ULM Frontend Configuration
server {
    listen 80;
    listen [::]:80;
    server_name ulm.ovu.co.il www.ulm.ovu.co.il;
    
    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ulm.ovu.co.il www.ulm.ovu.co.il;

    # SSL certificates (PLOI manages these)
    ssl_certificate /etc/letsencrypt/live/ulm.ovu.co.il/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ulm.ovu.co.il/privkey.pem;

    # Web root
    root /var/www/ulm-frontend;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Flutter Web App
    location / {
        try_files $uri $uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 30d;
            add_header Cache-Control "public, immutable";
        }
    }

    # API Proxy to Backend Server
    location /api/ {
        proxy_pass http://BACKEND_SERVER_IP:8001/;
        proxy_http_version 1.1;
        
        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # CORS (if needed)
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' 'https://ulm.ovu.co.il' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, Accept, Origin, X-Requested-With' always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
            add_header 'Access-Control-Max-Age' 86400 always;
            add_header 'Content-Type' 'text/plain; charset=utf-8' always;
            add_header 'Content-Length' 0 always;
            return 204;
        }
    }

    # Health check endpoint
    location /health {
        access_log off;
        add_header 'Content-Type' 'text/plain';
        return 200 'healthy';
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
```

---

## 2. AAM Site Configuration
**Site: aam.ovu.co.il**  
**In PLOI: Sites → aam.ovu.co.il → NGINX Configuration**

```nginx
# AAM Frontend Configuration
server {
    listen 80;
    listen [::]:80;
    server_name aam.ovu.co.il www.aam.ovu.co.il;
    
    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name aam.ovu.co.il www.aam.ovu.co.il;

    # SSL certificates (PLOI manages these)
    ssl_certificate /etc/letsencrypt/live/aam.ovu.co.il/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/aam.ovu.co.il/privkey.pem;

    # Web root
    root /var/www/aam-frontend;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Flutter Web App
    location / {
        try_files $uri $uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 30d;
            add_header Cache-Control "public, immutable";
        }
    }

    # API Proxy to Backend Server
    location /api/ {
        proxy_pass http://BACKEND_SERVER_IP:8002/;
        proxy_http_version 1.1;
        
        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Admin-specific headers
        proxy_set_header X-Admin-Request "true";
    }

    # Health check endpoint
    location /health {
        access_log off;
        add_header 'Content-Type' 'text/plain';
        return 200 'healthy';
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
```

---

## 3. Main Site Configuration
**Site: ovu.co.il**  
**In PLOI: Sites → ovu.co.il → NGINX Configuration**

```nginx
# Main OVU Site Configuration
server {
    listen 80;
    listen [::]:80;
    server_name ovu.co.il www.ovu.co.il;
    
    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ovu.co.il www.ovu.co.il;

    # SSL certificates (PLOI manages these)
    ssl_certificate /etc/letsencrypt/live/ovu.co.il/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ovu.co.il/privkey.pem;

    # Web root
    root /var/www/ovu-main;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Content-Security-Policy "default-src 'self' https://ulm.ovu.co.il https://aam.ovu.co.il; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;

    # Main landing page
    location / {
        try_files $uri $uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 30d;
            add_header Cache-Control "public, immutable";
        }
    }

    # Redirect to ULM
    location /login {
        return 301 https://ulm.ovu.co.il;
    }

    # Redirect to AAM
    location /admin {
        return 301 https://aam.ovu.co.il;
    }

    # API Documentation (optional)
    location /api-docs {
        proxy_pass http://BACKEND_SERVER_IP:8001/docs;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Health check endpoint
    location /health {
        access_log off;
        add_header 'Content-Type' 'application/json';
        return 200 '{"status":"healthy","service":"main"}';
    }

    # Robots.txt
    location /robots.txt {
        add_header Content-Type text/plain;
        return 200 "User-agent: *\nAllow: /\nSitemap: https://ovu.co.il/sitemap.xml";
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
```

---

## 4. Backend API Site (Optional)
**Site: api.ovu.co.il**  
**In PLOI: Sites → api.ovu.co.il → NGINX Configuration**

```nginx
# API Documentation and Direct Access
server {
    listen 80;
    listen [::]:80;
    server_name api.ovu.co.il;
    
    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name api.ovu.co.il;

    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/api.ovu.co.il/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.ovu.co.il/privkey.pem;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;

    # ULM API
    location /ulm/ {
        proxy_pass http://BACKEND_SERVER_IP:8001/;
        include /etc/nginx/proxy_params;
    }

    # AAM API
    location /aam/ {
        proxy_pass http://BACKEND_SERVER_IP:8002/;
        include /etc/nginx/proxy_params;
    }

    # API Documentation
    location / {
        proxy_pass http://BACKEND_SERVER_IP:8001/docs;
        include /etc/nginx/proxy_params;
    }
}
```

---

## Important Notes:

1. **Replace `BACKEND_SERVER_IP`** with your actual backend server IP address
2. **SSL Certificates** - PLOI will handle Let's Encrypt SSL automatically
3. **After updating NGINX** - Click "Reload NGINX" in PLOI
4. **Test configuration** - Use PLOI's "Test NGINX Configuration" button
5. **Monitor logs** - Check PLOI's log viewer for any errors

## Security Recommendations:

1. Enable **Firewall Rules** in PLOI between servers
2. Use **Private Network** if VULTR supports it
3. Enable **Rate Limiting** for API endpoints
4. Configure **Fail2ban** via PLOI security settings
5. Enable **Auto-Updates** for security patches







