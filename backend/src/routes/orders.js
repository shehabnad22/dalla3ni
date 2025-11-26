const express = require('express');
const router = express.Router();
const { Order, Driver, User } = require('../models');
const matchingService = require('../services/matchingService');

// Create new order
router.post('/', async (req, res) => {
  try {
    const { customerId, itemsText, price, deliveryAddress, deliveryLat, deliveryLng, notes, area } = req.body;

    const order = await Order.create({
      customerId,
      itemsText,
      price,
      deliveryAddress,
      deliveryLat,
      deliveryLng,
      notes,
      status: 'pending',
    });

    // Start matching process
    const matchResult = await matchingService.startMatching(order.id, area);

    res.status(201).json({
      success: true,
      order,
      matching: matchResult,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Driver accepts order
router.post('/:orderId/accept', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { driverId } = req.body;

    const result = await matchingService.acceptOrder(orderId, driverId);
    
    if (!result.success) {
      return res.status(400).json(result);
    }

    res.json(result);
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Driver rejects order
router.post('/:orderId/reject', async (req, res) => {
  try {
    const { orderId } = req.params;
    const { driverId } = req.body;

    const result = await matchingService.rejectOrder(orderId, driverId);
    res.json(result);
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get order status
router.get('/:orderId', async (req, res) => {
  try {
    const order = await Order.findByPk(req.params.orderId, {
      include: [
        { model: User, as: 'customer', attributes: ['id', 'name', 'phone'] },
        { model: Driver, include: [{ model: User, attributes: ['id', 'name', 'phone'] }] },
      ],
    });

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    res.json({ success: true, order });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Update order status (driver)
router.patch('/:orderId/status', async (req, res) => {
  try {
    const { status } = req.body;
    const order = await Order.findByPk(req.params.orderId);

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    order.status = status;
    if (status === 'picked_up') order.pickedUpAt = new Date();
    if (status === 'delivered') {
      order.deliveredAt = new Date();
      // Make driver available again
      await Driver.update({ isAvailable: true }, { where: { id: order.driverId } });
    }

    await order.save();
    res.json({ success: true, order });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;

