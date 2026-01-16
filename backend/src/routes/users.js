const express = require('express');
const router = express.Router();
const { User, Order } = require('../models');

// Get user profile including points
router.get('/:id/profile', async (req, res) => {
    try {
        const user = await User.findByPk(req.params.id, {
            attributes: ['id', 'name', 'phone', 'email', 'points', 'createdAt'],
        });

        if (!user) {
            return res.status(404).json({ success: false, message: 'User not found' });
        }

        // Get order stats
        const totalOrders = await Order.count({ where: { customerId: user.id } });

        res.json({
            success: true,
            user: user,
            points: user.points,
            totalOrders: totalOrders
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
