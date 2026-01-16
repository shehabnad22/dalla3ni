const { Driver } = require('./src/models');
const sequelize = require('./src/config/database');

async function checkIdImages() {
    try {
        await sequelize.authenticate();
        const drivers = await Driver.findAll({ limit: 5 });
        drivers.forEach(d => {
            console.log(`Driver ID: ${d.id}`);
            console.log(`ID Image: ${d.idImage?.substring(0, 100)}...`);
            console.log(`Motor Image: ${d.motorImage?.substring(0, 100)}...`);
            console.log('---');
        });
    } catch (error) {
        console.error(error);
    } finally {
        await sequelize.close();
    }
}

checkIdImages();
