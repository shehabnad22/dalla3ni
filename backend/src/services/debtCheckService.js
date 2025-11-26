const { Driver, User } = require('../models');
const { Op } = require('sequelize');

class DebtCheckService {
  // Run at end of day (e.g., via cron job at 23:59)
  async checkEndOfDayDebts() {
    const driversWithDebt = await Driver.findAll({
      where: {
        pendingSettlement: { [Op.gt]: 0 },
        isBlocked: false,
      },
      include: [{ model: User, attributes: ['id', 'name', 'phone'] }],
    });

    const blockedDrivers = [];

    for (const driver of driversWithDebt) {
      // Block driver
      driver.isBlocked = true;
      driver.isAvailable = false;
      driver.blockReason = `ديون غير مسددة: ${driver.pendingSettlement} دينار - يرجى التسوية مع الإدارة`;
      await driver.save();

      // Send warning notification
      await this.sendDebtWarningNotification(driver);

      blockedDrivers.push({
        id: driver.id,
        name: driver.User?.name,
        phone: driver.User?.phone,
        debt: driver.pendingSettlement,
      });
    }

    console.log(`🚫 End of day debt check: ${blockedDrivers.length} drivers blocked`);
    return blockedDrivers;
  }

  // Send push notification to driver
  async sendDebtWarningNotification(driver) {
    // TODO: Implement actual push notification (Firebase/OneSignal)
    console.log(`⚠️ Debt warning sent to driver ${driver.id}:`);
    console.log(`   "لديك مستحقات غير مسددة بقيمة ${driver.pendingSettlement} دينار. تم إيقاف حسابك مؤقتاً."`);

    return {
      driverId: driver.id,
      title: '⚠️ تنبيه: مستحقات غير مسددة',
      body: `لديك مستحقات بقيمة ${driver.pendingSettlement} دينار. تم إيقاف استقبال الطلبات. يرجى التواصل مع الإدارة للتسوية.`,
      data: {
        type: 'debt_warning',
        amount: driver.pendingSettlement,
      },
    };
  }

  // Check single driver debt status
  async checkDriverDebtStatus(driverId) {
    const driver = await Driver.findByPk(driverId);
    if (!driver) return null;

    return {
      hasDebt: parseFloat(driver.pendingSettlement) > 0,
      amount: driver.pendingSettlement,
      isBlocked: driver.isBlocked,
      blockReason: driver.blockReason,
      canReceiveOrders: !driver.isBlocked && parseFloat(driver.pendingSettlement) === 0,
    };
  }
}

module.exports = new DebtCheckService();

