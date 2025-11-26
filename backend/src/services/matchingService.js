const { Driver, User, Order } = require('../models');
const { Op } = require('sequelize');

class MatchingService {
  // Find available drivers in the same area
  async findAvailableDrivers(area, excludeDriverIds = []) {
    const drivers = await Driver.findAll({
      where: {
        isAvailable: true,
        isApproved: true,
        isBlocked: false, // Exclude blocked drivers
        workingAreas: { [Op.contains]: [area] },
        id: { [Op.notIn]: excludeDriverIds },
      },
      include: [{ model: User, attributes: ['id', 'name', 'phone'] }],
    });
    return drivers;
  }

  // Start matching process for an order
  async startMatching(orderId, area) {
    const order = await Order.findByPk(orderId);
    if (!order) throw new Error('Order not found');

    order.status = 'matching';
    await order.save();

    const drivers = await this.findAvailableDrivers(area);
    
    if (drivers.length === 0) {
      return { success: false, message: 'لا يوجد سائقين متاحين حالياً' };
    }

    // Send notification to all available drivers
    const notifiedDrivers = [];
    for (const driver of drivers) {
      await this.sendOrderNotification(driver, order);
      notifiedDrivers.push(driver.id);
    }

    return { 
      success: true, 
      driversNotified: notifiedDrivers.length,
      message: `تم إرسال الطلب إلى ${notifiedDrivers.length} سائق`
    };
  }

  // Send push notification to driver
  async sendOrderNotification(driver, order) {
    // TODO: Implement actual push notification (Firebase/OneSignal)
    console.log(`📱 Notification sent to driver ${driver.id}: طلب جديد - اضغط للقبول`);
    
    // Store pending notification
    // In production, use Redis or similar for real-time
    return {
      driverId: driver.id,
      orderId: order.id,
      title: 'طلب جديد 🛵',
      body: 'طلب جديد في منطقتك - اضغط للقبول',
      data: {
        orderId: order.id,
        type: 'new_order',
      },
    };
  }

  // Driver accepts order - first come first served
  async acceptOrder(orderId, driverId) {
    const order = await Order.findByPk(orderId);
    
    if (!order) {
      return { success: false, message: 'الطلب غير موجود' };
    }

    if (order.status !== 'matching') {
      return { success: false, message: 'الطلب تم قبوله من سائق آخر' };
    }

    // Assign to first driver who accepts
    order.driverId = driverId;
    order.status = 'accepted';
    order.acceptedAt = new Date();
    await order.save();

    // Update driver availability
    await Driver.update(
      { isAvailable: false },
      { where: { id: driverId } }
    );

    return { 
      success: true, 
      message: 'تم قبول الطلب بنجاح',
      order 
    };
  }

  // Driver rejects/ignores order
  async rejectOrder(orderId, driverId) {
    // Log rejection for analytics
    console.log(`Driver ${driverId} rejected order ${orderId}`);
    return { success: true };
  }
}

module.exports = new MatchingService();

