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

## 🚀 البدء السريع

### Backend
```bash
cd backend
npm install
# Copy env.example to .env and configure
npm run dev
```

### Mobile App
```bash
cd mobile-app
flutter pub get
flutter run
```

### Admin Dashboard
```bash
cd admin-dashboard
npm install
npm start
```

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
- [ ] Stores (stores_enabled=false)
- [ ] Centers (centers_enabled=false)

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
stores_enabled: false      // متاجر - معطّل
centers_enabled: false     // مراكز - معطّل
text_orders: true          // طلبات نصية - مفعّل
invoice_upload: true       // رفع الفواتير - مفعّل
delivery_code: true        // كود التسليم - مفعّل
ratings: true              // التقييمات - مفعّل
settlements: true          // التسويات - مفعّل
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

| Role | Description |
|------|-------------|
| Customer | زبون يطلب التوصيل |
| Driver | سائق ميتور |
| Admin | مدير النظام |

---

**Dalla3ni © 2025**
