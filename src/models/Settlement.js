const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Settlement = sequelize.define('Settlement', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  driverId: {
    type: DataTypes.UUID,
    allowNull: false,
  },
  amount: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  ordersCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  periodStart: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  periodEnd: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  status: {
    type: DataTypes.ENUM('pending', 'paid'),
    defaultValue: 'pending',
  },
  paidAt: {
    type: DataTypes.DATE,
  },
  paidBy: {
    type: DataTypes.UUID, // Admin who marked as paid
  },
  notes: {
    type: DataTypes.TEXT,
  },
});

module.exports = Settlement;

