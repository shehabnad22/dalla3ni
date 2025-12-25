/**
 * Database Migration Script
 * Run this to set up the production database
 * 
 * Usage: node src/scripts/migrate.js
 */

require('dotenv').config();
const { sequelize } = require('../models');

async function migrate() {
  try {
    console.log('🔄 Starting database migration...');
    
    // Test connection
    await sequelize.authenticate();
    console.log('✅ Database connection established');
    
    // Sync all models (creates tables if they don't exist)
    // Use { force: true } to drop and recreate (DANGEROUS - only for development)
    // Use { alter: true } to alter existing tables (safer for production)
    await sequelize.sync({ alter: true });
    console.log('✅ Database tables synced');
    
    console.log('✅ Migration completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

migrate();

