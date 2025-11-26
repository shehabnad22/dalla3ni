const sequelize = require('../config/database');
const User = require('./User');
const Driver = require('./Driver');
const Order = require('./Order');
const Review = require('./Review');
const Wallet = require('./Wallet');
const Settlement = require('./Settlement');
const AuditLog = require('./AuditLog');

// User - Driver (1:1)
User.hasOne(Driver, { foreignKey: 'userId' });
Driver.belongsTo(User, { foreignKey: 'userId' });

// Driver - Wallet (1:1)
Driver.hasOne(Wallet, { foreignKey: 'driverId' });
Wallet.belongsTo(Driver, { foreignKey: 'driverId' });

// Driver - Settlement (1:M)
Driver.hasMany(Settlement, { foreignKey: 'driverId' });
Settlement.belongsTo(Driver, { foreignKey: 'driverId' });

// Order relations
User.hasMany(Order, { foreignKey: 'customerId', as: 'orders' });
Order.belongsTo(User, { foreignKey: 'customerId', as: 'customer' });

Driver.hasMany(Order, { foreignKey: 'driverId' });
Order.belongsTo(Driver, { foreignKey: 'driverId' });

// Review relations
Order.hasOne(Review, { foreignKey: 'orderId' });
Review.belongsTo(Order, { foreignKey: 'orderId' });

User.hasMany(Review, { foreignKey: 'customerId' });
Review.belongsTo(User, { foreignKey: 'customerId' });

Driver.hasMany(Review, { foreignKey: 'driverId' });
Review.belongsTo(Driver, { foreignKey: 'driverId' });

module.exports = {
  sequelize,
  User,
  Driver,
  Order,
  Review,
  Wallet,
  Settlement,
  AuditLog,
};
