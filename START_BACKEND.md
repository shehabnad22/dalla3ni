# 🚀 كيفية تشغيل الـ Backend

## الخطوات:

### 1. افتح Terminal/Command Prompt

### 2. اذهب إلى مجلد Backend:
```bash
cd C:\Users\PC\Desktop\shehab\Dalla3ni\backend
```

### 3. تأكد من تثبيت المكتبات:
```bash
npm install
```

### 4. شغّل الـ Backend:
```bash
npm start
```

أو إذا كان لديك script مختلف:
```bash
node src/index.js
```

### 5. يجب أن ترى رسالة مثل:
```
Server is running on port 3000
Database connected successfully
```

## ✅ للتحقق من أن Backend يعمل:

افتح المتصفح واذهب إلى:
```
http://localhost:3000/health
```

يجب أن ترى:
```json
{
  "status": "ok",
  "timestamp": "...",
  "uptime": ...,
  "message": "Backend is running"
}
```

## ⚠️ إذا ظهرت أخطاء:

1. **خطأ في قاعدة البيانات:**
   - تأكد من أن PostgreSQL يعمل
   - تحقق من ملف `.env` في مجلد `backend`

2. **خطأ في المنفذ (Port 3000):**
   - تأكد أن لا يوجد تطبيق آخر يستخدم Port 3000
   - يمكنك تغيير المنفذ في ملف `.env` أو `src/index.js`

3. **خطأ في المكتبات:**
   - احذف `node_modules` و `package-lock.json`
   - ثم شغّل `npm install` مرة أخرى

## 📝 ملاحظات:

- يجب أن يبقى Terminal مفتوحاً طالما Backend يعمل
- إذا أغلقت Terminal، سيتوقف Backend
- للعمل في الخلفية، استخدم `pm2` أو `nodemon`

