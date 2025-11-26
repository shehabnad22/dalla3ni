const express = require('express');
const router = express.Router();
const { Driver, User, Order, Settlement } = require('../models');
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

// Dashboard stats
router.get('/stats', async (req, res) => {
  try {
    const totalDrivers = await Driver.count();
    const activeDrivers = await Driver.count({ where: { isAvailable: true } });
    const blockedDrivers = await Driver.count({ where: { isBlocked: true } });
    const totalOrders = await Order.count();
    const pendingOrders = await Order.count({ where: { status: 'pending' } });
    
    const totalPendingSettlement = await Driver.sum('pendingSettlement') || 0;

    res.json({
      success: true,
      stats: {
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

module.exports = router;

