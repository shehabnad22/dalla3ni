const debtCheckService = require('../services/debtCheckService');

// Schedule this to run at 23:59 daily using node-cron or similar
// Example with node-cron: cron.schedule('59 23 * * *', runEndOfDayCheck);

async function runEndOfDayCheck() {
  console.log('🕛 Running end of day debt check...');
  
  try {
    const result = await debtCheckService.checkEndOfDayDebts();
    
    console.log(`✅ End of day check completed:`);
    console.log(`   - Warnings sent: ${result.warnedDrivers.length}`);
    console.log(`   - Drivers blocked: ${result.blockedDrivers.length}`);
    
    if (result.warnedDrivers.length > 0) {
      console.log('   - Warned drivers:');
      result.warnedDrivers.forEach(d => {
        console.log(`     • ${d.name} (${d.phone}): ${d.debt} دينار (${d.hoursUntilBlock.toFixed(1)}h until block)`);
      });
    }
    
    if (result.blockedDrivers.length > 0) {
      console.log('   - Blocked drivers:');
      result.blockedDrivers.forEach(d => {
        console.log(`     • ${d.name} (${d.phone}): ${d.debt} دينار`);
      });
    }

    return { 
      success: true, 
      warnedCount: result.warnedDrivers.length,
      blockedCount: result.blockedDrivers.length, 
      warnedDrivers: result.warnedDrivers,
      blockedDrivers: result.blockedDrivers 
    };
  } catch (error) {
    console.error('❌ End of day check failed:', error);
    return { success: false, error: error.message };
  }
}

module.exports = { runEndOfDayCheck };

