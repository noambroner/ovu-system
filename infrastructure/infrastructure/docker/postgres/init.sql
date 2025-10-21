-- Create databases for each microservice
CREATE DATABASE ulm_db;
CREATE DATABASE aam_db;

-- Grant all privileges to the ovu_user
GRANT ALL PRIVILEGES ON DATABASE ulm_db TO ovu_user;
GRANT ALL PRIVILEGES ON DATABASE aam_db TO ovu_user;

-- Create extensions in ulm_db
\c ulm_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create extensions in aam_db
\c aam_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create default roles in ulm_db
\c ulm_db;
CREATE TABLE IF NOT EXISTS system_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    is_system_role BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert default system roles
INSERT INTO system_roles (name, description, is_system_role) VALUES
    ('super_admin', 'Full system access - can manage all services and users', true),
    ('admin', 'Administrative access - can manage users and settings', true),
    ('developer', 'Developer access - can manage projects and code', true),
    ('support', 'Support team access - can view and assist users', true),
    ('user', 'Regular user access - basic permissions', true)
ON CONFLICT (name) DO NOTHING;

-- Create default permissions
CREATE TABLE IF NOT EXISTS system_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    resource VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(resource, action)
);

-- Insert default permissions
INSERT INTO system_permissions (resource, action, description) VALUES
    ('users', 'create', 'Create new users'),
    ('users', 'read', 'View user information'),
    ('users', 'update', 'Update user information'),
    ('users', 'delete', 'Delete users'),
    ('roles', 'create', 'Create new roles'),
    ('roles', 'read', 'View roles'),
    ('roles', 'update', 'Update roles'),
    ('roles', 'delete', 'Delete roles'),
    ('permissions', 'create', 'Create new permissions'),
    ('permissions', 'read', 'View permissions'),
    ('permissions', 'update', 'Update permissions'),
    ('permissions', 'delete', 'Delete permissions'),
    ('settings', 'read', 'View system settings'),
    ('settings', 'update', 'Update system settings'),
    ('logs', 'read', 'View system logs'),
    ('api_keys', 'create', 'Create API keys'),
    ('api_keys', 'read', 'View API keys'),
    ('api_keys', 'delete', 'Revoke API keys')
ON CONFLICT (resource, action) DO NOTHING;
