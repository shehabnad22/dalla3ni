const { Server } = require('socket.io');
const { authenticate } = require('../middleware/auth');
const jwt = require('jsonwebtoken');

let io = null;

// Store connected drivers and customers
const connectedDrivers = new Map(); // driverId -> socket
const connectedCustomers = new Map(); // customerId -> socket

/**
 * Initialize Socket.IO server
 * @param {http.Server} server - HTTP server instance
 */
function initializeSocket(server) {
    io = new Server(server, {
        cors: {
            origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : '*',
            credentials: true,
            methods: ['GET', 'POST'],
        },
        pingTimeout: 60000,
        pingInterval: 25000,
    });

    // Authentication middleware for Socket.IO
    io.use(async (socket, next) => {
        try {
            const token = socket.handshake.auth.token || socket.handshake.headers.authorization?.replace('Bearer ', '');

            if (!token) {
                return next(new Error('Authentication token required'));
            }

            const decoded = jwt.verify(token, process.env.JWT_SECRET || 'dalla3ni-secret-key');

            // Attach user info to socket
            socket.userId = decoded.userId;
            socket.userRole = decoded.role;

            next();
        } catch (error) {
            next(new Error('Invalid authentication token'));
        }
    });

    io.on('connection', (socket) => {
        console.log(`✅ Socket connected: ${socket.id} (User: ${socket.userId}, Role: ${socket.userRole})`);

        // Handle driver connection
        if (socket.userRole === 'driver') {
            handleDriverConnection(socket);
        }

        // Handle customer connection
        if (socket.userRole === 'customer') {
            handleCustomerConnection(socket);
        }

        // Handle disconnection
        socket.on('disconnect', () => {
            console.log(`❌ Socket disconnected: ${socket.id}`);

            if (socket.userRole === 'driver' && socket.driverId) {
                connectedDrivers.delete(socket.driverId);
                console.log(`🚗 Driver ${socket.driverId} disconnected`);
            }

            if (socket.userRole === 'customer' && socket.customerId) {
                connectedCustomers.delete(socket.customerId);
                console.log(`👤 Customer ${socket.customerId} disconnected`);
            }
        });
    });

    console.log('🔌 Socket.IO initialized');
    return io;
}

/**
 * Handle driver connection and events
 */
function handleDriverConnection(socket) {
    socket.on('driver:register', (data) => {
        const { driverId } = data;
        socket.driverId = driverId;
        connectedDrivers.set(driverId, socket);
        console.log(`🚗 Driver registered: ${driverId}`);

        // Confirm registration
        socket.emit('driver:registered', { success: true, driverId });
    });

    socket.on('driver:location', async (data) => {
        const { latitude, longitude } = data;
        // Update driver location in database
        // This will be handled by the existing API endpoint
        console.log(`📍 Driver ${socket.driverId} location: ${latitude}, ${longitude}`);
    });

    socket.on('driver:status', (data) => {
        const { isAvailable } = data;
        console.log(`🚗 Driver ${socket.driverId} status: ${isAvailable ? 'Available' : 'Unavailable'}`);
        // Update driver availability in database
    });
}

/**
 * Handle customer connection and events
 */
function handleCustomerConnection(socket) {
    socket.on('customer:register', (data) => {
        const { customerId } = data;
        socket.customerId = customerId;
        connectedCustomers.set(customerId, socket);
        console.log(`👤 Customer registered: ${customerId}`);

        // Confirm registration
        socket.emit('customer:registered', { success: true, customerId });
    });
}

/**
 * Send new order notification to driver
 * @param {string} driverId - Driver ID
 * @param {object} orderData - Order details
 */
function notifyDriverNewOrder(driverId, orderData) {
    const driverSocket = connectedDrivers.get(driverId);

    if (driverSocket) {
        console.log(`📲 Sending order ${orderData.id} to driver ${driverId}`);
        driverSocket.emit('order:new', orderData);
        return true;
    } else {
        console.log(`⚠️ Driver ${driverId} not connected via Socket.IO`);
        return false;
    }
}

/**
 * Notify customer about order status update
 * @param {string} customerId - Customer ID
 * @param {object} orderData - Order details
 */
function notifyCustomerOrderUpdate(customerId, orderData) {
    const customerSocket = connectedCustomers.get(customerId);

    if (customerSocket) {
        console.log(`📲 Sending order update to customer ${customerId}`);
        customerSocket.emit('order:update', orderData);
        return true;
    } else {
        console.log(`⚠️ Customer ${customerId} not connected via Socket.IO`);
        return false;
    }
}

/**
 * Notify driver about order status update
 * @param {string} driverId - Driver ID
 * @param {object} orderData - Order details
 */
function notifyDriverOrderUpdate(driverId, orderData) {
    const driverSocket = connectedDrivers.get(driverId);

    if (driverSocket) {
        console.log(`📲 Sending order update to driver ${driverId}`);
        driverSocket.emit('order:update', orderData);
        return true;
    } else {
        console.log(`⚠️ Driver ${driverId} not connected via Socket.IO`);
        return false;
    }
}

/**
 * Get list of connected driver IDs
 */
function getConnectedDrivers() {
    return Array.from(connectedDrivers.keys());
}

/**
 * Check if driver is connected
 */
function isDriverConnected(driverId) {
    return connectedDrivers.has(driverId);
}

/**
 * Get Socket.IO instance
 */
function getIO() {
    if (!io) {
        throw new Error('Socket.IO not initialized');
    }
    return io;
}

module.exports = {
    initializeSocket,
    notifyDriverNewOrder,
    notifyCustomerOrderUpdate,
    notifyDriverOrderUpdate,
    getConnectedDrivers,
    isDriverConnected,
    getIO,
};
