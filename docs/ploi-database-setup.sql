-- OVU System Database Setup Script
-- Run this on your Database Server after PostgreSQL is installed

-- Create user
CREATE USER ovu_user WITH PASSWORD 'YOUR_SECURE_PASSWORD_HERE';

-- Create databases
CREATE DATABASE ulm_db OWNER ovu_user;
CREATE DATABASE aam_db OWNER ovu_user;

-- Grant all privileges
GRANT ALL PRIVILEGES ON DATABASE ulm_db TO ovu_user;
GRANT ALL PRIVILEGES ON DATABASE aam_db TO ovu_user;

-- Connect to ulm_db and create tables
\c ulm_db;

-- Users table for ULM
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    preferred_language VARCHAR(10) DEFAULT 'he',
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sessions table
CREATE TABLE IF NOT EXISTS sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(500) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Password reset tokens
CREATE TABLE IF NOT EXISTS password_resets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User roles
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255)
);

-- User-Role mapping
CREATE TABLE IF NOT EXISTS user_roles (
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id)
);

-- Insert default roles
INSERT INTO roles (name, description) VALUES 
    ('user', 'Regular user'),
    ('admin', 'Administrator'),
    ('moderator', 'Moderator')
ON CONFLICT (name) DO NOTHING;

-- Create indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_sessions_token ON sessions(token);
CREATE INDEX idx_sessions_expires ON sessions(expires_at);
CREATE INDEX idx_password_resets_token ON password_resets(token);

-- Connect to aam_db and create tables
\c aam_db;

-- Admin users table for AAM
CREATE TABLE IF NOT EXISTS admins (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    full_name VARCHAR(200),
    role VARCHAR(50) DEFAULT 'admin',
    permissions JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Admin sessions
CREATE TABLE IF NOT EXISTS admin_sessions (
    id SERIAL PRIMARY KEY,
    admin_id INTEGER REFERENCES admins(id) ON DELETE CASCADE,
    token VARCHAR(500) UNIQUE NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Activity logs
CREATE TABLE IF NOT EXISTS activity_logs (
    id SERIAL PRIMARY KEY,
    admin_id INTEGER REFERENCES admins(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INTEGER,
    details JSONB DEFAULT '{}',
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Settings table
CREATE TABLE IF NOT EXISTS settings (
    key VARCHAR(100) PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_by INTEGER REFERENCES admins(id) ON DELETE SET NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default settings
INSERT INTO settings (key, value, description) VALUES 
    ('site_name', '"OVU Management System"', 'Site name'),
    ('maintenance_mode', 'false', 'Maintenance mode status'),
    ('default_language', '"he"', 'Default system language'),
    ('supported_languages', '["he", "en", "ar"]', 'Supported languages'),
    ('session_timeout', '3600', 'Session timeout in seconds'),
    ('max_login_attempts', '5', 'Maximum login attempts before lockout')
ON CONFLICT (key) DO NOTHING;

-- Create indexes
CREATE INDEX idx_admins_email ON admins(email);
CREATE INDEX idx_admins_username ON admins(username);
CREATE INDEX idx_admin_sessions_token ON admin_sessions(token);
CREATE INDEX idx_activity_logs_admin ON activity_logs(admin_id);
CREATE INDEX idx_activity_logs_created ON activity_logs(created_at);

-- Create a default admin user (CHANGE PASSWORD IMMEDIATELY!)
INSERT INTO admins (email, username, hashed_password, full_name, role) 
VALUES (
    'admin@ovu.co.il',
    'admin',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5ljI0sFuNZFYi', -- password: admin123 (CHANGE THIS!)
    'System Administrator',
    'super_admin'
) ON CONFLICT (email) DO NOTHING;

-- Grant permissions to ovu_user
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO ovu_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO ovu_user;

-- Create update trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add update triggers to tables with updated_at
\c ulm_db;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

\c aam_db;
CREATE TRIGGER update_admins_updated_at BEFORE UPDATE ON admins
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_settings_updated_at BEFORE UPDATE ON settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Display summary
\echo ''
\echo '✅ Database setup complete!'
\echo ''
\echo 'Databases created:'
\echo '  - ulm_db (User Login Manager)'
\echo '  - aam_db (Admin Area Manager)'
\echo ''
\echo 'Default admin credentials:'
\echo '  Email: admin@ovu.co.il'
\echo '  Password: admin123 (CHANGE IMMEDIATELY!)'
\echo ''
\echo 'Next steps:'
\echo '  1. Change the default admin password'
\echo '  2. Update ovu_user password in your .env files'
\echo '  3. Configure Redis for caching'
\echo '  4. Set up regular backups'







