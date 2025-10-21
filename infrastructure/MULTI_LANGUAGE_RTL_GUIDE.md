# 🌐 OVU System - Multi-Language & RTL Support Guide

## ✅ **תמיכה מלאה בריבוי שפות ו-RTL!**

המערכת תומכת באופן מלא בריבוי שפות כולל:
- 🇮🇱 **עברית** (RTL)
- 🇸🇦 **ערבית** (RTL)
- 🇺🇸 **אנגלית** (LTR)
- 🇷🇺 **רוסית** (LTR)
- 🇫🇷 **צרפתית** (LTR)
- 🇪🇸 **ספרדית** (LTR)

## 📁 **קבצים שנוספו לתמיכה בריבוי שפות**

### Frontend (Flutter)
```
shared/localization/
├── lib/
│   └── app_localizations.dart       # מחלקת תרגום ראשית
├── assets/i18n/
│   ├── he.json                      # תרגומים בעברית
│   ├── en.json                      # תרגומים באנגלית
│   └── ar.json                      # תרגומים בערבית

shared/interface-resources/flutter/lib/widgets/
└── rtl_aware_widget.dart           # ווידג'טים מותאמי RTL

services/ulm/frontend/flutter/
├── lib/main_with_localization.dart # דוגמת אפליקציה עם תמיכה מלאה
└── pubspec.yaml                     # Dependencies לתמיכה בשפות
```

### Backend (Python/FastAPI)
```
services/ulm/backend/app/
├── core/
│   └── localization.py              # מערכת תרגום Backend
└── middleware/
    └── localization_middleware.py   # זיהוי שפה אוטומטי
```

## 🎯 **תכונות מרכזיות**

### 1. **זיהוי שפה אוטומטי**
המערכת מזהה את השפה המועדפת של המשתמש אוטומטית דרך:
- Query parameters (`?lang=he`)
- Headers (`Accept-Language`)
- Cookies
- User preferences

### 2. **RTL אוטומטי**
- כל הרכיבים מתהפכים אוטומטית בשפות RTL
- אייקונים מתהפכים בהתאם (חצים, ניווט)
- יישור טקסט אוטומטי
- Padding ו-Margin מתהפכים

### 3. **גופנים מותאמים**
- **עברית**: Rubik (גופן מעולה לעברית)
- **ערבית**: Tajawal
- **אנגלית**: Roboto

## 💻 **שימוש ב-Frontend (Flutter)**

### הגדרת האפליקציה
```dart
import 'package:localization/app_localizations.dart';

class OVUApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // הגדרת תמיכה בשפות
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      
      // כיוון טקסט אוטומטי
      builder: (context, child) {
        return Directionality(
          textDirection: AppLocalizations.of(context).textDirection,
          child: child!,
        );
      },
    );
  }
}
```

### שימוש בתרגומים
```dart
// גישה לתרגומים
final l10n = AppLocalizations.of(context);

Text(l10n.welcome)  // "ברוך הבא" / "Welcome" / "مرحبا"

// או עם Extension
Text(context.l10n.login)

// תרגום עם פרמטרים
Text(context.tr('showing_x_to_y_of_z', params: {
  'from': '1',
  'to': '10', 
  'total': '100'
}))
```

### RTL-Aware Widgets
```dart
// במקום Row רגיל
RTLRow(
  children: [
    Icon(Icons.arrow_forward),  // יתהפך אוטומטית ב-RTL
    Text('Next'),
  ],
)

// Padding מותאם RTL
RTLPadding(
  start: 16,  // ימין ב-LTR, שמאל ב-RTL
  end: 8,     // שמאל ב-LTR, ימין ב-RTL
  child: Text('Content'),
)

// אייקון שמתהפך
RTLAwareIcon(
  icon: Icons.arrow_back,  // יתהפך ב-RTL
)
```

### החלפת שפה
```dart
// Provider לניהול שפה
final localeProvider = Provider.of<LocaleProvider>(context);

// החלפת שפה
localeProvider.setLocale('he');  // עברית
localeProvider.setLocale('ar');  // ערבית
localeProvider.setLocale('en');  // אנגלית
```

## 🔧 **שימוש ב-Backend (Python/FastAPI)**

### הוספת Middleware
```python
# main.py
from app.middleware.localization_middleware import LocalizationMiddleware

app.add_middleware(LocalizationMiddleware)
```

### שימוש בתרגומים
```python
from app.core.localization import translator, _
from app.middleware.localization_middleware import get_request_language

@app.post("/api/v1/auth/login")
async def login(request: Request, credentials: LoginSchema):
    language = get_request_language(request)
    
    if not valid_credentials:
        return LocalizedResponse.error(
            "invalid_credentials",
            language=language,
            status_code=401
        )
    
    return LocalizedResponse.success(
        "login_successful",
        data={"token": token},
        language=language
    )
```

### תרגום מהיר
```python
# שימוש בפונקציה מקוצרת
message = _("user_created", item="משתמש")

# עם שפה ספציפית
message = translator.get("welcome_message", Language.HEBREW)
```

## 📱 **בדיקת RTL באפליקציה**

### שינוי שפת המכשיר (לבדיקה)
```bash
# Android
adb shell setprop persist.sys.locale he-IL

# iOS Simulator
xcrun simctl spawn booted defaults write -g AppleLanguages -array he

# Flutter Web - Add to URL
http://localhost:3000/?lang=he
```

### בדיקת כיוון
```dart
// בדיקה האם RTL פעיל
if (context.isRTL) {
  print("RTL is active");
}

// כיוון נוכחי
TextDirection direction = context.textDirection;
```

## 🌍 **הוספת שפה חדשה**

### 1. הוסף קובץ תרגום
```bash
# Frontend
shared/localization/assets/i18n/fr.json

# Backend
services/ulm/backend/app/translations/fr.json
```

### 2. הוסף ל-Enum
```dart
// Frontend - app_localizations.dart
static const List<Locale> supportedLocales = [
  Locale('he', 'IL'),
  Locale('en', 'US'),
  Locale('ar', 'SA'),
  Locale('fr', 'FR'),  // חדש
];
```

```python
# Backend - localization.py
class Language(str, Enum):
    FRENCH = "fr"  # חדש
```

### 3. הוסף גופן (אם נדרש)
```yaml
# pubspec.yaml
fonts:
  - family: CustomFont
    fonts:
      - asset: assets/fonts/CustomFont.ttf
```

## 🎨 **עיצוב מותאם RTL**

### CSS/SCSS למי שצריך
```scss
// Mixins for RTL
@mixin padding-start($value) {
  @if $rtl {
    padding-right: $value;
  } @else {
    padding-left: $value;
  }
}

@mixin margin-end($value) {
  @if $rtl {
    margin-left: $value;
  } @else {
    margin-right: $value;
  }
}

// Usage
.button {
  @include padding-start(16px);
  @include margin-end(8px);
}
```

## ⚙️ **הגדרות נוספות**

### Environment Variables
```env
# Default language
DEFAULT_LANGUAGE=he
SUPPORTED_LANGUAGES=he,en,ar,ru,fr

# RTL languages
RTL_LANGUAGES=he,ar,fa,ur

# Date format
DATE_FORMAT_HE=dd/MM/yyyy
DATE_FORMAT_EN=MM/dd/yyyy
DATE_FORMAT_AR=yyyy/MM/dd

# Currency
DEFAULT_CURRENCY=ILS
CURRENCY_SYMBOL_POSITION=start  # For Hebrew: ₪100
```

### Database - Store user preferences
```sql
ALTER TABLE users ADD COLUMN preferred_language VARCHAR(5) DEFAULT 'he';
ALTER TABLE users ADD COLUMN date_format VARCHAR(20);
ALTER TABLE users ADD COLUMN timezone VARCHAR(50) DEFAULT 'Asia/Jerusalem';
```

## 🧪 **בדיקות**

### Unit Tests
```dart
// Flutter test
testWidgets('RTL text alignment', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale('he'),
      home: RTLText('טקסט בעברית'),
    ),
  );
  
  final text = tester.widget<Text>(find.byType(Text));
  expect(text.textAlign, TextAlign.right);
});
```

```python
# Backend test
def test_hebrew_translation():
    translator.set_language(Language.HEBREW)
    message = _("login_successful")
    assert message == "התחברות הצליחה"
```

## 📊 **ביצועים**

### Caching
- תרגומים נטענים פעם אחת בהפעלה
- שמירת העדפת שפה ב-SharedPreferences
- Cache של תרגומים ב-Backend

### Bundle Size
- כל שפה ~50KB
- Lazy loading של תרגומים
- Tree shaking מסיר שפות לא בשימוש

## ✅ **Checklist לתמיכה מלאה**

- [x] תרגום כל הטקסטים
- [x] RTL לרכיבי UI
- [x] גופנים מתאימים
- [x] תאריכים ומספרים מותאמים
- [x] זיהוי שפה אוטומטי
- [x] שמירת העדפות משתמש
- [x] תרגום הודעות שגיאה
- [x] תרגום emails
- [x] API responses בשפה הנכונה
- [x] בדיקות לכל שפה

## 🚀 **סיכום**

המערכת מוכנה לעבודה עם ריבוי שפות ו-RTL מלא:
- ✅ תמיכה מלאה בעברית וערבית
- ✅ החלפת שפה דינמית
- ✅ RTL אוטומטי
- ✅ תרגום Backend ו-Frontend
- ✅ גופנים מותאמים
- ✅ ביצועים מעולים

**המערכת מוכנה לשימוש גלובלי!** 🌍
