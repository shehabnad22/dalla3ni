const { body, validationResult } = require('express-validator');

// Sanitize input
const sanitizeInput = (req, res, next) => {
  // Remove HTML tags and trim
  const sanitize = (obj) => {
    for (let key in obj) {
      if (typeof obj[key] === 'string') {
        obj[key] = obj[key]
          .replace(/<[^>]*>/g, '') // Remove HTML tags
          .trim()
          .substring(0, 10000); // Max length
      } else if (typeof obj[key] === 'object' && obj[key] !== null) {
        sanitize(obj[key]);
      }
    }
  };
  
  if (req.body) sanitize(req.body);
  if (req.query) sanitize(req.query);
  if (req.params) sanitize(req.params);
  
  next();
};

// Validation rules
const validateOrder = [
  body('customerId').isUUID().withMessage('customerId يجب أن يكون UUID صحيح'),
  body('itemsText').trim().isLength({ min: 5, max: 1000 }).withMessage('itemsText مطلوب (5-1000 حرف)'),
  body('deliveryAddress').trim().isLength({ min: 10, max: 500 }).withMessage('deliveryAddress مطلوب (10-500 حرف)'),
  body('estimatedPrice').optional().isFloat({ min: 0 }).withMessage('estimatedPrice يجب أن يكون رقم موجب'),
  body('area').optional().trim().isLength({ max: 100 }),
];

const validateDriverAccept = [
  body('driverId').isUUID().withMessage('driverId يجب أن يكون UUID صحيح'),
];

const validatePickup = [
  body('driverId').isUUID().withMessage('driverId يجب أن يكون UUID صحيح'),
  body('invoiceImageUrl').isURL().withMessage('invoiceImageUrl يجب أن يكون رابط صحيح'),
  body('actualPrice').optional().isFloat({ min: 0 }),
];

const validateDeliver = [
  body('driverId').isUUID().withMessage('driverId يجب أن يكون UUID صحيح'),
  body('deliveryCode').matches(/^\d{4}$/).withMessage('deliveryCode يجب أن يكون 4 أرقام'),
];

const validateComplete = [
  body('rating').isInt({ min: 1, max: 5 }).withMessage('rating مطلوب (1-5)'),
  body('comment').optional().trim().isLength({ max: 500 }),
];

// Validation error handler
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'خطأ في التحقق من البيانات',
      errors: errors.array(),
    });
  }
  next();
};

module.exports = {
  sanitizeInput,
  validateOrder,
  validateDriverAccept,
  validatePickup,
  validateDeliver,
  validateComplete,
  handleValidationErrors,
};

