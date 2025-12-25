# API Examples - دلّعني (Dalla3ni)

## 📝 Create Order Example

### Request
```http
POST /api/orders
Content-Type: application/json

{
  "customerId": "550e8400-e29b-41d4-a716-446655440000",
  "itemsText": "2 شاورما دجاج + بيبسي كبير من مطعم الشام",
  "estimatedPrice": 5.50,
  "deliveryAddress": "شارع الجامعة، عمارة 15، الطابق الثاني",
  "deliveryLat": 31.9539,
  "deliveryLng": 35.9106,
  "pickupAddress": "مطعم الشام - وسط البلد",
  "pickupLat": 31.9500,
  "pickupLng": 35.9200,
  "notes": "يرجى الاتصال عند الوصول",
  "area": "وسط البلد"
}
```

### Response
```json
{
  "success": true,
  "order": {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "status": "REQUESTED",
    "deliveryCode": "1234",
    "itemsText": "2 شاورما دجاج + بيبسي كبير من مطعم الشام",
    "estimatedPrice": 5.50,
    "deliveryFee": 1.5,
    "deliveryAddress": "شارع الجامعة، عمارة 15، الطابق الثاني",
    "createdAt": "2025-01-15T10:30:00.000Z"
  },
  "matching": {
    "success": true,
    "driversNotified": 3,
    "message": "تم إرسال الطلب إلى 3 سائق",
    "notifications": [
      {
        "driverId": "770e8400-e29b-41d4-a716-446655440002",
        "driverName": "أحمد محمد",
        "sentAt": "2025-01-15T10:30:01.000Z",
        "position": 1
      },
      {
        "driverId": "880e8400-e29b-41d4-a716-446655440003",
        "driverName": "خالد علي",
        "sentAt": "2025-01-15T10:30:02.000Z",
        "position": 2
      }
    ]
  }
}
```

## 🛵 Driver Accept Order

### Request
```http
POST /api/orders/660e8400-e29b-41d4-a716-446655440001/accept
Content-Type: application/json

{
  "driverId": "770e8400-e29b-41d4-a716-446655440002"
}
```

### Response
```json
{
  "success": true,
  "message": "تم قبول الطلب بنجاح",
  "order": {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "status": "ASSIGNED",
    "deliveryCode": "1234",
    "itemsText": "2 شاورما دجاج + بيبسي كبير من مطعم الشام",
    "deliveryAddress": "شارع الجامعة، عمارة 15، الطابق الثاني",
    "pickupAddress": "مطعم الشام - وسط البلد",
    "estimatedPrice": 5.50,
    "deliveryFee": 1.5,
    "customer": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "محمد أحمد",
      "phone": "0791234567"
    }
  }
}
```

## 📸 Driver Pickup (Upload Invoice)

### Request
```http
POST /api/orders/660e8400-e29b-41d4-a716-446655440001/pickup
Content-Type: application/json

{
  "driverId": "770e8400-e29b-41d4-a716-446655440002",
  "invoiceImageUrl": "https://storage.dalla3ni.com/invoices/invoice_123.jpg",
  "actualPrice": 5.75
}
```

### Response
```json
{
  "success": true,
  "message": "تم تأكيد استلام الطلب",
  "order": {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "status": "PICKED_UP",
    "invoiceImageUrl": "https://storage.dalla3ni.com/invoices/invoice_123.jpg",
    "pickedAt": "2025-01-15T10:45:00.000Z"
  }
}
```

## 🚚 Driver Deliver (Enter Delivery Code)

### Request
```http
POST /api/orders/660e8400-e29b-41d4-a716-446655440001/deliver
Content-Type: application/json

{
  "driverId": "770e8400-e29b-41d4-a716-446655440002",
  "deliveryCode": "1234",
  "podImageUrl": "https://storage.dalla3ni.com/pod/pod_123.jpg"
}
```

### Response
```json
{
  "success": true,
  "message": "تم تأكيد التسليم - في انتظار تقييم الزبون",
  "order": {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "status": "DELIVERED",
    "deliveredAt": "2025-01-15T11:00:00.000Z"
  }
}
```

## ⭐ Complete Order (Rating Required)

### Request
```http
POST /api/orders/660e8400-e29b-41d4-a716-446655440001/complete
Content-Type: application/json

{
  "rating": 5,
  "comment": "توصيل سريع وممتاز!"
}
```

### Response (if rating missing)
```json
{
  "success": false,
  "message": "يجب إرسال التقييم لإغلاق الطلب (rating: 1-5)"
}
```

### Response (success)
```json
{
  "success": true,
  "message": "تم إكمال الطلب بنجاح",
  "order": {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "status": "COMPLETED",
    "completedAt": "2025-01-15T11:05:00.000Z",
    "driverShare": 5.75,
    "commissionAmount": 2500,
    "rating": 5
  }
}
```

## ⚠️ Dispute Order

### Request
```http
POST /api/orders/660e8400-e29b-41d4-a716-446655440001/dispute
Content-Type: application/json

{
  "reason": "الزبون رفض استلام الطلب",
  "reportedBy": "driver"
}
```

### Response
```json
{
  "success": true,
  "message": "تم تسجيل البلاغ وسيتم مراجعته من قبل الإدارة",
  "order": {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "status": "DISPUTE",
    "disputeFlag": true
  }
}
```

---

## 📱 Driver App Screenshots

### Incoming Request Dialog
```
┌─────────────────────────────────────┐
│  🔔 طلب جديد!              [12]     │
├─────────────────────────────────────┤
│  2 شاورما دجاج + بيبسي كبير        │
│                                      │
│  🏪 من: مطعم الشام - وسط البلد      │
│  📍 إلى: شارع الجامعة، عمارة 15    │
│  💰 السعر التقديري: 5.50 ل.س      │
│                                      │
│  [رفض]          [آخذ ✓]            │
└─────────────────────────────────────┘
```

### Pickup Screen
```
┌─────────────────────────────────────┐
│  📦 استلام الطلب                    │
├─────────────────────────────────────┤
│  🏪 مطعم الشام - وسط البلد          │
│  📞 0791234567                      │
│                                      │
│  [الملاحة إلى المحل]                │
│                                      │
│  📸 [رفع صورة الفاتورة (مطلوب)]     │
│                                      │
│  ⚠️ يجب رفع صورة الفاتورة قبل      │
│     المتابعة                        │
└─────────────────────────────────────┘
```

### Deliver Screen
```
┌─────────────────────────────────────┐
│  🚚 التوصيل                         │
├─────────────────────────────────────┤
│  📍 شارع الجامعة، عمارة 15         │
│  👤 محمد أحمد                       │
│  📞 0791234567                      │
│                                      │
│  [الاتصال]  [الملاحة]               │
│                                      │
│  أدخل كود التسليم (4 أرقام):        │
│  [1] [2] [3] [4]                    │
│                                      │
│  [تأكيد التسليم]                    │
└─────────────────────────────────────┘
```

