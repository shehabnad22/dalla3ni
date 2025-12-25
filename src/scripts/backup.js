require('dotenv').config();
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

const DB_NAME = process.env.DB_NAME || 'dalla3ni';
const DB_USER = process.env.DB_USER || 'postgres';
const DB_HOST = process.env.DB_HOST || 'localhost';
const DB_PORT = process.env.DB_PORT || 5432;
const BACKUP_DIR = path.join(__dirname, '../../backups');

// Create backup directory if it doesn't exist
if (!fs.existsSync(BACKUP_DIR)) {
  fs.mkdirSync(BACKUP_DIR, { recursive: true });
}

const timestamp = new Date().toISOString().replace(/[:.]/g, '-').split('T')[0];
const backupFile = path.join(BACKUP_DIR, `dalla3ni_backup_${timestamp}.sql`);

// PostgreSQL backup command
const backupCommand = `pg_dump -h ${DB_HOST} -p ${DB_PORT} -U ${DB_USER} -d ${DB_NAME} -F c -f "${backupFile}"`;

console.log('🔄 Starting database backup...');
console.log(`   Database: ${DB_NAME}`);
console.log(`   Backup file: ${backupFile}`);

exec(backupCommand, (error, stdout, stderr) => {
  if (error) {
    console.error('❌ Backup failed:', error.message);
    process.exit(1);
  }
  
  if (stderr) {
    console.warn('⚠️ Warning:', stderr);
  }
  
  console.log('✅ Backup completed successfully!');
  console.log(`   File: ${backupFile}`);
  
  // Clean old backups (keep last 7 days)
  const files = fs.readdirSync(BACKUP_DIR);
  const sevenDaysAgo = Date.now() - 7 * 24 * 60 * 60 * 1000;
  
  files.forEach(file => {
    const filePath = path.join(BACKUP_DIR, file);
    const stats = fs.statSync(filePath);
    if (stats.mtimeMs < sevenDaysAgo) {
      fs.unlinkSync(filePath);
      console.log(`   Deleted old backup: ${file}`);
    }
  });
  
  process.exit(0);
});

