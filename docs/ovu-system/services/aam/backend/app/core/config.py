"""
Configuration settings for AAM service
"""
from typing import List, Optional
from pydantic_settings import BaseSettings
from pydantic import AnyHttpUrl, validator
import secrets


class Settings(BaseSettings):
    # Service Information
    SERVICE_NAME: str = "AAM - Admin Area Manager"
    SERVICE_VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    PORT: int = 8002
    
    # Security
    SECRET_KEY: str = secrets.token_urlsafe(32)
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # Database
    DATABASE_URL: str = "postgresql+asyncpg://postgres:password@localhost/aam_db"
    DATABASE_POOL_SIZE: int = 20
    DATABASE_MAX_OVERFLOW: int = 40
    DATABASE_POOL_TIMEOUT: int = 30
    
    # Redis
    REDIS_URL: str = "redis://localhost:6379/1"
    REDIS_PASSWORD: Optional[str] = None
    REDIS_POOL_SIZE: int = 10
    REDIS_DECODE_RESPONSES: bool = True
    
    # Email
    SMTP_TLS: bool = True
    SMTP_PORT: int = 587
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""
    EMAILS_FROM_EMAIL: str = "admin@ovu.co.il"
    EMAILS_FROM_NAME: str = "OVU Admin"
    EMAIL_TEMPLATES_DIR: str = "app/templates/email"
    
    # CORS
    BACKEND_CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:3002",
        "http://localhost:8080",
        "https://aam.ovu.co.il",
        "https://ulm.ovu.co.il",
        "https://ovu.co.il"
    ]
    
    @validator("BACKEND_CORS_ORIGINS", pre=True)
    def assemble_cors_origins(cls, v: str | List[str]) -> List[str]:
        if isinstance(v, str):
            return [i.strip() for i in v.split(",")]
        return v
    
    # Service URLs
    ULM_SERVICE_URL: str = "http://ulm_backend:8001"
    FRONTEND_URL: str = "https://aam.ovu.co.il"
    
    # Rate Limiting
    API_RATE_LIMIT: str = "200/minute"  # Higher limit for admin
    
    # Session Configuration
    SESSION_COOKIE_NAME: str = "aam_session"
    SESSION_COOKIE_SECURE: bool = True
    SESSION_COOKIE_HTTPONLY: bool = True
    SESSION_COOKIE_SAMESITE: str = "lax"
    
    # Logging
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"
    SENTRY_DSN: Optional[str] = None
    
    # Analytics & Monitoring
    ENABLE_METRICS: bool = True
    METRICS_PATH: str = "/metrics"
    
    # Dashboard Settings
    DASHBOARD_REFRESH_INTERVAL: int = 30  # seconds
    MAX_CHART_POINTS: int = 100
    DEFAULT_DATE_RANGE: int = 7  # days
    
    # Admin Features
    ENABLE_USER_IMPERSONATION: bool = False
    ENABLE_DATABASE_ADMIN: bool = False
    ENABLE_LOG_VIEWER: bool = True
    ENABLE_SERVICE_MANAGER: bool = True
    
    # Development
    DEBUG: bool = False
    TESTING: bool = False
    
    # Health Check
    HEALTH_CHECK_PATH: str = "/health"
    READY_CHECK_PATH: str = "/ready"
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
