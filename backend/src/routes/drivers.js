const express = require('express');
const router = express.Router();
const { Driver, User, Order } = require('../models');
const debtCheckService = require('../services/debtCheckService');

// Toggle driver availability (go online/offline)
router.patch('/:driverId/availability', async (req, res) => {
  try {
    const { isAvailable, latitude, longitude } = req.body;
    
    // Check if driver is blocked before going online
    if (isAvailable) {
      const driver = await Driver.findByPk(req.params.driverId);
      if (driver?.isBlocked) {
        return res.status(403).json({ 
          success: false, 
          message: 'حسابك موقوف بسبب مستحقات غير مسددة. يرجى التواصل مع الإدارة.',
          blockReason: driver.blockReason,
          pendingSettlement: driver.pendingSettlement,
        });
      }
    }
    
    await Driver.update(
      { isAvailable, latitude, longitude },
      { where: { id: req.params.driverId } }
    );

    res.json({ success: true, message: isAvailable ? 'أنت الآن متصل' : 'أنت الآن غير متصل' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get driver debt status
router.get('/:driverId/debt-status', async (req, res) => {
  try {
    const status = await debtCheckService.checkDriverDebtStatus(req.params.driverId);
    if (!status) {
      return res.status(404).json({ success: false, message: 'Driver not found' });
    }
    res.json({ success: true, ...status });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Update driver location
router.patch('/:driverId/location', async (req, res) => {
  try {
    const { latitude, longitude } = req.body;
    
    await Driver.update(
      { latitude, longitude },
      { where: { id: req.params.driverId } }
    );

    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get pending orders for driver (in their areas)
router.get('/:driverId/pending-orders', async (req, res) => {
  try {
    const driver = await Driver.findByPk(req.params.driverId);
    if (!driver) {
      return res.status(404).json({ success: false, message: 'Driver not found' });
    }

    const orders = await Order.findAll({
      where: { status: 'matching' },
      include: [{ model: User, as: 'customer', attributes: ['name', 'phone'] }],
      order: [['createdAt', 'DESC']],
    });

    res.json({ success: true, orders });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get driver's active orders
router.get('/:driverId/orders', async (req, res) => {
  try {
    const orders = await Order.findAll({
      where: { 
        driverId: req.params.driverId,
        status: ['accepted', 'picked_up'],
      },
      include: [{ model: User, as: 'customer', attributes: ['name', 'phone'] }],
    });

    res.json({ success: true, orders });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;

