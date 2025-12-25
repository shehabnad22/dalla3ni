require('dotenv').config();
const { sequelize, User, Driver, Order } = require('../models');

/**
 * Script to identify and delete fake/test drivers from the database
 * 
 * This script identifies drivers that are likely test/fake accounts based on:
 * - Phone numbers matching test patterns (0792000000-0792000009 from seed.js)
 * - Names matching test patterns
 * - Low activity (no orders or very few orders)
 * - Created during testing phase
 */

async function deleteFakeDrivers() {
  try {
    console.log('🔍 Starting fake drivers identification...');
    
    // Connect to database
    await sequelize.authenticate();
    console.log('✅ Database connected');

    // Find test drivers by phone pattern (from seed.js: 0792000000-0792000009)
    const testPhonePattern = /^079200000\d$/;
    
    // Find all drivers
    const allDrivers = await Driver.findAll({
      include: [{ model: User }],
    });

    console.log(`📊 Total drivers found: ${allDrivers.length}`);

    const fakeDrivers = [];
    const realDrivers = [];

    for (const driver of allDrivers) {
      const user = driver.User;
      if (!user) continue;

      let isFake = false;
      const reasons = [];

      // Check phone pattern
      if (testPhonePattern.test(user.phone)) {
        isFake = true;
        reasons.push('test phone pattern');
      }

      // Check for test names (from seed.js)
      const testNames = [
        'أحمد محمد', 'محمود سعيد', 'خالد علي', 'عمر حسن', 'يوسف أحمد',
        'حسام الدين', 'طارق محمود', 'نادر خالد', 'باسم علي', 'رامي سعيد',
        'سائق 1', 'سائق 2', 'سائق 3', 'سائق 4', 'سائق 5',
        'سائق 6', 'سائق 7', 'سائق 8', 'سائق 9', 'سائق 10',
      ];
      if (testNames.includes(user.name)) {
        isFake = true;
        reasons.push('test name');
      }

      // Check for low activity (no orders or very few)
      const orderCount = await Order.count({ where: { driverId: driver.id } });
      if (orderCount === 0 && driver.totalDeliveries === 0) {
        isFake = true;
        reasons.push('no activity');
      }

      // Check email pattern (test emails from seed.js)
      if (user.email && user.email.match(/driver\d+@dalla3ni\.app/)) {
        isFake = true;
        reasons.push('test email pattern');
      }

      if (isFake) {
        fakeDrivers.push({
          driverId: driver.id,
          userId: user.id,
          name: user.name,
          phone: user.phone,
          email: user.email,
          orderCount,
          reasons,
        });
      } else {
        realDrivers.push({
          driverId: driver.id,
          name: user.name,
          phone: user.phone,
          orderCount,
        });
      }
    }

    console.log(`\n📋 Analysis Results:`);
    console.log(`   - Fake/Test drivers: ${fakeDrivers.length}`);
    console.log(`   - Real drivers: ${realDrivers.length}`);

    if (fakeDrivers.length > 0) {
      console.log(`\n🗑️  Fake drivers to be deleted:`);
      fakeDrivers.forEach((fd, index) => {
        console.log(`   ${index + 1}. ${fd.name} (${fd.phone}) - Reasons: ${fd.reasons.join(', ')}`);
      });

      // Ask for confirmation (in production, you might want to add a --force flag)
      const readline = require('readline');
      const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
      });

      return new Promise((resolve) => {
        rl.question('\n⚠️  Are you sure you want to delete these fake drivers? (yes/no): ', async (answer) => {
          if (answer.toLowerCase() === 'yes' || answer.toLowerCase() === 'y') {
            console.log('\n🗑️  Deleting fake drivers...');
            
            let deletedCount = 0;
            for (const fakeDriver of fakeDrivers) {
              try {
                // Delete associated orders first (if any)
                await Order.destroy({ where: { driverId: fakeDriver.driverId } });
                
                // Delete driver record
                await Driver.destroy({ where: { id: fakeDriver.driverId } });
                
                // Delete user record
                await User.destroy({ where: { id: fakeDriver.userId } });
                
                deletedCount++;
                console.log(`   ✅ Deleted: ${fakeDriver.name} (${fakeDriver.phone})`);
              } catch (error) {
                console.error(`   ❌ Error deleting ${fakeDriver.name}:`, error.message);
              }
            }

            console.log(`\n✅ Successfully deleted ${deletedCount} fake driver(s)`);
            console.log(`📊 Remaining drivers: ${realDrivers.length}`);
          } else {
            console.log('❌ Deletion cancelled');
          }
          
          rl.close();
          await sequelize.close();
          resolve();
        });
      });
    } else {
      console.log('\n✅ No fake drivers found. Database is clean!');
      await sequelize.close();
    }
  } catch (error) {
    console.error('❌ Error:', error);
    await sequelize.close();
    process.exit(1);
  }
}

// Run script
if (require.main === module) {
  deleteFakeDrivers()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error('Fatal error:', error);
      process.exit(1);
    });
}

module.exports = { deleteFakeDrivers };

