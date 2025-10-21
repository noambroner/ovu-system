import { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, useNavigate, useLocation } from 'react-router-dom';
import axios from 'axios';
import { Sidebar } from './components/Sidebar/Sidebar';
import { Dashboard } from './components/Dashboard/Dashboard';
import { ManagePage } from './components/ManagePage/ManagePage';
import { APIUIEndpoints } from './components/APIUIEndpoints/APIUIEndpoints';
import { APIFunctions } from './components/APIFunctions/APIFunctions';
import './App.css';
import './components/Layout/Layout.css';

interface UserInfo {
  id: number;
  username: string;
  email: string;
  role: string;
}

const translations = {
  he: {
    headerTitle: 'מערכת ניהול אדמינים',
    langBtn: 'EN',
    themeBtn: (theme: string) => theme === 'light' ? '🌙' : '☀️',
    // Login
    loginTitle: 'התחברות למערכת ניהול',
    email: 'אימייל',
    password: 'סיסמה',
    loginBtn: 'התחבר',
    logout: 'התנתק',
    // Dashboard
    welcome: 'ברוך הבא',
    totalAdmins: 'סה"כ מנהלים',
    activeAdmins: 'מנהלים פעילים',
    systemAlerts: 'התראות מערכת',
    recentActivity: 'פעילות אחרונה',
    // Menu
    dashboard: 'לוח בקרה',
    admins: 'מנהלים',
    allAdmins: 'כל המנהלים',
    addAdmin: 'הוספת מנהל',
    permissions: 'הרשאות',
    roleManagement: 'ניהול תפקידים',
    accessControl: 'בקרת גישה',
    system: 'מערכת',
    logs: 'לוגים',
    settings: 'הגדרות',
    manage: 'ניהול',
    api: 'API',
    apiUIEndpoints: 'UI Endpoints',
    apiFunctions: 'פונקציות',
    // Quick Actions
    addNewAdmin: 'הוסף מנהל',
    viewLogs: 'צפה בלוגים',
    managePermissions: 'נהל הרשאות',
    systemSettings: 'הגדרות מערכת',
    // Activity
    adminCreated: 'מנהל חדש נוצר',
    permissionChanged: 'הרשאה שונתה',
    systemUpdated: 'מערכת עודכנה',
    roleModified: 'תפקיד שונה',
  },
  en: {
    headerTitle: 'Admin Management System',
    langBtn: 'עב',
    themeBtn: (theme: string) => theme === 'light' ? '🌙' : '☀️',
    // Login
    loginTitle: 'Admin Login',
    email: 'Email',
    password: 'Password',
    loginBtn: 'Login',
    logout: 'Logout',
    // Dashboard
    welcome: 'Welcome',
    totalAdmins: 'Total Admins',
    activeAdmins: 'Active Admins',
    systemAlerts: 'System Alerts',
    recentActivity: 'Recent Activity',
    // Menu
    dashboard: 'Dashboard',
    admins: 'Admins',
    allAdmins: 'All Admins',
    addAdmin: 'Add Admin',
    permissions: 'Permissions',
    roleManagement: 'Role Management',
    accessControl: 'Access Control',
    system: 'System',
    logs: 'Logs',
    settings: 'Settings',
    manage: 'Manage',
    api: 'API',
    apiUIEndpoints: 'UI Endpoints',
    apiFunctions: 'Functions',
    // Quick Actions
    addNewAdmin: 'Add Admin',
    viewLogs: 'View Logs',
    managePermissions: 'Manage Permissions',
    systemSettings: 'System Settings',
    // Activity
    adminCreated: 'New admin created',
    permissionChanged: 'Permission changed',
    systemUpdated: 'System updated',
    roleModified: 'Role modified',
  }
};

function AppContent() {
  const [theme, setTheme] = useState<'light' | 'dark'>('dark');
  const [language, setLanguage] = useState<'he' | 'en'>('he');
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [userInfo, setUserInfo] = useState<UserInfo | null>(null);
  const [loading, setLoading] = useState(true);
  
  // Login form
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');

  const navigate = useNavigate();
  const location = useLocation();
  const t = translations[language];

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
    const savedTheme = localStorage.getItem('theme');
    const savedLanguage = localStorage.getItem('language');
    if (savedTheme) setTheme(savedTheme as 'light' | 'dark');
    if (savedLanguage) setLanguage(savedLanguage as 'he' | 'en');
  }, []);

  useEffect(() => {
    localStorage.setItem('theme', theme);
    localStorage.setItem('language', language);
    document.documentElement.setAttribute('data-theme', theme);
  }, [theme, language]);

  useEffect(() => {
    const checkAuth = async () => {
      const token = localStorage.getItem('aam_token');
      if (token) {
        try {
          const response = await axios.get('/api/v1/admin/me', {
            headers: { Authorization: `Bearer ${token}` }
          });
          if (response.data.role === 'admin' || response.data.role === 'super_admin') {
            setUserInfo(response.data);
            setIsLoggedIn(true);
          } else {
            localStorage.removeItem('aam_token');
          }
        } catch (err) {
          localStorage.removeItem('aam_token');
        }
      }
      setLoading(false);
    };
    checkAuth();
  }, []);

  const toggleTheme = () => setTheme(prev => prev === 'light' ? 'dark' : 'light');
  const toggleLanguage = () => setLanguage(prev => prev === 'he' ? 'en' : 'he');

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const response = await axios.post('/api/v1/auth/login', {
        username: email,
        password: password,
      });

      if (response.data.user.role === 'admin' || response.data.user.role === 'super_admin') {
        localStorage.setItem('aam_token', response.data.access_token);
        setUserInfo(response.data.user);
        setIsLoggedIn(true);
        navigate('/dashboard');
      } else {
        setError('Access denied: Admin role required');
      }
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Login failed');
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('aam_token');
    setIsLoggedIn(false);
    setUserInfo(null);
    navigate('/');
  };

  const menuItems = [
    {
      id: 'dashboard',
      label: t.dashboard,
      labelEn: t.dashboard,
      icon: '📊',
      path: '/dashboard'
    },
    {
      id: 'admins',
      label: t.admins,
      labelEn: t.admins,
      icon: '👥',
      path: '/admins',
      subItems: [
        {
          id: 'all-admins',
          label: t.allAdmins,
          labelEn: t.allAdmins,
          icon: '📋',
          path: '/admins/all'
        },
        {
          id: 'add-admin',
          label: t.addAdmin,
          labelEn: t.addAdmin,
          icon: '➕',
          path: '/admins/add'
        }
      ]
    },
    {
      id: 'permissions',
      label: t.permissions,
      labelEn: t.permissions,
      icon: '🔑',
      path: '/permissions',
      subItems: [
        {
          id: 'roles',
          label: t.roleManagement,
          labelEn: t.roleManagement,
          icon: '👔',
          path: '/permissions/roles'
        },
        {
          id: 'access',
          label: t.accessControl,
          labelEn: t.accessControl,
          icon: '🔒',
          path: '/permissions/access'
        }
      ]
    },
    {
      id: 'manage',
      label: t.manage,
      labelEn: t.manage,
      icon: '🛠️',
      path: '/manage',
      subItems: [
        {
          id: 'api',
          label: t.api,
          labelEn: t.api,
          icon: '📡',
          path: '/api',
          subItems: [
            {
              id: 'api-ui',
              label: t.apiUIEndpoints,
              labelEn: t.apiUIEndpoints,
              icon: '🌐',
              path: '/api/ui'
            },
            {
              id: 'api-functions',
              label: t.apiFunctions,
              labelEn: t.apiFunctions,
              icon: '⚡',
              path: '/api/functions'
            }
          ]
        },
        {
          id: 'system',
          label: t.system,
          labelEn: t.system,
          icon: '⚙️',
          path: '/system',
          subItems: [
            {
              id: 'logs',
              label: t.logs,
              labelEn: t.logs,
              icon: '📝',
              path: '/system/logs'
            },
            {
              id: 'settings',
              label: t.settings,
              labelEn: t.settings,
              icon: '🔧',
              path: '/system/settings'
            }
          ]
        }
      ]
    }
  ];

  const stats = [
    {
      icon: '👥',
      label: t.totalAdmins,
      labelEn: t.totalAdmins,
      value: 24,
      change: 3,
      color: 'purple' as const
    },
    {
      icon: '✓',
      label: t.activeAdmins,
      labelEn: t.activeAdmins,
      value: 18,
      change: 2,
      color: 'green' as const
    },
    {
      icon: '⚠️',
      label: t.systemAlerts,
      labelEn: t.systemAlerts,
      value: 7,
      change: -5,
      color: 'orange' as const
    }
  ];

  const activities = [
    {
      id: '1',
      icon: '👤',
      message: t.adminCreated,
      messageEn: t.adminCreated,
      timestamp: language === 'he' ? '10 דקות' : '10 min ago'
    },
    {
      id: '2',
      icon: '🔑',
      message: t.permissionChanged,
      messageEn: t.permissionChanged,
      timestamp: language === 'he' ? '30 דקות' : '30 min ago'
    },
    {
      id: '3',
      icon: '⚙️',
      message: t.systemUpdated,
      messageEn: t.systemUpdated,
      timestamp: language === 'he' ? 'שעה' : '1 hour ago'
    },
    {
      id: '4',
      icon: '👔',
      message: t.roleModified,
      messageEn: t.roleModified,
      timestamp: language === 'he' ? 'שעתיים' : '2 hours ago'
    },    {      id: "5",      icon: "📧",      message: language === "he" ? "מייל נשלח" : "Email sent",      messageEn: "Email sent",      timestamp: language === "he" ? "3 שעות" : "3 hours ago"    },    {      id: "6",      icon: "🔔",      message: language === "he" ? "התראה נוצרה" : "Notification created",      messageEn: "Notification created",      timestamp: language === "he" ? "4 שעות" : "4 hours ago"    },    {      id: "7",      icon: "📊",      message: language === "he" ? "דוח נוצר" : "Report generated",      messageEn: "Report generated",      timestamp: language === "he" ? "5 שעות" : "5 hours ago"    },    {      id: "8",      icon: "🗄️",      message: language === "he" ? "ארכיון נוצר" : "Archive created",      messageEn: "Archive created",      timestamp: language === "he" ? "6 שעות" : "6 hours ago"    },    {      id: "9",      icon: "💾",      message: language === "he" ? "גיבוי הושלם" : "Backup completed",      messageEn: "Backup completed",      timestamp: language === "he" ? "7 שעות" : "7 hours ago"    },    {      id: "10",      icon: "🔐",      message: language === "he" ? "אבטחה עודכנה" : "Security updated",      messageEn: "Security updated",      timestamp: language === "he" ? "8 שעות" : "8 hours ago"    },    {      id: "11",      icon: "📝",      message: language === "he" ? "לוג נוצר" : "Log created",      messageEn: "Log created",      timestamp: language === "he" ? "9 שעות" : "9 hours ago"    },    {      id: "12",      icon: "🔄",      message: language === "he" ? "סנכרון הושלם" : "Sync completed",      messageEn: "Sync completed",      timestamp: language === "he" ? "10 שעות" : "10 hours ago"    },    {      id: "13",      icon: "✅",      message: language === "he" ? "משימת אדמין הושלמה" : "Admin task completed",      messageEn: "Admin task completed",      timestamp: language === "he" ? "11 שעות" : "11 hours ago"    },    {      id: "14",      icon: "🔗",      message: language === "he" ? "אינטגרציה חוברה" : "Integration connected",      messageEn: "Integration connected",      timestamp: language === "he" ? "12 שעות" : "12 hours ago"    },    {      id: "15",      icon: "📤",      message: language === "he" ? "נתונים יוצאו" : "Data exported",      messageEn: "Data exported",      timestamp: language === "he" ? "אתמול" : "Yesterday"
    }
  ];

  const quickActions = [
    {
      label: t.addNewAdmin,
      labelEn: t.addNewAdmin,
      icon: '➕',
      onClick: () => navigate('/admins/add')
    },
    {
      label: t.viewLogs,
      labelEn: t.viewLogs,
      icon: '📝',
      onClick: () => navigate('/system/logs')
    },
    {
      label: t.managePermissions,
      labelEn: t.managePermissions,
      icon: '🔑',
      onClick: () => navigate('/permissions/roles')
    },
    {
      label: t.systemSettings,
      labelEn: t.systemSettings,
      icon: '🔧',
      onClick: () => navigate('/system/settings')
    }
  ];

  if (loading) {
    return <div className="loading">Loading...</div>;
  }

  if (!isLoggedIn) {
    return (
      <div className="app" dir={language === 'he' ? 'rtl' : 'ltr'}>
        <header className="app-header">
          <h1 className="header-title">{t.headerTitle}</h1>
          <div className="header-controls">
            <button onClick={toggleLanguage} className="control-btn lang-btn">
              <span>{t.langBtn}</span>
            </button>
            <button onClick={toggleTheme} className="control-btn theme-btn">
              <span>{t.themeBtn(theme)}</span>
            </button>
          </div>
        </header>

        <main className="main-content">
          <div className="login-card">
            <div className="logo-container">
              <div className="logo-icon">🔐</div>
            </div>
            <h1 className="login-title">{t.loginTitle}</h1>
            {error && <div className="error-message">{error}</div>}
            <form className="login-form" onSubmit={handleLogin}>
              <div className="form-group">
                <label htmlFor="email">{t.email}</label>
                <input
                  type="text"
                  id="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>
              <div className="form-group">
                <label htmlFor="password">{t.password}</label>
                <div className="password-input-wrapper">
                  <input
                    type={showPassword ? 'text' : 'password'}
                    id="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                  />
                  <button
                    type="button"
                    className="toggle-password"
                    onClick={() => setShowPassword(!showPassword)}
                  >
                    {showPassword ? '👁️' : '👁️‍🗨️'}
                  </button>
                </div>
              </div>
              <button type="submit" className="login-btn" disabled={loading}>
                {loading ? '...' : t.loginBtn}
              </button>
            </form>
          </div>
        </main>
      </div>
    );
  }

  return (
    <div className="app-layout" dir={language === 'he' ? 'rtl' : 'ltr'}>
      <Sidebar
        menuItems={menuItems}
        currentPath={location.pathname}
        language={language}
        theme={theme}
        onNavigate={(path) => navigate(path)}
      />
      
      <div className="main-layout">
        <header className="app-header">
          <h1 className="header-title">{t.headerTitle}</h1>
          <div className="header-controls">
            <span className="user-info">{userInfo?.username} ({userInfo?.role})</span>
            <button onClick={toggleLanguage} className="control-btn lang-btn">
              <span>{t.langBtn}</span>
            </button>
            <button onClick={toggleTheme} className="control-btn theme-btn">
              <span>{t.themeBtn(theme)}</span>
            </button>
            <button onClick={handleLogout} className="control-btn logout-btn">
              <span>{t.logout}</span>
            </button>
          </div>
        </header>

        <main className="main-container">
          <Routes>
            <Route path="/dashboard" element={
              <Dashboard
                language={language}
                theme={theme}
                stats={stats}
                activities={activities}
                quickActions={quickActions}
              />
            } />
            <Route path="/admins/all" element={<div className="page-placeholder">👥 {t.allAdmins}</div>} />
            <Route path="/admins/add" element={<div className="page-placeholder">➕ {t.addAdmin}</div>} />
            <Route path="/permissions/roles" element={<div className="page-placeholder">👔 {t.roleManagement}</div>} />
            <Route path="/permissions/access" element={<div className="page-placeholder">🔒 {t.accessControl}</div>} />
            <Route path="/system/logs" element={<div className="page-placeholder">📝 {t.logs}</div>} />
            <Route path="/system/settings" element={<div className="page-placeholder">🔧 {t.settings}</div>} />
            <Route path="/manage" element={<ManagePage language={language} theme={theme} />} />
            <Route path="/api/ui" element={<APIUIEndpoints language={language} theme={theme} appType="aam" />} />
            <Route path="/api/functions" element={<APIFunctions language={language} theme={theme} appType="aam" />} />
            <Route path="*" element={<Dashboard language={language} theme={theme} stats={stats} activities={activities} quickActions={quickActions} />} />
          </Routes>
        </main>
      </div>
    </div>
  );
}

export default function App() {
  return (
    <Router>
      <AppContent />
    </Router>
  );
}
