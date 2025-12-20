const { Driver, Order, Settlement, User } = require('../models');
const { Op } = require('sequelize');
const { featureFlags } = require('../config/featureFlags');

const DEBT_THRESHOLD = 50; // Block driver if debt exceeds this

class SettlementService {
  // Add commission to driver's pending settlement after order completion
  async addCommission(orderId) {
    const order = await Order.findByPk(orderId);
    if (!order || !order.driverId) return;

    const driver = await Driver.findByPk(order.driverId);
    if (!driver) return;

    // Get commission amount from feature flags
    const commissionAmount = featureFlags.commission_amount;
    
    // Update order commission
    order.commissionAmount = commissionAmount;
    await order.save();

    // Add to driver's pending settlement
    driver.pendingSettlement = parseFloat(driver.pendingSettlement) + commissionAmount;
    await driver.save();

    // Check if driver should be blocked
    await this.checkDriverDebt(driver);

    return { commission: commissionAmount, totalPending: driver.pendingSettlement };
  }

  // Check and block driver if debt exceeds threshold
  async checkDriverDebt(driver) {
    if (parseFloat(driver.pendingSettlement) >= DEBT_THRESHOLD && !driver.isBlocked) {
      driver.isBlocked = true;
      driver.blockReason = `ديون متراكمة: ${driver.pendingSettlement} دينار`;
      driver.isAvailable = false;
      await driver.save();
      return true;
    }
    return false;
  }

  // Get daily settlement summary for admin
  async getDailySettlements(date = new Date()) {
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);

    const drivers = await Driver.findAll({
      where: {
        pendingSettlement: { [Op.gt]: 0 },
      },
      include: [{ model: User, attributes: ['name', 'phone'] }],
      order: [['pendingSettlement', 'DESC']],
    });

    const summary = {
      date: date.toISOString().split('T')[0],
      totalPending: drivers.reduce((sum, d) => sum + parseFloat(d.pendingSettlement), 0),
      driversCount: drivers.length,
      drivers: drivers.map(d => ({
        id: d.id,
        name: d.User?.name,
        phone: d.User?.phone,
        pendingSettlement: d.pendingSettlement,
        isBlocked: d.isBlocked,
      })),
    };

    return summary;
  }

  // Mark driver settlement as paid
  async markAsPaid(driverId, adminId, amount = null) {
    const driver = await Driver.findByPk(driverId, {
      include: [{ model: User, attributes: ['name'] }],
    });
    if (!driver) throw new Error('Driver not found');

    const settledAmount = amount || parseFloat(driver.pendingSettlement);

    // Create settlement record
    const settlement = await Settlement.create({
      driverId,
      amount: settledAmount,
      periodStart: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // Last 7 days
      periodEnd: new Date(),
      status: 'paid',
      paidAt: new Date(),
      paidBy: adminId,
    });

    // Reset driver's pending settlement
    driver.pendingSettlement = parseFloat(driver.pendingSettlement) - settledAmount;
    
    // Unblock if debt cleared
    if (driver.isBlocked && parseFloat(driver.pendingSettlement) < DEBT_THRESHOLD) {
      driver.isBlocked = false;
      driver.blockReason = null;
    }
    
    await driver.save();

    return {
      settlement,
      driver: {
        id: driver.id,
        name: driver.User?.name,
        remainingDebt: driver.pendingSettlement,
        isBlocked: driver.isBlocked,
      },
    };
  }

  // Get settlement history for a driver
  async getDriverSettlements(driverId) {
    return Settlement.findAll({
      where: { driverId },
      order: [['createdAt', 'DESC']],
    });
  }
}

module.exports = new SettlementService();

