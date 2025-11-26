const debtCheckService = require('../services/debtCheckService');

// Schedule this to run at 23:59 daily using node-cron or similar
// Example with node-cron: cron.schedule('59 23 * * *', runEndOfDayCheck);

async function runEndOfDayCheck() {
  console.log('🕛 Running end of day debt check...');
  
  try {
    const blockedDrivers = await debtCheckService.checkEndOfDayDebts();
    
    console.log(`✅ End of day check completed:`);
    console.log(`   - Drivers blocked: ${blockedDrivers.length}`);
    
    if (blockedDrivers.length > 0) {
      console.log('   - Blocked drivers:');
      blockedDrivers.forEach(d => {
        console.log(`     • ${d.name} (${d.phone}): ${d.debt} دينار`);
      });
    }

    return { success: true, blockedCount: blockedDrivers.length, blockedDrivers };
  } catch (error) {
    console.error('❌ End of day check failed:', error);
    return { success: false, error: error.message };
  }
}

module.exports = { runEndOfDayCheck };

