const { Sequelize } = require('sequelize');

// Use DATABASE_URL in production (Render), fallback to DATABASE_URL_LOCAL for local development
const databaseUrl = process.env.DATABASE_URL || process.env.DATABASE_URL_LOCAL;

if (!databaseUrl) {
  throw new Error('DATABASE_URL or DATABASE_URL_LOCAL must be set');
}

const sequelize = new Sequelize(databaseUrl, {
  dialect: 'postgres',
  logging: process.env.NODE_ENV === 'development' ? console.log : false,
  dialectOptions: {
    ssl: process.env.DATABASE_URL ? {
      require: true,
      rejectUnauthorized: false
    } : false
  }
});

module.exports = sequelize;
