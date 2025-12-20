const { Driver, User, AuditLog } = require('../models');
const { Op } = require('sequelize');

class DebtCheckService {
  // Run at end of day (e.g., via cron job at 23:59)
  // Sends warnings first, then blocks after 24 hours
  async checkEndOfDayDebts() {
    const driversWithDebt = await Driver.findAll({
      where: {
        pendingSettlement: { [Op.gt]: 0 },
      },
      include: [{ model: User, attributes: ['id', 'name', 'phone'] }],
    });

    const warnedDrivers = [];
    const blockedDrivers = [];

    for (const driver of driversWithDebt) {
      // Check if driver was already warned
      const lastWarning = await AuditLog.findOne({
        where: {
          action: 'DEBT_WARNING_SENT',
          entityType: 'driver',
          entityId: driver.id,
        },
        order: [['createdAt', 'DESC']],
      });

      const warningAge = lastWarning 
        ? (Date.now() - new Date(lastWarning.createdAt).getTime()) / (1000 * 60 * 60) // hours
        : Infinity;

      if (warningAge >= 24 && !driver.isBlocked) {
        // Block driver after 24 hours of warning
        driver.isBlocked = true;
        driver.isAvailable = false;
        driver.blockReason = `ديون غير مسددة: ${driver.pendingSettlement} دينار - تم الحظر بعد 24 ساعة من الإنذار`;
        await driver.save();

        await AuditLog.create({
          action: 'DRIVER_BLOCKED_DEBT',
          entityType: 'driver',
          entityId: driver.id,
          actorType: 'system',
          details: {
            pendingSettlement: driver.pendingSettlement,
            warningAgeHours: warningAge,
          },
          result: 'blocked',
        });

        blockedDrivers.push({
          id: driver.id,
          name: driver.User?.name,
          phone: driver.User?.phone,
          debt: driver.pendingSettlement,
        });
      } else if (!lastWarning || warningAge < 24) {
        // Send warning notification (first time or within 24 hours)
        await this.sendDebtWarningNotification(driver);

        await AuditLog.create({
          action: 'DEBT_WARNING_SENT',
          entityType: 'driver',
          entityId: driver.id,
          actorType: 'system',
          details: {
            pendingSettlement: driver.pendingSettlement,
            warningAgeHours: warningAge,
          },
          result: 'warned',
        });

        warnedDrivers.push({
          id: driver.id,
          name: driver.User?.name,
          phone: driver.User?.phone,
          debt: driver.pendingSettlement,
          hoursUntilBlock: lastWarning ? Math.max(0, 24 - warningAge) : 24,
        });
      }
    }

    console.log(`⚠️ End of day debt check:`);
    console.log(`   - Warnings sent: ${warnedDrivers.length}`);
    console.log(`   - Drivers blocked: ${blockedDrivers.length}`);

    return { warnedDrivers, blockedDrivers };
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

