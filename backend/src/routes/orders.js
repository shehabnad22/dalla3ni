const express = require('express');
const router = express.Router();
const { Order, Driver, User } = require('../models');
const matchingService = require('../services/matchingService');
const settlementService = require('../services/settlementService');

// ============================================
// POST /orders - Create new order
// ============================================
router.post('/', async (req, res) => {
  try {
    const { 
      customerId, 
      itemsText, 
      estimatedPrice, 
      deliveryAddress, 
      deliveryLat, 
      deliveryLng,
      pickupAddress,
      notes,
      area 
    } = req.body;

    // Validation
    if (!customerId || !itemsText || !deliveryAddress) {
      return res.status(400).json({ 
        success: false, 
        message: 'customerId, itemsText, و deliveryAddress مطلوبة' 
      });
    }

    // Create order
    const order = await Order.create({
      customerId,
      itemsText,
      estimatedPrice: estimatedPrice || null,
      deliveryAddress,
      deliveryLat,
      deliveryLng,
      pickupAddress,
      notes,
      status: 'REQUESTED',
      deliveryFee: 1.5,
      commissionAmount: 1.5,
    });

    // Start matching process
    let matchResult = { success: false, message: 'لم يتم تحديد المنطقة' };
    if (area) {
      matchResult = await matchingService.startMatching(order.id, area);
    }

    res.status(201).json({
      success: true,
      order: {
        id: order.id,
        status: order.status,
        deliveryCode: order.deliveryCode,
        itemsText: order.itemsText,
        estimatedPrice: order.estimatedPrice,
        deliveryFee: order.deliveryFee,
        deliveryAddress: order.deliveryAddress,
        createdAt: order.createdAt,
      },
      matching: matchResult,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================
// POST /orders/:id/assign - Internal: Assign driver to order
// ============================================
router.post('/:id/assign', async (req, res) => {
  try {
    const { driverId } = req.body;
    const order = await Order.findByPk(req.params.id);

    if (!order) {
      return res.status(404).json({ success: false, message: 'الطلب غير موجود' });
    }

    if (order.status !== 'REQUESTED') {
      return res.status(400).json({ success: false, message: 'لا يمكن تعيين سائق لهذا الطلب' });
    }

    order.driverId = driverId;
    order.status = 'ASSIGNED';
    order.assignedAt = new Date();
    await order.save();

    // Notify driver
    // TODO: Send push notification

    res.json({
      success: true,
      message: 'تم تعيين السائق',
      order: {
        id: order.id,
        status: order.status,
        driverId: order.driverId,
        assignedAt: order.assignedAt,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================
// POST /orders/:id/accept - Driver accepts order
// ============================================
router.post('/:id/accept', async (req, res) => {
  try {
    const { driverId } = req.body;
    const order = await Order.findByPk(req.params.id);

    if (!order) {
      return res.status(404).json({ success: false, message: 'الطلب غير موجود' });
    }

    // Check if order is still available
    if (order.status !== 'REQUESTED' && order.status !== 'ASSIGNED') {
      return res.status(400).json({ 
        success: false, 
        message: 'الطلب تم قبوله من سائق آخر أو لم يعد متاحاً' 
      });
    }

    // Check driver status
    const driver = await Driver.findByPk(driverId);
    if (!driver || driver.isBlocked) {
      return res.status(403).json({ success: false, message: 'لا يمكنك قبول الطلبات حالياً' });
    }

    // Assign order to driver
    order.driverId = driverId;
    order.status = 'ASSIGNED';
    order.assignedAt = new Date();
    await order.save();

    // Update driver availability
    driver.isAvailable = false;
    await driver.save();

    // Notify customer
    // TODO: Send push notification

    res.json({
      success: true,
      message: 'تم قبول الطلب بنجاح',
      order: {
        id: order.id,
        status: order.status,
        deliveryCode: order.deliveryCode,
        itemsText: order.itemsText,
        deliveryAddress: order.deliveryAddress,
        customer: await User.findByPk(order.customerId, { attributes: ['name', 'phone'] }),
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================
// POST /orders/:id/pickup - Driver uploads invoice image
// ============================================
router.post('/:id/pickup', async (req, res) => {
  try {
    const { driverId, invoiceImageUrl, actualPrice } = req.body;
    const order = await Order.findByPk(req.params.id);

    if (!order) {
      return res.status(404).json({ success: false, message: 'الطلب غير موجود' });
    }

    if (order.driverId !== driverId) {
      return res.status(403).json({ success: false, message: 'هذا الطلب ليس مسنداً إليك' });
    }

    if (order.status !== 'ASSIGNED') {
      return res.status(400).json({ success: false, message: 'حالة الطلب لا تسمح بهذا الإجراء' });
    }

    if (!invoiceImageUrl) {
      return res.status(400).json({ success: false, message: 'صورة الفاتورة مطلوبة' });
    }

    // Update order
    order.invoiceImageUrl = invoiceImageUrl;
    order.status = 'PICKED_UP';
    order.pickedAt = new Date();
    
    // Update actual price if provided
    if (actualPrice) {
      order.estimatedPrice = actualPrice;
    }

    await order.save();

    res.json({
      success: true,
      message: 'تم تأكيد استلام الطلب',
      order: {
        id: order.id,
        status: order.status,
        invoiceImageUrl: order.invoiceImageUrl,
        pickedAt: order.pickedAt,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================
// POST /orders/:id/enroute - Driver is on the way
// ============================================
router.post('/:id/enroute', async (req, res) => {
  try {
    const { driverId } = req.body;
    const order = await Order.findByPk(req.params.id);

    if (!order || order.driverId !== driverId) {
      return res.status(404).json({ success: false, message: 'الطلب غير موجود أو ليس مسنداً إليك' });
    }

    if (order.status !== 'PICKED_UP') {
      return res.status(400).json({ success: false, message: 'يجب استلام الطلب أولاً' });
    }

    order.status = 'EN_ROUTE';
    order.enRouteAt = new Date();
    await order.save();

    // Notify customer with delivery code
    // TODO: Send push notification

    res.json({
      success: true,
      message: 'أنت الآن في الطريق للزبون',
      order: {
        id: order.id,
        status: order.status,
        enRouteAt: order.enRouteAt,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================
// POST /orders/:id/deliver - Driver enters delivery code
// ============================================
router.post('/:id/deliver', async (req, res) => {
  try {
    const { driverId, deliveryCode, podImageUrl } = req.body;
    const order = await Order.findByPk(req.params.id);

    if (!order || order.driverId !== driverId) {
      return res.status(404).json({ success: false, message: 'الطلب غير موجود أو ليس مسنداً إليك' });
    }

    if (order.status !== 'EN_ROUTE' && order.status !== 'PICKED_UP') {
      return res.status(400).json({ success: false, message: 'حالة الطلب لا تسمح بالتسليم' });
    }

    // Verify delivery code
    if (order.deliveryCode !== deliveryCode) {
      return res.status(400).json({ success: false, message: 'كود التسليم غير صحيح' });
    }

    // Update order
    order.status = 'DELIVERED';
    order.deliveredAt = new Date();
    if (podImageUrl) {
      order.podImageUrl = podImageUrl;
    }
    await order.save();

    res.json({
      success: true,
      message: 'تم تأكيد التسليم - في انتظار تقييم الزبون',
      order: {
        id: order.id,
        status: order.status,
        deliveredAt: order.deliveredAt,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================
// POST /orders/:id/complete - Complete order (after rating)
// ============================================
router.post('/:id/complete', async (req, res) => {
  try {
    const { rating, comment } = req.body;
    const order = await Order.findByPk(req.params.id);

    if (!order) {
      return res.status(404).json({ success: false, message: 'الطلب غير موجود' });
    }

    if (order.status !== 'DELIVERED') {
      return res.status(400).json({ success: false, message: 'الطلب لم يتم تسليمه بعد' });
    }

    // Complete order
    order.status = 'COMPLETED';
    order.completedAt = new Date();
    
    // Calculate driver share
    const totalAmount = parseFloat(order.estimatedPrice || 0) + parseFloat(order.deliveryFee);
    order.driverShare = totalAmount - parseFloat(order.commissionAmount);
    
    await order.save();

    // Add commission to driver's pending settlement
    await settlementService.addCommission(order.id);

    // Make driver available again
    if (order.driverId) {
      await Driver.update({ isAvailable: true }, { where: { id: order.driverId } });
    }

    // Save rating
    if (rating && order.driverId) {
      const { Review } = require('../models');
      await Review.create({
        orderId: order.id,
        customerId: order.customerId,
        driverId: order.driverId,
        rating,
        comment,
      });

      // Update driver rating
      const reviews = await Review.findAll({ where: { driverId: order.driverId } });
      const avgRating = reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length;
      await Driver.update(
        { rating: avgRating.toFixed(1), totalDeliveries: reviews.length },
        { where: { id: order.driverId } }
      );
    }

    res.json({
      success: true,
      message: 'تم إكمال الطلب بنجاح',
      order: {
        id: order.id,
        status: order.status,
        completedAt: order.completedAt,
        driverShare: order.driverShare,
        commissionAmount: order.commissionAmount,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================
// POST /orders/:id/cancel - Cancel order
// ============================================
router.post('/:id/cancel', async (req, res) => {
  try {
    const { reason, canceledBy } = req.body;
    const order = await Order.findByPk(req.params.id);

    if (!order) {
      return res.status(404).json({ success: false, message: 'الطلب غير موجود' });
    }

    // Can only cancel if not yet delivered
    if (['DELIVERED', 'COMPLETED', 'CANCELED'].includes(order.status)) {
      return res.status(400).json({ success: false, message: 'لا يمكن إلغاء هذا الطلب' });
    }

    order.status = 'CANCELED';
    order.canceledAt = new Date();
    order.notes = `${order.notes || ''}\nسبب الإلغاء: ${reason || 'غير محدد'} (بواسطة: ${canceledBy})`;
    await order.save();

    // Make driver available again
    if (order.driverId) {
      await Driver.update({ isAvailable: true }, { where: { id: order.driverId } });
    }

    res.json({
      success: true,
      message: 'تم إلغاء الطلب',
      order: {
        id: order.id,
        status: order.status,
        canceledAt: order.canceledAt,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================
// POST /orders/:id/dispute - Flag order as dispute
// ============================================
router.post('/:id/dispute', async (req, res) => {
  try {
    const { reason, reportedBy } = req.body;
    const order = await Order.findByPk(req.params.id);

    if (!order) {
      return res.status(404).json({ success: false, message: 'الطلب غير موجود' });
    }

    order.status = 'DISPUTE';
    order.disputeFlag = true;
    order.disputeReason = `${reason} (بلاغ من: ${reportedBy})`;
    await order.save();

    // Notify admin
    // TODO: Send notification to admin dashboard

    res.json({
      success: true,
      message: 'تم تسجيل البلاغ وسيتم مراجعته من قبل الإدارة',
      order: {
        id: order.id,
        status: order.status,
        disputeFlag: order.disputeFlag,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================
// GET /orders/:id - Get order details
// ============================================
router.get('/:id', async (req, res) => {
  try {
    const order = await Order.findByPk(req.params.id, {
      include: [
        { model: User, as: 'customer', attributes: ['id', 'name', 'phone'] },
        { 
          model: Driver, 
          include: [{ model: User, attributes: ['name', 'phone'] }],
        },
      ],
    });

    if (!order) {
      return res.status(404).json({ success: false, message: 'الطلب غير موجود' });
    }

    res.json({ success: true, order });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// ============================================
// GET /orders - List orders (with filters)
// ============================================
router.get('/', async (req, res) => {
  try {
    const { customerId, driverId, status, limit = 20, offset = 0 } = req.query;
    
    const where = {};
    if (customerId) where.customerId = customerId;
    if (driverId) where.driverId = driverId;
    if (status) where.status = status;

    const orders = await Order.findAndCountAll({
      where,
      include: [
        { model: User, as: 'customer', attributes: ['id', 'name', 'phone'] },
        { model: Driver, include: [{ model: User, attributes: ['name', 'phone'] }] },
      ],
      order: [['createdAt', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset),
    });

    res.json({
      success: true,
      orders: orders.rows,
      total: orders.count,
      limit: parseInt(limit),
      offset: parseInt(offset),
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
