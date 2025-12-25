const express = require('express');
const router = express.Router();
const { Driver, User, Order, Settlement } = require('../models');
const sequelize = require('../config/database');
const { Op } = require('sequelize');
const settlementService = require('../services/settlementService');
const { runEndOfDayCheck } = require('../jobs/endOfDayCheck');

// Get daily settlements summary
router.get('/settlements/daily', async (req, res) => {
  try {
    const date = req.query.date ? new Date(req.query.date) : new Date();
    const summary = await settlementService.getDailySettlements(date);
    res.json({ success: true, ...summary });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Mark driver settlement as paid
router.post('/settlements/:driverId/pay', async (req, res) => {
  try {
    const { driverId } = req.params;
    const { adminId, amount } = req.body;

    const result = await settlementService.markAsPaid(driverId, adminId, amount);
    res.json({ success: true, ...result });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get all settlements history
router.get('/settlements/history', async (req, res) => {
  try {
    const settlements = await Settlement.findAll({
      include: [{
        model: Driver,
        include: [{ model: User, attributes: ['name', 'phone'] }]
      }],
      order: [['createdAt', 'DESC']],
      limit: 100,
    });
    res.json({ success: true, settlements });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get blocked drivers
router.get('/drivers/blocked', async (req, res) => {
  try {
    const drivers = await Driver.findAll({
      where: { isBlocked: true },
      include: [{ model: User, attributes: ['name', 'phone'] }],
    });
    res.json({ success: true, drivers });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Unblock driver manually (requires admin approval)
router.post('/drivers/:driverId/unblock', async (req, res) => {
  try {
    const driver = await Driver.findByPk(req.params.driverId, {
      include: [{ model: User, attributes: ['name'] }],
    });
    if (!driver) {
      return res.status(404).json({ success: false, message: 'Driver not found' });
    }

    // Only admin can unblock - debt must be settled first or admin override
    const { adminId, forceUnblock } = req.body;

    if (!forceUnblock && parseFloat(driver.pendingSettlement) > 0) {
      return res.status(400).json({
        success: false,
        message: 'لا يمكن رفع الحظر. يجب تسوية المستحقات أولاً.',
        pendingSettlement: driver.pendingSettlement,
      });
    }

    driver.isBlocked = false;
    driver.blockReason = null;
    await driver.save();

    res.json({
      success: true,
      message: `تم رفع الحظر عن السائق ${driver.User?.name}`,
      driver: {
        id: driver.id,
        pendingSettlement: driver.pendingSettlement,
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Manual trigger for end of day check (for testing)
router.post('/run-debt-check', async (req, res) => {
  try {
    const result = await runEndOfDayCheck();
    res.json(result);
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get all drivers
router.get('/drivers', async (req, res) => {
  try {
    const drivers = await Driver.findAll({
      include: [{ model: User, attributes: ['id', 'name', 'phone', 'email'] }],
      order: [['createdAt', 'DESC']],
    });
    res.json({ success: true, drivers });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Approve driver
router.post('/drivers/:driverId/approve', async (req, res) => {
  try {
    const driver = await Driver.findByPk(req.params.driverId, {
      include: [{ model: User }],
    });
    if (!driver) {
      return res.status(404).json({ success: false, message: 'Driver not found' });
    }

    driver.isApproved = true;
    driver.accountStatus = 'APPROVED';
    driver.User.isVerified = true;
    await driver.save();
    await driver.User.save();

    res.json({ success: true, message: 'تمت الموافقة على السائق' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Block driver
router.post('/drivers/:driverId/block', async (req, res) => {
  try {
    const { reason } = req.body;
    const driver = await Driver.findByPk(req.params.driverId);
    if (!driver) {
      return res.status(404).json({ success: false, message: 'Driver not found' });
    }

    driver.isBlocked = true;
    driver.isAvailable = false;
    driver.blockReason = reason || 'حظر يدوي من الإدارة';
    await driver.save();

    res.json({ success: true, message: 'تم حظر السائق' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get disputes
router.get('/disputes', async (req, res) => {
  try {
    const disputes = await Order.findAll({
      where: { status: 'DISPUTE' },
      include: [
        { model: User, as: 'customer', attributes: ['name', 'phone'] },
        {
          model: Driver,
          include: [{ model: User, attributes: ['name', 'phone'] }]
        },
      ],
      order: [['createdAt', 'DESC']],
    });
    res.json({ success: true, disputes });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Resolve dispute
router.post('/disputes/:orderId/resolve', async (req, res) => {
  try {
    const { resolution, notes, adminId } = req.body;
    const order = await Order.findByPk(req.params.orderId);
    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    // Update order based on resolution
    if (resolution === 'refund') {
      // Mark for refund
      order.notes = `${order.notes || ''}\n[REFUND] ${notes}`;
    } else if (resolution === 'penalty') {
      // Add penalty to driver
      if (order.driverId) {
        const driver = await Driver.findByPk(order.driverId);
        if (driver) {
          driver.pendingSettlement = parseFloat(driver.pendingSettlement) + 5.0; // Penalty
          await driver.save();
        }
      }
      order.notes = `${order.notes || ''}\n[PENALTY] ${notes}`;
    }

    order.status = 'COMPLETED';
    order.disputeFlag = false;
    await order.save();

    res.json({ success: true, message: 'تم حل النزاع' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get settings
router.get('/settings', async (req, res) => {
  try {
    const { featureFlags } = require('../config/featureFlags');
    res.json({
      success: true,
      settings: {
        commissionAmount: featureFlags.commission_amount,
        storesEnabled: featureFlags.stores_enabled,
        dailySettlementTime: '23:59',
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Update settings
router.put('/settings', async (req, res) => {
  try {
    const { commissionAmount, storesEnabled, dailySettlementTime } = req.body;

    // Update environment variables (in production, use database or config service)
    if (commissionAmount !== undefined) {
      process.env.COMMISSION_AMOUNT = commissionAmount.toString();
    }
    if (storesEnabled !== undefined) {
      process.env.STORES_ENABLED = storesEnabled.toString();
    }

    // Reload feature flags
    delete require.cache[require.resolve('../config/featureFlags')];
    const { featureFlags } = require('../config/featureFlags');

    res.json({
      success: true,
      message: 'تم تحديث الإعدادات',
      settings: {
        commissionAmount: featureFlags.commission_amount,
        storesEnabled: featureFlags.stores_enabled,
        dailySettlementTime: dailySettlementTime || '23:59',
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Dashboard stats
router.get('/stats', async (req, res) => {
  try {
    const totalDrivers = await Driver.count();
    const activeDrivers = await Driver.count({ where: { isAvailable: true } });
    const blockedDrivers = await Driver.count({ where: { isBlocked: true } });
    const totalOrders = await Order.count();
    const pendingOrders = await Order.count({ where: { status: 'REQUESTED' } });
    const totalUsers = await User.count({ where: { role: 'customer' } });

    const totalPendingSettlement = await Driver.sum('pendingSettlement') || 0;

    res.json({
      success: true,
      stats: {
        totalUsers,
        totalDrivers,
        activeDrivers,
        blockedDrivers,
        totalOrders,
        pendingOrders,
        totalPendingSettlement,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get all users with sorting and filtering
router.get('/users', async (req, res) => {
  try {
    const { sort = 'newest', search = '' } = req.query;

    let orderBy = [['createdAt', 'DESC']];
    if (sort === 'oldest') {
      orderBy = [['createdAt', 'ASC']];
    } else if (sort === 'name-asc') {
      orderBy = [['name', 'ASC']];
    } else if (sort === 'name-desc') {
      orderBy = [['name', 'DESC']];
    }

    const where = {
      role: 'customer',
    };

    if (search) {
      where[Op.or] = [
        { name: { [Op.iLike]: `%${search}%` } },
        { phone: { [Op.iLike]: `%${search}%` } },
      ];
    }

    const users = await User.findAll({
      where,
      order: orderBy,
      attributes: ['id', 'name', 'phone', 'isBlocked', 'createdAt'],
    });

    // Get orders count for each user
    const usersWithOrders = await Promise.all(
      users.map(async (user) => {
        const ordersCount = await Order.count({ where: { customerId: user.id } });
        return {
          id: user.id,
          name: user.name,
          phone: user.phone,
          isBlocked: user.isBlocked,
          registerTime: user.createdAt,
          ordersCount,
        };
      })
    );

    res.json({ success: true, users: usersWithOrders });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get all orders
router.get('/orders', async (req, res) => {
  try {
    const { status } = req.query;

    const where = {};
    if (status && status !== 'all') {
      where.status = status.toUpperCase();
    }

    const orders = await Order.findAll({
      where,
      include: [
        { model: User, as: 'customer', attributes: ['name', 'phone'] },
        {
          model: Driver,
          include: [{ model: User, attributes: ['name', 'phone'] }],
        },
      ],
      order: [['createdAt', 'DESC']],
    });

    const formattedOrders = orders.map(order => ({
      id: order.id,
      customer: order.customer?.name || 'غير معروف',
      driver: order.Driver?.User?.name || null,
      status: order.status,
      time: order.createdAt,
    }));

    res.json({ success: true, orders: formattedOrders });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get invoices grouped by location
router.get('/invoices', async (req, res) => {
  try {
    const { location } = req.query;

    const where = {
      invoiceImageUrl: { [Op.ne]: null },
    };

    if (location && location !== 'all') {
      // Extract location from pickupAddress
      where.pickupAddress = { [Op.iLike]: `%${location}%` };
    }

    const orders = await Order.findAll({
      where,
      include: [
        {
          model: Driver,
          include: [{ model: User, attributes: ['name'] }],
        },
      ],
      order: [['pickedAt', 'DESC']],
    });

    // Group by location (extract from pickupAddress)
    const grouped = {};
    orders.forEach(order => {
      const location = order.pickupAddress?.split('،')[0]?.trim() || 'غير محدد';
      if (!grouped[location]) {
        grouped[location] = [];
      }
      grouped[location].push({
        id: order.id,
        driver: order.Driver?.User?.name || 'غير معروف',
        location,
        image: order.invoiceImageUrl,
        orderId: order.id,
        time: order.pickedAt || order.createdAt,
      });
    });

    res.json({ success: true, invoices: grouped });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get active deliveries with tracking
router.get('/tracking', async (req, res) => {
  try {
    const activeOrders = await Order.findAll({
      where: {
        status: { [Op.in]: ['ASSIGNED', 'PICKED_UP', 'EN_ROUTE'] },
      },
      include: [
        { model: User, as: 'customer', attributes: ['name', 'phone'] },
        {
          model: Driver,
          include: [{ model: User, attributes: ['name', 'phone'] }],
          attributes: ['id', 'latitude', 'longitude'],
        },
      ],
      order: [['createdAt', 'DESC']],
    });

    const deliveries = activeOrders.map(order => ({
      id: order.id,
      driver: order.Driver?.User?.name || 'غير معروف',
      customer: order.customer?.name || 'غير معروف',
      orderId: order.id,
      driverLocation: order.Driver ? {
        lat: parseFloat(order.Driver.latitude) || null,
        lng: parseFloat(order.Driver.longitude) || null,
      } : null,
      deliveryLocation: {
        lat: parseFloat(order.deliveryLat) || null,
        lng: parseFloat(order.deliveryLng) || null,
      },
      status: order.status,
    }));

    res.json({ success: true, deliveries });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get statistics
router.get('/statistics', async (req, res) => {
  try {
    // Top users by orders
    const topUsers = await User.findAll({
      where: { role: 'customer' },
      attributes: ['id', 'name', 'phone'],
      include: [{
        model: Order,
        as: 'customer',
        attributes: [],
      }],
      group: ['User.id'],
      order: [[sequelize.fn('COUNT', sequelize.col('Orders.id')), 'DESC']],
      limit: 10,
      subQuery: false,
    });

    const topUsersWithCount = await Promise.all(
      topUsers.map(async (user) => {
        const count = await Order.count({ where: { customerId: user.id } });
        return {
          id: user.id,
          name: user.name,
          ordersCount: count,
        };
      })
    );

    // Top rated drivers
    const topRatedDrivers = await Driver.findAll({
      include: [{ model: User, attributes: ['name'] }],
      order: [['rating', 'DESC'], ['totalDeliveries', 'DESC']],
      limit: 10,
    });

    const formattedDrivers = topRatedDrivers.map(driver => ({
      id: driver.id,
      name: driver.User?.name || 'غير معروف',
      rating: parseFloat(driver.rating) || 0,
      ordersCount: driver.totalDeliveries || 0,
    }));

    res.json({
      success: true,
      topUsers: topUsersWithCount,
      topRatedDrivers: formattedDrivers,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get delayed drivers
router.get('/delayed', async (req, res) => {
  try {
    const activeOrders = await Order.findAll({
      where: {
        status: { [Op.in]: ['ASSIGNED', 'PICKED_UP', 'EN_ROUTE'] },
      },
      include: [
        {
          model: Driver,
          include: [{ model: User, attributes: ['name', 'phone'] }],
        },
      ],
    });

    const delayed = [];
    const now = new Date();

    for (const order of activeOrders) {
      // Calculate expected delivery time (30 minutes from assignment)
      const expectedTime = new Date(order.assignedAt || order.createdAt);
      expectedTime.setMinutes(expectedTime.getMinutes() + 30);

      if (now > expectedTime) {
        const delayMinutes = Math.floor((now - expectedTime) / 1000 / 60);
        delayed.push({
          driver: order.Driver?.User?.name || 'غير معروف',
          phone: order.Driver?.User?.phone || '',
          order: `#${order.id.substring(0, 8)}`,
          expectedTime: expectedTime.toLocaleTimeString('ar-SA', { hour: '2-digit', minute: '2-digit' }),
          actualTime: now.toLocaleTimeString('ar-SA', { hour: '2-digit', minute: '2-digit' }),
          delay: `${delayMinutes} دقيقة`,
          delayMinutes,
        });
      }
    }

    // Sort by delay (longest first)
    delayed.sort((a, b) => b.delayMinutes - a.delayMinutes);

    res.json({ success: true, delayed });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Block customer
router.post('/users/:userId/block', async (req, res) => {
  try {
    const { reason } = req.body;
    const user = await User.findByPk(req.params.userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    user.isBlocked = true;
    user.blockReason = reason || 'حظر يدوي من الإدارة';
    await user.save();

    res.json({ success: true, message: 'تم حظر الزبون' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Unblock customer
router.post('/users/:userId/unblock', async (req, res) => {
  try {
    const user = await User.findByPk(req.params.userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    user.isBlocked = false;
    user.blockReason = null;
    await user.save();

    res.json({ success: true, message: 'تم رفع الحظر عن الزبون' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;

