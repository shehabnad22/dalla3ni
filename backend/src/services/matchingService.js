const { Driver, User, Order, AuditLog } = require('../models');
const { Op } = require('sequelize');

// Area proximity map - areas grouped by proximity
const AREA_PROXIMITY = {
  'وسط البلد': ['جبل عمان', 'جبل الحسين', 'الشميساني', 'الهاشمي'],
  'جبل عمان': ['وسط البلد', 'الشميساني', 'عبدون', 'الرابية'],
  'جبل الحسين': ['وسط البلد', 'الشميساني', 'طبربور'],
  'الشميساني': ['وسط البلد', 'جبل عمان', 'جبل الحسين', 'عبدون'],
  'عبدون': ['الشميساني', 'جبل عمان', 'الرابية', 'خلدا'],
  'الرابية': ['عبدون', 'جبل عمان', 'خلدا', 'الجبيهة'],
  'خلدا': ['عبدون', 'الرابية', 'الجبيهة', 'صويلح'],
  'الجبيهة': ['خلدا', 'الرابية', 'صويلح', 'شفا بدران'],
  'صويلح': ['الجبيهة', 'خلدا', 'شفا بدران', 'أبو نصير'],
  'طبربور': ['جبل الحسين', 'ماركا', 'الهاشمي'],
  'ماركا': ['طبربور', 'الهاشمي', 'الزرقاء'],
  'الهاشمي': ['وسط البلد', 'طبربور', 'ماركا'],
  'أبو نصير': ['صويلح', 'شفا بدران', 'الجبيهة'],
  'شفا بدران': ['أبو نصير', 'صويلح', 'الجبيهة'],
  'المدينة الرياضية': ['الشميساني', 'وسط البلد'],
  'الزرقاء': ['ماركا'],
  'السلط': ['صويلح'],
};

// Notification timeout per driver (ms)
const NOTIFICATION_TIMEOUT = 12000; // 12 seconds

// Max drivers to notify
const MAX_DRIVERS_TO_NOTIFY = 5;

// Pending order locks (in production use Redis)
const orderLocks = new Map();

class MatchingService {
  
  /**
   * Calculate proximity score for a driver based on area tags
   * Higher score = closer/better match
   */
  calculateProximityScore(driverAreas, orderArea) {
    // Direct match - highest priority
    if (driverAreas.includes(orderArea)) {
      return 100;
    }
    
    // Check adjacent areas
    const adjacentAreas = AREA_PROXIMITY[orderArea] || [];
    for (const area of driverAreas) {
      if (adjacentAreas.includes(area)) {
        return 75; // Adjacent area
      }
    }
    
    // Check second-degree proximity
    for (const adjacent of adjacentAreas) {
      const secondDegree = AREA_PROXIMITY[adjacent] || [];
      for (const area of driverAreas) {
        if (secondDegree.includes(area)) {
          return 50; // 2 areas away
        }
      }
    }
    
    return 0; // No proximity match
  }

  /**
   * Find and rank available drivers for an order
   */
  async findAvailableDrivers(orderArea, excludeDriverIds = []) {
    // Get all online, approved, non-blocked drivers
    const drivers = await Driver.findAll({
      where: {
        isAvailable: true,
        isApproved: true,
        isBlocked: false,
        id: { [Op.notIn]: excludeDriverIds },
      },
      include: [{ model: User, attributes: ['id', 'name', 'phone'] }],
    });

    // Score and rank drivers
    const rankedDrivers = drivers.map(driver => {
      const proximityScore = this.calculateProximityScore(
        driver.workingAreas || [],
        orderArea
      );
      
      // Activity score based on last update (more recent = higher)
      const lastActivity = driver.updatedAt ? new Date(driver.updatedAt).getTime() : 0;
      const activityScore = Math.min(50, (Date.now() - lastActivity) / (1000 * 60)); // Minutes since last activity
      
      // Rating bonus
      const ratingBonus = (parseFloat(driver.rating) || 0) * 5;
      
      return {
        driver,
        score: proximityScore + (50 - activityScore) + ratingBonus,
        proximityScore,
      };
    });

    // Sort by score (highest first) and filter those with proximity
    return rankedDrivers
      .filter(d => d.proximityScore > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, MAX_DRIVERS_TO_NOTIFY)
      .map(d => d.driver);
  }

  /**
   * Send push notification to driver
   */
  async sendNotification(driver, order) {
    // TODO: Implement actual push notification (Firebase/OneSignal)
    console.log(`📱 [PUSH] Driver ${driver.User?.name} (${driver.id}): طلب جديد #${order.id.slice(0, 8)}`);
    
    // Log the notification attempt
    await AuditLog.create({
      action: 'MATCHING_NOTIFICATION_SENT',
      entityType: 'order',
      entityId: order.id,
      actorType: 'system',
      details: {
        driverId: driver.id,
        driverName: driver.User?.name,
        driverPhone: driver.User?.phone,
        orderArea: order.deliveryAddress,
      },
      result: 'sent',
    });

    return {
      driverId: driver.id,
      title: 'طلب جديد 🛵',
      body: `طلب جديد في منطقتك - ${order.itemsText?.slice(0, 50)}...`,
      data: {
        orderId: order.id,
        type: 'new_order',
        timeout: NOTIFICATION_TIMEOUT,
      },
    };
  }

  /**
   * Start matching process for an order
   * Notifies drivers sequentially with timeout
   */
  async startMatching(orderId, area) {
    const order = await Order.findByPk(orderId);
    if (!order) throw new Error('Order not found');

    // Update order status
    order.status = 'REQUESTED';
    await order.save();

    // Log matching start
    await AuditLog.create({
      action: 'MATCHING_STARTED',
      entityType: 'order',
      entityId: orderId,
      actorType: 'system',
      details: { area, orderItems: order.itemsText?.slice(0, 100) },
      result: 'started',
    });

    // Find available drivers
    const drivers = await this.findAvailableDrivers(area);

    if (drivers.length === 0) {
      await AuditLog.create({
        action: 'MATCHING_NO_DRIVERS',
        entityType: 'order',
        entityId: orderId,
        actorType: 'system',
        details: { area },
        result: 'failed',
      });
      return { success: false, message: 'لا يوجد سائقين متاحين في هذه المنطقة حالياً' };
    }

    // Initialize lock for this order
    orderLocks.set(orderId, { locked: false, assignedTo: null });

    // Notify drivers sequentially
    const notificationResults = [];
    
    for (let i = 0; i < drivers.length; i++) {
      const driver = drivers[i];
      
      // Check if order already taken
      const lock = orderLocks.get(orderId);
      if (lock?.locked) {
        console.log(`⏹️ Order ${orderId} already taken, stopping notifications`);
        break;
      }

      // Send notification
      const notification = await this.sendNotification(driver, order);
      notificationResults.push({
        driverId: driver.id,
        driverName: driver.User?.name,
        sentAt: new Date(),
        position: i + 1,
      });

      // Wait for response or timeout (in real implementation, this would be event-driven)
      // For now, we send all notifications and first to accept wins
      if (i < drivers.length - 1) {
        // Small delay between notifications to give priority to closer drivers
        await new Promise(resolve => setTimeout(resolve, 500));
      }
    }

    // Log matching results
    await AuditLog.create({
      action: 'MATCHING_NOTIFICATIONS_SENT',
      entityType: 'order',
      entityId: orderId,
      actorType: 'system',
      details: {
        driversNotified: notificationResults.length,
        drivers: notificationResults,
      },
      result: 'success',
    });

    return {
      success: true,
      driversNotified: notificationResults.length,
      message: `تم إرسال الطلب إلى ${notificationResults.length} سائق`,
      notifications: notificationResults,
    };
  }

  /**
   * Driver accepts order - atomic lock
   */
  async acceptOrder(orderId, driverId) {
    // Get or create lock
    let lock = orderLocks.get(orderId);
    if (!lock) {
      lock = { locked: false, assignedTo: null };
      orderLocks.set(orderId, lock);
    }

    // Atomic check and lock
    if (lock.locked) {
      await AuditLog.create({
        action: 'MATCHING_ACCEPT_REJECTED',
        entityType: 'order',
        entityId: orderId,
        actorType: 'driver',
        actorId: driverId,
        details: { reason: 'already_taken', takenBy: lock.assignedTo },
        result: 'rejected',
      });
      return { success: false, message: 'الطلب تم قبوله من سائق آخر' };
    }

    // Lock the order
    lock.locked = true;
    lock.assignedTo = driverId;
    orderLocks.set(orderId, lock);

    // Update order in database
    const order = await Order.findByPk(orderId);
    if (!order || order.status !== 'REQUESTED') {
      lock.locked = false;
      lock.assignedTo = null;
      return { success: false, message: 'الطلب لم يعد متاحاً' };
    }

    order.driverId = driverId;
    order.status = 'ASSIGNED';
    order.assignedAt = new Date();
    await order.save();

    // Update driver availability
    await Driver.update(
      { isAvailable: false },
      { where: { id: driverId } }
    );

    // Log successful acceptance
    await AuditLog.create({
      action: 'MATCHING_ACCEPTED',
      entityType: 'order',
      entityId: orderId,
      actorType: 'driver',
      actorId: driverId,
      details: {
        acceptedAt: new Date(),
        responseTime: Date.now() - new Date(order.createdAt).getTime(),
      },
      result: 'success',
    });

    // Clean up lock after some time
    setTimeout(() => orderLocks.delete(orderId), 60000);

    return {
      success: true,
      message: 'تم قبول الطلب بنجاح',
      order: {
        id: order.id,
        status: order.status,
        deliveryCode: order.deliveryCode,
        itemsText: order.itemsText,
        deliveryAddress: order.deliveryAddress,
      },
    };
  }

  /**
   * Driver rejects/ignores order
   */
  async rejectOrder(orderId, driverId, reason = 'rejected') {
    await AuditLog.create({
      action: 'MATCHING_REJECTED',
      entityType: 'order',
      entityId: orderId,
      actorType: 'driver',
      actorId: driverId,
      details: { reason },
      result: 'rejected',
    });

    return { success: true };
  }

  /**
   * Timeout - driver didn't respond
   */
  async timeoutDriver(orderId, driverId) {
    await AuditLog.create({
      action: 'MATCHING_TIMEOUT',
      entityType: 'order',
      entityId: orderId,
      actorType: 'driver',
      actorId: driverId,
      details: { timeoutMs: NOTIFICATION_TIMEOUT },
      result: 'timeout',
    });

    return { success: true };
  }
}

module.exports = new MatchingService();
