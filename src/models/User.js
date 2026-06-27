const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const User = sequelize.define('User', {
  phone: {
    type: DataTypes.STRING,
    unique: true,
    allowNull: false,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  isPro: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  isAdmin: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  otpCode: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  subscriptionExpiresAt: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  freeDeliveriesUsedThisWeek: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  businessName: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  ninea: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  address: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  loyaltyPoints: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  gpsLatitude: {
    type: DataTypes.DECIMAL,
    allowNull: true,
  },
  gpsLongitude: {
    type: DataTypes.DECIMAL,
    allowNull: true,
  },
});

module.exports = User;
