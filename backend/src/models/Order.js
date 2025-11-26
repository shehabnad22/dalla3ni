const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Order = sequelize.define('Order', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  customerId: {
    type: DataTypes.UUID,
    allowNull: false,
  },
  driverId: {
    type: DataTypes.UUID,
    allowNull: true, // Nullable until assigned
  },
  itemsText: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  estimatedPrice: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true, // Optional
  },
  deliveryFee: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 1.5,
  },
  commissionAmount: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 1.5,
  },
  driverShare: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  deliveryCode: {
    type: DataTypes.STRING(4),
    allowNull: true,
  },
  invoiceImageUrl: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  podImageUrl: {
    type: DataTypes.STRING,
    allowNull: true, // Proof of Delivery
  },
  status: {
    type: DataTypes.ENUM(
      'REQUESTED',
      'ASSIGNED',
      'PICKED_UP',
      'EN_ROUTE',
      'DELIVERED',
      'COMPLETED',
      'CANCELED',
      'DISPUTE'
    ),
    defaultValue: 'REQUESTED',
  },
  disputeFlag: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  disputeReason: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  // Addresses
  pickupAddress: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  pickupLat: {
    type: DataTypes.DECIMAL(10, 8),
    allowNull: true,
  },
  pickupLng: {
    type: DataTypes.DECIMAL(11, 8),
    allowNull: true,
  },
  deliveryAddress: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  deliveryLat: {
    type: DataTypes.DECIMAL(10, 8),
    allowNull: true,
  },
  deliveryLng: {
    type: DataTypes.DECIMAL(11, 8),
    allowNull: true,
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  // Timestamps
  assignedAt: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  pickedAt: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  enRouteAt: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  deliveredAt: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  completedAt: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  canceledAt: {
    type: DataTypes.DATE,
    allowNull: true,
  },
}, {
  timestamps: true, // createdAt, updatedAt
  hooks: {
    beforeCreate: (order) => {
      // Generate 4-digit delivery code
      order.deliveryCode = Math.floor(1000 + Math.random() * 9000).toString();
    },
  },
});

module.exports = Order;
