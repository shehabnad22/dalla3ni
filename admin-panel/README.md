# لوحة تحكم دلّعني - Admin Panel

## ✅ تم الربط مع API الحقيقي

تم ربط جميع الصفحات مع API الحقيقي وإزالة البيانات التجريبية.

## 🔐 نظام المصادقة

- عند فتح الواجهة لأول مرة، سيظهر نموذج تسجيل الدخول
- استخدم بيانات Admin للدخول (البريد الإلكتروني وكلمة المرور)
- Token يتم حفظه تلقائياً في localStorage
- عند انتهاء صلاحية Token، سيتم إعادة توجيهك لتسجيل الدخول

## 📡 Endpoints المستخدمة

### المصادقة
- `POST /api/auth/admin/login` - تسجيل دخول Admin

### البيانات
- `GET /api/admin/stats` - إحصائيات عامة
- `GET /api/admin/users?sort=&search=` - المستخدمين
- `GET /api/admin/drivers` - السائقين
- `GET /api/admin/orders?status=` - الطلبات
- `GET /api/admin/invoices?location=` - الفواتير
- `GET /api/admin/tracking` - تتبع الميتور
- `GET /api/admin/statistics` - الإحصائيات
- `GET /api/admin/delayed` - المتأخرين

## ⚙️ الإعدادات

### تغيير رابط API

افتح `app.js` وعدّل السطر التالي:

```javascript
const API_BASE_URL = 'http://localhost:3000/api'; // غيّر هذا
```

لإنتاج:
```javascript
const API_BASE_URL = 'https://api.dalla3ni.com/api';
```

## 🚀 كيفية الاستخدام

1. تأكد أن الـ Backend يعمل على `http://localhost:3000`
2. افتح `index.html` في المتصفح
3. سجل دخول باستخدام بيانات Admin
4. استخدم القائمة الجانبية للتنقل

## 📝 ملاحظات

- جميع البيانات الآن تأتي من قاعدة البيانات الحقيقية
- لا توجد بيانات تجريبية
- التصنيف التلقائي للفواتير يعمل حسب `pickupAddress`
- حساب المتأخرين يعتمد على الوقت المتوقع (30 دقيقة من التعيين)

## 🔧 استكشاف الأخطاء

إذا ظهرت أخطاء:
1. تأكد أن الـ Backend يعمل
2. تحقق من رابط API في `app.js`
3. افتح Console في المتصفح (F12) لرؤية الأخطاء
4. تأكد من وجود Token صالح
