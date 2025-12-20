# دلّعني - Dalla3ni 🛵

تطبيق توصيل سريع يربط الزبائن بسائقي الميتور مباشرة.

## 📁 هيكل المشروع

```
Dalla3ni/
├── backend/              # Node.js + Express + PostgreSQL
│   ├── src/
│   │   ├── config/       # Database, Feature Flags
│   │   ├── models/       # Sequelize Models
│   │   ├── routes/       # API Routes
│   │   ├── services/     # Business Logic
│   │   └── jobs/         # Scheduled Jobs
│   └── package.json
│
├── mobile-app/           # Flutter (Customer + Driver)
│   ├── lib/
│   │   ├── config/       # Feature Flags
│   │   ├── main.dart     # Customer App Entry
│   │   ├── driver_app.dart
│   │   └── splash_screen.dart
│   ├── android/          # Android Config + Keystore
│   └── pubspec.yaml
│
├── admin-dashboard/      # React Admin Panel
│   ├── src/
│   │   ├── components/   # Sidebar, etc.
│   │   └── pages/        # Dashboard, Orders, Drivers...
│   └── package.json
│
└── env.example           # Environment Variables Template
```

## 📦 Deliverables

### APKs
**Location**: `builds/` (after running build script)

**Build**:
```bash
# Linux/Mac
./scripts/build-apks.sh

# Windows
scripts\build-apks.bat
```

**Output**:
- `builds/dalla3ni-customer-debug.apk`
- `builds/dalla3ni-driver-debug.apk`

### Postman Collection
**File**: `backend/postman_collection.json`

**Import**: Postman → Import → File

### Swagger/OpenAPI
**URL**: `http://localhost:3000/api-docs`

**Production**: `https://api.dalla3ni.com/api-docs`

---

## 🚀 البدء السريع

### المتطلبات الأساسية
- Node.js 18+ 
- PostgreSQL 14+
- Flutter 3.0+
- Git

### 1. إعداد قاعدة البيانات

```bash
# إنشاء قاعدة بيانات PostgreSQL
createdb dalla3ni

# أو عبر psql
psql -U postgres
CREATE DATABASE dalla3ni;
```

### 2. إعداد Backend

```bash
cd backend
npm install

# نسخ ملف البيئة
cp ../env.example .env

# تعديل ملف .env وإضافة:
# - DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
# - JWT_SECRET
# - COMMISSION_AMOUNT=2500
# - STORES_ENABLED=false

# تشغيل Backend
npm run dev
```

الـ Backend سيعمل على: `http://localhost:3000`

### 3. إعداد Mobile App

```bash
cd mobile-app
flutter pub get

# إضافة الأيقونات (راجع ASSETS_PLACEHOLDER.md)
# ثم:
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create

# تشغيل التطبيق
flutter run
```

### 4. إعداد Admin Dashboard

```bash
cd admin-dashboard
npm install

# إنشاء ملف .env
echo "REACT_APP_API_URL=http://localhost:3000/api" > .env

# تشغيل Dashboard
npm start
```

الـ Dashboard سيعمل على: `http://localhost:3000` (أو البورت المحدد)

## 📋 قائمة المهام

### ✅ مكتمل
- [x] Onboarding (Customer / Driver)
- [x] تسجيل الزبون (اسم + رقم + OTP)
- [x] تسجيل السائق (كامل مع الوثائق)
- [x] شاشة كتابة الطلب النصي
- [x] نظام Matching للسائقين
- [x] رفع صورة الفاتورة
- [x] كود التسليم (4 أرقام)
- [x] تقييم السائق (إجباري)
- [x] محفظة السائق
- [x] نظام التسويات
- [x] حظر السائق عند الديون
- [x] Admin Dashboard كامل
- [x] Feature Flags
- [x] Splash Screen

### 🔄 قيد التطوير
- [ ] Push Notifications (Firebase)
- [ ] Live Tracking
- [ ] Chat

### ❌ معطّل
- [ ] Stores (stores_enabled=false) - سيُفعّل في المرحلة الثانية
- [ ] StoreOwner Registration - مقفول مع رسالة "قريباً"

## 🗄️ قاعدة البيانات

| Table | Description |
|-------|-------------|
| Users | المستخدمين (customer/driver/admin) |
| Drivers | بيانات السائقين |
| Orders | الطلبات |
| Reviews | التقييمات |
| Wallets | محافظ السائقين |
| Settlements | التسويات |

## 🔧 Feature Flags

```javascript
stores_enabled: false      // متاجر - معطّل (قابل للتعديل من Admin)
commission_amount: 2500    // قيمة العمولة (قابل للتعديل من Admin)
text_orders: true          // طلبات نصية - مفعّل
invoice_upload: true       // رفع الفواتير - مفعّل
delivery_code: true        // كود التسليم - مفعّل
ratings: true              // التقييمات - مفعّل
settlements: true          // التسويات - مفعّل
```

### إعداد Feature Flags

يمكن تعديل Feature Flags من ملف `.env` في مجلد `backend/`:

```env
STORES_ENABLED=false
COMMISSION_AMOUNT=2500
```

## 🌿 Git Branches

- `main` - Production
- `staging` - Testing
- `dev` - Development

## 📱 Build APK

```bash
cd mobile-app
flutter build apk --release
```

## 👥 الأدوار

| Role | Description | Status |
|------|-------------|--------|
| Customer | زبون يطلب التوصيل | ✅ مفعّل |
| Driver | سائق ميتور (PENDING_REVIEW عند التسجيل) | ✅ مفعّل |
| StoreOwner | صاحب متجر | ❌ معطّل (قريباً) |
| Admin | مدير النظام | ✅ مفعّل |

## 📝 Onboarding Flow

### Customer Flow
1. اختيار دور "زبون"
2. إدخال الاسم ورقم الهاتف
3. استلام OTP عبر WhatsApp API
4. التحقق من OTP وإنشاء الحساب

### Driver Flow
1. اختيار دور "سائق ميتور"
2. ملء النموذج:
   - البيانات الشخصية (الاسم، رقم الهاتف)
   - الوثائق (صورة الهوية، صورة الدراجة)
   - رقم اللوحة وموديل الدراجة
   - اختيار المناطق (area_tags)
   - ساعات العمل (availability_hours)
   - الموافقة على الشروط
3. إرسال الطلب → `accountStatus = PENDING_REVIEW`
4. انتظار موافقة الإدارة

### StoreOwner Flow
- ❌ معطّل حالياً
- عند الضغط على "صاحب متجر" → رسالة: "قريباً"

## 🔐 Security Features

- JWT Authentication (Access + Refresh tokens)
- Rate Limiting (Auth: 5/15min, Standard: 100/15min)
- Input Validation & Sanitization
- HTTPS Ready (Helmet configured)
- Daily Database Backup
- Audit Logs for all critical events

## 📊 Admin Dashboard

- **Orders**: Filter by date, driver, status, invoice preview
- **Drivers**: KYC status, ratings, block/unblock, settlements
- **Reconciliation**: Pending settlements, Mark as Paid, CSV export
- **Disputes**: Evidence viewer, resolution (refund/penalty/no-action)
- **Settings**: Commission amount, feature flags, settlement config

## 🧪 Testing

### Seed Demo Data
```bash
cd backend
npm run seed
```

Creates:
- 1 Admin user
- 5 Customers
- 10 Drivers (3 approved)
- 30 Demo Orders
- 5 Settlements

### Admin Credentials
- Email: `admin@dalla3ni.com`
- Password: `Admin123!`

---

**Dalla3ni © 2025**
