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
  },
  itemsText: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
  },
  deliveryFee: {
    type: DataTypes.DECIMAL(10, 2),
  },
  totalPrice: {
    type: DataTypes.DECIMAL(10, 2),
  },
  status: {
    type: DataTypes.ENUM('pending', 'matching', 'accepted', 'picked_up', 'delivered', 'cancelled'),
    defaultValue: 'pending',
  },
  pickupAddress: {
    type: DataTypes.STRING,
  },
  pickupLat: {
    type: DataTypes.DECIMAL(10, 8),
  },
  pickupLng: {
    type: DataTypes.DECIMAL(11, 8),
  },
  deliveryAddress: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  deliveryLat: {
    type: DataTypes.DECIMAL(10, 8),
  },
  deliveryLng: {
    type: DataTypes.DECIMAL(11, 8),
  },
  notes: {
    type: DataTypes.TEXT,
  },
  acceptedAt: {
    type: DataTypes.DATE,
  },
  pickedUpAt: {
    type: DataTypes.DATE,
  },
  deliveredAt: {
    type: DataTypes.DATE,
  },
  invoiceImage: {
    type: DataTypes.STRING,
  },
  deliveryCode: {
    type: DataTypes.STRING(4),
  },
  commission: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 1.5,
  },
});

module.exports = Order;

