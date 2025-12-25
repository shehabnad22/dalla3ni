require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const cron = require('node-cron');
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');
const { sequelize } = require('./models');
const { runEndOfDayCheck } = require('./jobs/endOfDayCheck');
const { standardRateLimiter, authRateLimiter } = require('./middleware/rateLimiter');
const { sanitizeInput } = require('./middleware/validator');
const path = require('path');
const fs = require('fs');
const multer = require('multer');

const app = express();

// Security Middleware
app.use(helmet({
  contentSecurityPolicy: false, // Allow inline scripts for Swagger
}));

// CORS Configuration
const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',').map(origin => origin.trim())
  : ['*']; // Allow all origins by default (can be restricted later)

app.use(cors({
  origin: allowedOrigins.includes('*')
    ? '*'
    : (origin, callback) => {
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Logging
app.use(morgan('dev'));

// Body Parser
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Static Files & Uploads Setup
const uploadsDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir);
}
if (!fs.existsSync(path.join(uploadsDir, 'drivers'))) {
  fs.mkdirSync(path.join(uploadsDir, 'drivers'));
}
if (!fs.existsSync(path.join(uploadsDir, 'orders'))) {
  fs.mkdirSync(path.join(uploadsDir, 'orders'));
}

app.use('/uploads', express.static(uploadsDir));

// Input Sanitization
app.use(sanitizeInput);

// Rate Limiting
// Skip rate limiting for admin login to avoid blocking
app.use('/api/auth', (req, res, next) => {
  // Skip rate limiting for admin login endpoint
  if (req.path === '/admin/login' || req.originalUrl.includes('/admin/login')) {
    return next();
  }
  // Apply rate limiting for other auth endpoints
  return authRateLimiter(req, res, next);
});
app.use('/api', standardRateLimiter); // General API endpoints

// Swagger Configuration
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Dalla3ni API',
      version: '1.0.0',
      description: 'API documentation for Dalla3ni delivery service',
      contact: {
        name: 'Dalla3ni Support',
        email: 'support@dalla3ni.com',
      },
      license: {
        name: 'MIT',
        url: 'https://opensource.org/licenses/MIT',
      },
    },
    servers: [
      {
        url: process.env.API_URL || (process.env.NODE_ENV === 'production' ? 'https://api.dalla3ni.com' : 'http://localhost:3000'),
        description: process.env.NODE_ENV === 'production' ? 'Production server' : 'Development server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'JWT Authorization header using the Bearer scheme. Example: "Authorization: Bearer {token}"',
        },
      },
      schemas: {
        Order: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            customerId: { type: 'string', format: 'uuid' },
            driverId: { type: 'string', format: 'uuid', nullable: true },
            itemsText: { type: 'string' },
            estimatedPrice: { type: 'number', format: 'float' },
            deliveryFee: { type: 'number', format: 'float' },
            commissionAmount: { type: 'number', format: 'float' },
            deliveryCode: { type: 'string', pattern: '^\\d{4}$' },
            status: {
              type: 'string',
              enum: ['REQUESTED', 'ASSIGNED', 'PICKED_UP', 'EN_ROUTE', 'DELIVERED', 'COMPLETED', 'CANCELED', 'DISPUTE']
            },
            invoiceImageUrl: { type: 'string', format: 'uri', nullable: true },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        Driver: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            userId: { type: 'string', format: 'uuid' },
            plateNumber: { type: 'string' },
            rating: { type: 'number', format: 'float' },
            totalDeliveries: { type: 'integer' },
            isAvailable: { type: 'boolean' },
            isApproved: { type: 'boolean' },
            accountStatus: { type: 'string', enum: ['PENDING_REVIEW', 'APPROVED', 'REJECTED'] },
            pendingSettlement: { type: 'number', format: 'float' },
          },
        },
      },
    },
    tags: [
      { name: 'Auth', description: 'Authentication endpoints' },
      { name: 'Orders', description: 'Order management' },
      { name: 'Drivers', description: 'Driver management' },
      { name: 'Admin', description: 'Admin operations' },
    ],
  },
  apis: ['./src/routes/*.js'],
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Routes
app.get('/', (req, res) => {
  res.json({
    message: 'مرحباً بك في API دلّعني',
    version: '1.0.0',
    docs: '/api-docs',
  });
});

// Health Check Endpoint (no auth required)
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    message: 'Backend is running'
  });
});

// Public Routes
app.use('/api/auth', require('./routes/auth'));

// Protected Routes (require authentication)
const { authenticate } = require('./middleware/auth');
// For MVP, allow orders without auth (will add auth later)
app.use('/api/orders', require('./routes/orders'));
app.use('/api/drivers', authenticate, require('./routes/drivers'));
app.use('/api/admin', authenticate, require('./middleware/auth').requireAdmin, require('./routes/admin'));

const PORT = process.env.PORT || 3000;

// Database sync and server start
sequelize.sync({ alter: true }).then(() => {
  console.log('✅ Database synced');

  // Schedule daily debt check at 23:59
  cron.schedule('59 23 * * *', async () => {
    console.log('🕛 Running scheduled end of day debt check...');
    await runEndOfDayCheck();
  });
  console.log('⏰ Scheduled daily debt check at 23:59');

  app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
  });
}).catch(err => {
  console.error('❌ Database sync failed:', err);
});

