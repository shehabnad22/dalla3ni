const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Wallet = sequelize.define('Wallet', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  driverId: {
    type: DataTypes.UUID,
    allowNull: false,
    unique: true,
  },
  pendingSettlement: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  totalEarnings: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  totalWithdrawn: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  completedOrders: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
});

module.exports = Wallet;

