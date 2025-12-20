# 📱 دليل رفع التطبيق إلى Google Play Store

## 📋 نظرة عامة

هذا الدليل يوضح خطوات رفع تطبيق Dalla3ni إلى Google Play Store.

---

## 🎯 المتطلبات الأساسية

1. **حساب Google Play Developer**
   - رسوم لمرة واحدة: $25
   - رابط: https://play.google.com/console

2. **ملف AAB (Android App Bundle)**
   - الموقع: `builds/dalla3ni-release.aab`
   - يجب أن يكون موقّعاً

3. **الأصول المطلوبة:**
   - App icon (512x512 px)
   - Feature graphic (1024x500 px)
   - Screenshots (2-8 صور)
   - Short description (80 حرف)
   - Full description (4000 حرف)

---

## 📝 الخطوات التفصيلية

### الخطوة 1: إنشاء حساب Google Play Developer

1. اذهب إلى: https://play.google.com/console
2. اضغط "Get started"
3. ادفع $25 (رسوم لمرة واحدة)
4. أكمل معلومات الحساب:
   - الاسم
   - البريد الإلكتروني
   - معلومات الدفع
   - معلومات المطور

### الخطوة 2: إنشاء تطبيق جديد

1. في Google Play Console، اضغط "Create app"
2. املأ المعلومات:
   - **App name**: "دلّعني" (Dalla3ni)
   - **Default language**: Arabic (العربية)
   - **App or game**: App
   - **Free or paid**: Free
3. اضغط "Create app"

### الخطوة 3: إعداد Store Listing

#### 3.1 App Details

**Short description (80 حرف):**
```
خدمة التوصيل السريع - اطلب أي شيء ونوصله لك خلال دقائق
```

**Full description (4000 حرف):**
```
دلّعني - خدمة التوصيل السريع

تطبيق دلّعني يوفر لك خدمة توصيل سريعة وآمنة لأي شيء تحتاجه. سواء كان طعام، مشتريات، أو أي منتج آخر، نحن هنا لنوصله إليك في أسرع وقت ممكن.

المميزات:
✅ توصيل سريع وآمن
✅ سائقين محترفين ومدربين
✅ تتبع الطلب في الوقت الفعلي
✅ دفع آمن وسهل
✅ تقييم السائقين

كيف يعمل التطبيق:
1. سجّل حساب جديد
2. اكتب طلبك
3. اختر عنوان التوصيل
4. انتظر وصول السائق
5. استلم طلبك

انضم إلينا اليوم واستمتع بخدمة توصيل سريعة وموثوقة!
```

#### 3.2 Graphics Assets

**App icon:**
- الحجم: 512x512 px
- التنسيق: PNG (بدون شفافية)
- الموقع: `assets/app_icon_512.png`

**Feature graphic:**
- الحجم: 1024x500 px
- التنسيق: PNG أو JPG
- الموقع: `assets/feature_graphic.png`

**Screenshots:**
- الحد الأدنى: 2 صورة
- الحد الأقصى: 8 صور
- الأحجام الموصى بها:
  - Phone: 1080x1920 px (9:16)
  - Tablet: 1200x1920 px
- التنسيق: PNG أو JPG

**Phone screenshots (مثال):**
1. شاشة البداية (Splash Screen)
2. شاشة اختيار الدور (Onboarding)
3. شاشة إنشاء طلب (Create Order)
4. شاشة تتبع الطلب (Order Tracking)
5. شاشة السائق (Driver App)

#### 3.3 Categorization

- **App category**: Food & Drink أو Shopping
- **Tags**: توصيل، توصيل سريع، طلبات
- **Content rating**: Complete questionnaire

### الخطوة 4: إعداد Pricing & Distribution

1. **Pricing:**
   - Free

2. **Countries/regions:**
   - اختر الدول (الأردن على الأقل)

3. **Device categories:**
   - Phones
   - Tablets (اختياري)

4. **Program policies:**
   - اقرأ واقبل جميع السياسات

### الخطوة 5: رفع AAB

1. اذهب إلى "Production" → "Create new release"
2. اضغط "Upload" واختر `builds/dalla3ni-release.aab`
3. املأ "Release notes":
   ```
   الإصدار الأول من تطبيق دلّعني
   
   - تسجيل زبائن وسائقين
   - إنشاء وتتبع الطلبات
   - نظام التقييمات
   - لوحة تحكم إدارية
   ```
4. اضغط "Save"

### الخطوة 6: Content Rating

1. اذهب إلى "Content rating"
2. أجب على الأسئلة:
   - Does your app contain user-generated content? → No
   - Does your app allow users to communicate with each other? → No
   - Does your app allow users to share content? → No
   - Does your app contain ads? → No (أو Yes إذا كان لديك إعلانات)
3. احصل على شهادة التصنيف

### الخطوة 7: Privacy Policy

**مطلوب:**
- رابط لسياسة الخصوصية
- يجب أن يكون متاحاً على الويب

**مثال:**
```
https://dalla3ni.com/privacy-policy
```

**محتوى سياسة الخصوصية الأساسي:**
- ما هي البيانات التي نجمعها
- كيف نستخدم البيانات
- مع من نشارك البيانات
- حقوق المستخدم
- كيفية الاتصال بنا

### الخطوة 8: App Access (إذا كان مطلوباً)

إذا كان التطبيق يتطلب تسجيل دخول:
- وضّح كيفية الحصول على حساب
- أو وفر حساب تجريبي

### الخطوة 9: Review & Submit

1. راجع جميع الأقسام:
   - ✅ Store listing
   - ✅ App content
   - ✅ Pricing & distribution
   - ✅ Content rating
   - ✅ Target audience
   - ✅ Data safety
   - ✅ App access

2. تأكد من:
   - جميع الحقول مكتملة
   - الصور والأيقونات مرفوعة
   - AAB مرفوع
   - سياسة الخصوصية متاحة

3. اضغط "Submit for review"

---

## ⏱️ Timeline

- **Review time**: 1-3 أيام (عادة)
- **First review**: قد يستغرق أسبوعاً
- **Updates**: عادة 1-2 أيام

---

## 🔄 تحديثات التطبيق

### رفع تحديث جديد:

1. اذهب إلى "Production" → "Create new release"
2. ارفع AAB الجديد
3. اكتب Release notes
4. اضغط "Review release"
5. اضغط "Start rollout to Production"

**ملاحظة:** استخدم نفس Keystore لكل التحديثات!

---

## 📊 Monitoring

بعد النشر، راقب:
- **Statistics**: عدد التحميلات، التقييمات
- **Reviews**: رد على التقييمات
- **Crashes**: راجع تقارير الأعطال
- **Performance**: راجع أداء التطبيق

---

## ✅ Checklist قبل الإرسال

- [ ] حساب Google Play Developer نشط
- [ ] AAB مرفوع وموقّع
- [ ] App icon (512x512) مرفوع
- [ ] Feature graphic (1024x500) مرفوع
- [ ] Screenshots (2-8) مرفوعة
- [ ] Short description مكتمل
- [ ] Full description مكتمل
- [ ] Content rating مكتمل
- [ ] Privacy policy متاح
- [ ] جميع الأقسام مكتملة
- [ ] تم المراجعة النهائية

---

## 🆘 حل المشاكل

### مشكلة: "Upload failed"
- تأكد من أن AAB موقّع بشكل صحيح
- تحقق من حجم الملف (يجب أن يكون < 150 MB)

### مشكلة: "Content rating required"
- أكمل استبيان Content rating
- انتظر الحصول على الشهادة

### مشكلة: "Privacy policy required"
- أضف رابط سياسة الخصوصية
- تأكد من أن الرابط يعمل

---

**جاهز للرفع! 🚀**

بعد اكتمال جميع الخطوات، سيتم مراجعة التطبيق وستحصل على إشعار عند الموافقة.

