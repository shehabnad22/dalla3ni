const { Sequelize } = require('sequelize');

// Use external URL from user request
const dbUrl = 'postgresql://dalla3ni_db_hp79_user@dpg-d53dej8gjchc73f4rl4g-a.oregon-postgres.render.com/dalla3ni_db_hp79';

const sequelize = new Sequelize(dbUrl, {
    dialect: 'postgres',
    dialectOptions: {
        ssl: {
            require: true,
            rejectUnauthorized: false
        }
    },
    logging: false
});

async function checkUsers() {
    try {
        await sequelize.authenticate();
        console.log('✅ Connected to External DB');

        // Raw query to list users
        const [results] = await sequelize.query("SELECT id, name, phone, role, \"isBlocked\", \"createdAt\" FROM \"Users\" WHERE role IN ('cust omer', 'driver') ORDER BY \"createdAt\" DESC;");

        console.log('\n📊 Users Found:');
        if (results.length === 0) {
            console.log('   No users found.');
        } else {
            results.forEach(u => {
                console.log(`   - [${u.role}] ${u.name} | Phone: ${u.phone} | Blocked: ${u.isBlocked} | Created: ${u.createdAt}`);
            });
        }

        /*
        // Optional: Check specific phone if provided as arg
        if (process.argv[2]) {
            const phone = process.argv[2];
            console.log(`\n🔍 Searching for phone containing: ${phone}`);
            const [filtered] = await sequelize.query(`SELECT * FROM "Users" WHERE phone LIKE '%${phone}%'`);
            console.log(filtered);
        }
        */

    } catch (error) {
        console.error('❌ Connection failed:', error.message);
    } finally {
        await sequelize.close();
    }
}

checkUsers();
