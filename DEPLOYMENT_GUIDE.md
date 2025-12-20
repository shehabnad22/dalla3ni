# 🚀 دليل النشر - Dalla3ni Deployment Guide

## 📋 نظرة عامة

هذا الدليل يوضح كيفية نشر تطبيق Dalla3ni في بيئة الإنتاج.

---

## 🖥️ 1. نشر Backend API

### الخيار 1: VPS/Cloud Server (Ubuntu/Debian)

#### المتطلبات
- Ubuntu 20.04+ أو Debian 11+
- Node.js 18+
- PostgreSQL 14+
- Nginx
- PM2 (لإدارة العمليات)

#### خطوات النشر

```bash
# 1. تحديث النظام
sudo apt update && sudo apt upgrade -y

# 2. تثبيت Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 3. تثبيت PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# 4. تثبيت Nginx
sudo apt install -y nginx

# 5. تثبيت PM2
sudo npm install -g pm2

# 6. إنشاء مستخدم للتطبيق
sudo adduser dalla3ni
sudo su - dalla3ni

# 7. استنساخ المشروع
git clone <repository-url> Dalla3ni
cd Dalla3ni/backend

# 8. تثبيت المتطلبات
npm install --production

# 9. إعداد قاعدة البيانات
sudo -u postgres createdb dalla3ni
sudo -u postgres psql dalla3ni -c "CREATE USER dalla3ni_user WITH PASSWORD 'secure_password';"
sudo -u postgres psql dalla3ni -c "GRANT ALL PRIVILEGES ON DATABASE dalla3ni TO dalla3ni_user;"

# 10. إعداد متغيرات البيئة
cp .env.example .env
nano .env
```

**ملف `.env` للإنتاج:**
```env
NODE_ENV=production
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=dalla3ni
DB_USER=dalla3ni_user
DB_PASSWORD=secure_password
JWT_SECRET=your_super_secret_jwt_key_here
JWT_REFRESH_SECRET=your_super_secret_refresh_key_here
COMMISSION_AMOUNT=2500
STORES_ENABLED=false
```

```bash
# 11. تشغيل migrations
npm run migrate

# 12. تشغيل seed (اختياري)
npm run seed

# 13. تشغيل التطبيق باستخدام PM2
pm2 start src/index.js --name dalla3ni-backend
pm2 save
pm2 startup
# اتبع التعليمات المعروضة

# 14. إعداد Nginx كـ Reverse Proxy
sudo nano /etc/nginx/sites-available/dalla3ni-api
```

**إعداد Nginx:**
```nginx
server {
    listen 80;
    server_name api.dalla3ni.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# تفعيل الموقع
sudo ln -s /etc/nginx/sites-available/dalla3ni-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 15. إعداد SSL (Let's Encrypt)
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d api.dalla3ni.com
```

### الخيار 2: Heroku

```bash
# 1. تثبيت Heroku CLI
# https://devcenter.heroku.com/articles/heroku-cli

# 2. تسجيل الدخول
heroku login

# 3. إنشاء تطبيق
heroku create dalla3ni-backend

# 4. إضافة PostgreSQL
heroku addons:create heroku-postgresql:hobby-dev

# 5. إعداد متغيرات البيئة
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=your_secret
heroku config:set JWT_REFRESH_SECRET=your_refresh_secret
heroku config:set COMMISSION_AMOUNT=2500
heroku config:set STORES_ENABLED=false

# 6. النشر
git push heroku main

# 7. تشغيل migrations
heroku run npm run migrate
```

---

## 🖥️ 2. نشر Admin Dashboard

### الخيار 1: Netlify

```bash
# 1. بناء التطبيق
cd admin-dashboard
npm run build

# 2. تثبيت Netlify CLI
npm install -g netlify-cli

# 3. النشر
netlify deploy --prod --dir=build
```

### الخيار 2: Vercel

```bash
# 1. بناء التطبيق
cd admin-dashboard
npm run build

# 2. تثبيت Vercel CLI
npm install -g vercel

# 3. النشر
vercel --prod
```

### الخيار 3: Nginx على VPS

```bash
# 1. بناء التطبيق
cd admin-dashboard
npm run build

# 2. نسخ الملفات
sudo mkdir -p /var/www/dalla3ni-admin
sudo cp -r build/* /var/www/dalla3ni-admin/

# 3. إعداد Nginx
sudo nano /etc/nginx/sites-available/dalla3ni-admin
```

**إعداد Nginx:**
```nginx
server {
    listen 80;
    server_name admin.dalla3ni.com;
    root /var/www/dalla3ni-admin;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

```bash
# تفعيل الموقع
sudo ln -s /etc/nginx/sites-available/dalla3ni-admin /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# إعداد SSL
sudo certbot --nginx -d admin.dalla3ni.com
```

**تحديث API URL في Admin Dashboard:**

قبل البناء، حدّث `src/pages/*.jsx`:
```javascript
// من
const API_URL = 'http://localhost:3000/api';

// إلى
const API_URL = 'https://api.dalla3ni.com/api';
```

---

## 📱 3. رفع التطبيق إلى Google Play

راجع `GOOGLE_PLAY_GUIDE.md` للتفاصيل الكاملة.

**ملخص سريع:**
1. إنشاء حساب Google Play Developer ($25)
2. إنشاء تطبيق جديد
3. رفع `dalla3ni-release.aab`
4. إكمال Store Listing
5. إرسال للمراجعة

---

## 🔒 4. الأمان

### SSL/HTTPS
- استخدم Let's Encrypt (مجاني)
- أو شهادة SSL مدفوعة
- فرض HTTPS في Nginx

### Firewall
```bash
# إعداد UFW
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### Database Security
- استخدام كلمات مرور قوية
- تقييد الوصول من localhost فقط
- نسخ احتياطية منتظمة

---

## 📊 5. المراقبة والصيانة

### PM2 Monitoring
```bash
pm2 monit
pm2 logs dalla3ni-backend
```

### Database Backups
```bash
# إضافة إلى crontab
0 2 * * * /path/to/backup-script.sh
```

### Logs
```bash
# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# PM2 logs
pm2 logs dalla3ni-backend
```

---

## ✅ Checklist قبل الإطلاق

- [ ] Backend يعمل على الإنتاج
- [ ] Admin Dashboard منشور
- [ ] SSL certificates مثبتة
- [ ] Database migrations منفذة
- [ ] Environment variables محدثة
- [ ] API URLs محدثة في التطبيق
- [ ] النسخ الاحتياطية مبرمجة
- [ ] المراقبة مفعلة
- [ ] الاختبارات على الإنتاج مكتملة

---

**جاهز للنشر! 🚀**

