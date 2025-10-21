"""
Main FastAPI application for AAM (Admin Area Manager) service
"""
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
import logging
import httpx
import time
from typing import Optional

from app.core.config import settings
from app.core.database import init_db, close_db

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize rate limiter
limiter = Limiter(key_func=get_remote_address)

# HTTP Client for ULM communication
ulm_client = httpx.AsyncClient(
    base_url=settings.ULM_SERVICE_URL,
    timeout=30.0,
    headers={"X-Service": "AAM"}
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Lifespan events for the application
    """
    # Startup
    logger.info(f"Starting {settings.SERVICE_NAME} v{settings.SERVICE_VERSION}")
    
    # Initialize database
    await init_db()
    logger.info("Database initialized")
    
    # Verify ULM connection
    try:
        response = await ulm_client.get("/health")
        if response.status_code == 200:
            logger.info("ULM service connection verified")
        else:
            logger.warning(f"ULM service returned status {response.status_code}")
    except Exception as e:
        logger.error(f"Failed to connect to ULM service: {e}")
    
    yield
    
    # Shutdown
    logger.info("Shutting down AAM service")
    await ulm_client.aclose()
    await close_db()
    logger.info("Database connections closed")


# Create FastAPI app
app = FastAPI(
    title=settings.SERVICE_NAME,
    version=settings.SERVICE_VERSION,
    description="Admin Area Manager - Central administration panel for OVU System",
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url=f"{settings.API_V1_STR}/docs",
    redoc_url=f"{settings.API_V1_STR}/redoc",
    lifespan=lifespan
)

# Add state to app for rate limiting
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["X-Total-Count", "X-Page", "X-Per-Page"]
)

# Request ID middleware
@app.middleware("http")
async def add_request_id(request: Request, call_next):
    """Add unique request ID to each request"""
    import uuid
    request_id = str(uuid.uuid4())
    request.state.request_id = request_id
    
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    
    response.headers["X-Request-ID"] = request_id
    response.headers["X-Process-Time"] = str(process_time)
    response.headers["X-Service"] = "AAM"
    
    # Log request
    logger.info(
        f"Request ID: {request_id} | "
        f"Path: {request.url.path} | "
        f"Method: {request.method} | "
        f"Process Time: {process_time:.3f}s"
    )
    
    return response

# Security headers middleware
@app.middleware("http")
async def add_security_headers(request: Request, call_next):
    """Add security headers to responses"""
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
    response.headers["Content-Security-Policy"] = "default-src 'self'"
    return response

# Root endpoint
@app.get("/", tags=["Root"])
async def root():
    """Root endpoint"""
    return {
        "service": settings.SERVICE_NAME,
        "version": settings.SERVICE_VERSION,
        "status": "operational",
        "description": "Admin Area Manager - Central administration panel",
        "api_docs": f"{settings.API_V1_STR}/docs"
    }

# Health check endpoint
@app.get("/health", tags=["Health"])
async def health_check():
    """Basic health check"""
    return {
        "status": "healthy",
        "service": settings.SERVICE_NAME,
        "version": settings.SERVICE_VERSION
    }

# Readiness check endpoint
@app.get("/ready", tags=["Health"])
async def readiness_check():
    """Readiness check - verify all dependencies"""
    checks = {
        "database": False,
        "redis": False,
        "ulm_service": False
    }
    
    # Check database
    try:
        from app.core.database import engine
        async with engine.connect() as conn:
            await conn.execute("SELECT 1")
            checks["database"] = True
    except Exception as e:
        logger.error(f"Database check failed: {e}")
    
    # Check Redis
    # TODO: Add Redis check
    checks["redis"] = True  # Placeholder
    
    # Check ULM service
    try:
        response = await ulm_client.get("/health")
        checks["ulm_service"] = response.status_code == 200
    except Exception as e:
        logger.error(f"ULM service check failed: {e}")
    
    all_ready = all(checks.values())
    
    return JSONResponse(
        status_code=200 if all_ready else 503,
        content={
            "ready": all_ready,
            "checks": checks
        }
    )

# Dashboard API endpoints
@app.get(f"{settings.API_V1_STR}/dashboard/stats", tags=["Dashboard"])
async def get_dashboard_stats():
    """Get dashboard statistics"""
    # TODO: Implement actual statistics from ULM and other services
    return {
        "users": {
            "total": 150,
            "active": 89,
            "new_today": 5
        },
        "services": {
            "total": 2,
            "active": 2,
            "health": {
                "ulm": "healthy",
                "aam": "healthy"
            }
        },
        "activity": {
            "logins_today": 234,
            "api_calls": 5678,
            "errors": 12
        }
    }

# User management proxy endpoints (calls ULM)
@app.get(f"{settings.API_V1_STR}/users", tags=["User Management"])
async def get_users(
    skip: int = 0,
    limit: int = 100,
    search: Optional[str] = None
):
    """Get users from ULM service"""
    try:
        params = {"skip": skip, "limit": limit}
        if search:
            params["search"] = search
            
        response = await ulm_client.get("/api/v1/users", params=params)
        response.raise_for_status()
        return response.json()
    except httpx.HTTPError as e:
        raise HTTPException(
            status_code=503,
            detail=f"Failed to fetch users from ULM service: {str(e)}"
        )

@app.get(f"{settings.API_V1_STR}/users/{{user_id}}", tags=["User Management"])
async def get_user(user_id: str):
    """Get specific user from ULM service"""
    try:
        response = await ulm_client.get(f"/api/v1/users/{user_id}")
        response.raise_for_status()
        return response.json()
    except httpx.HTTPStatusError as e:
        if e.response.status_code == 404:
            raise HTTPException(status_code=404, detail="User not found")
        raise HTTPException(
            status_code=503,
            detail=f"Failed to fetch user from ULM service: {str(e)}"
        )

# System settings endpoints
@app.get(f"{settings.API_V1_STR}/settings", tags=["Settings"])
async def get_settings():
    """Get system settings"""
    return {
        "general": {
            "site_name": "OVU Management System",
            "timezone": "Asia/Jerusalem",
            "language": "he"
        },
        "security": {
            "password_min_length": 8,
            "mfa_enabled": True,
            "session_timeout": 30
        },
        "email": {
            "smtp_host": settings.SMTP_HOST,
            "smtp_port": settings.SMTP_PORT,
            "from_email": settings.EMAILS_FROM_EMAIL
        }
    }

# Service monitoring endpoints
@app.get(f"{settings.API_V1_STR}/services/status", tags=["Monitoring"])
async def get_services_status():
    """Get status of all microservices"""
    services = []
    
    # Check ULM
    try:
        response = await ulm_client.get("/health")
        services.append({
            "name": "ULM",
            "url": settings.ULM_SERVICE_URL,
            "status": "healthy" if response.status_code == 200 else "unhealthy",
            "response_time": response.elapsed.total_seconds()
        })
    except Exception as e:
        services.append({
            "name": "ULM",
            "url": settings.ULM_SERVICE_URL,
            "status": "unreachable",
            "error": str(e)
        })
    
    # AAM (self)
    services.append({
        "name": "AAM",
        "url": f"http://localhost:{settings.PORT}",
        "status": "healthy"
    })
    
    return {"services": services}

# Logs viewer endpoint
@app.get(f"{settings.API_V1_STR}/logs", tags=["Monitoring"])
async def get_logs(
    service: Optional[str] = None,
    level: Optional[str] = None,
    limit: int = 100
):
    """Get system logs"""
    # TODO: Implement actual log fetching from log aggregation service
    return {
        "logs": [
            {
                "timestamp": "2024-01-01T12:00:00Z",
                "service": service or "all",
                "level": level or "INFO",
                "message": "Sample log entry",
                "details": {}
            }
        ],
        "total": 1
    }

# Custom error handlers
@app.exception_handler(404)
async def not_found_handler(request: Request, exc):
    """Custom 404 handler"""
    return JSONResponse(
        status_code=404,
        content={
            "error": "Not Found",
            "message": f"The requested resource was not found: {request.url.path}",
            "service": "AAM"
        }
    )

@app.exception_handler(500)
async def internal_error_handler(request: Request, exc):
    """Custom 500 handler"""
    request_id = getattr(request.state, 'request_id', 'unknown')
    logger.error(f"Internal server error - Request ID: {request_id}", exc_info=exc)
    
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal Server Error",
            "message": "An unexpected error occurred. Please try again later.",
            "request_id": request_id,
            "service": "AAM"
        }
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8002,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower()
    )
