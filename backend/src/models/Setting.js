const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Setting = sequelize.define('Setting', {
    key: {
        type: DataTypes.STRING,
        primaryKey: true,
        allowNull: false,
        unique: true,
    },
    value: {
        type: DataTypes.TEXT, // Using TEXT to store JSON or strings
        allowNull: false,
    },
    description: {
        type: DataTypes.STRING,
        allowNull: true,
    },
}, {
    timestamps: true,
});

module.exports = Setting;
