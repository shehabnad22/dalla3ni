const { User, Driver, Order, Settlement, Review, Wallet, AuditLog } = require('../src/models');
const sequelize = require('../src/config/database');

async function cleanup() {
    try {
        console.log('Starting full system cleanup...');

        // Disable foreign key checks for truncate (if possible) or delete in order
        // Standard approach: delete dependent tables first

        await AuditLog.destroy({ where: {} });
        console.log('Audit logs cleared');

        await Review.destroy({ where: {} });
        console.log('Reviews cleared');

        await Settlement.destroy({ where: {} });
        console.log('Settlements cleared');

        await Order.destroy({ where: {} });
        console.log('Orders cleared');

        await Wallet.destroy({ where: {} });
        console.log('Wallets cleared');

        await Driver.destroy({ where: {} });
        console.log('Drivers cleared');

        // Delete users with customer or driver role (keep admins)
        await User.destroy({
            where: {
                role: ['customer', 'driver']
            }
        });
        console.log('Customer and Driver users deleted. Admin user preserved.');

        // For Postgres, we might want to reset sequences as well
        // await sequelize.query('TRUNCATE TABLE "Orders" RESTART IDENTITY CASCADE');
        // But destroy handles Sequelize level hooks if any.

        console.log('Cleanup completed successfully!');
        process.exit(0);
    } catch (error) {
        console.error('Cleanup failed:', error);
        process.exit(1);
    }
}

cleanup();
