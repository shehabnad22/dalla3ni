const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Driver = sequelize.define('Driver', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  userId: {
    type: DataTypes.UUID,
    allowNull: false,
  },
  idImage: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  motorImage: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  plateNumber: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  workingAreas: {
    type: DataTypes.ARRAY(DataTypes.STRING),
    defaultValue: [],
  },
  workStartTime: {
    type: DataTypes.TIME,
  },
  workEndTime: {
    type: DataTypes.TIME,
  },
  rating: {
    type: DataTypes.DECIMAL(2, 1),
    defaultValue: 0,
  },
  totalDeliveries: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  isAvailable: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  isApproved: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  accountStatus: {
    type: DataTypes.ENUM('PENDING_REVIEW', 'APPROVED', 'REJECTED'),
    defaultValue: 'PENDING_REVIEW',
  },
  latitude: {
    type: DataTypes.DECIMAL(10, 8),
  },
  longitude: {
    type: DataTypes.DECIMAL(11, 8),
  },
  pendingSettlement: {
    type: DataTypes.DECIMAL(10, 2),
    defaultValue: 0,
  },
  isBlocked: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  blockReason: {
    type: DataTypes.STRING,
  },
  bikeModel: {
    type: DataTypes.STRING,
  },
});

module.exports = Driver;

