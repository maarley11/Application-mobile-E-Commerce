const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Order = sequelize.define('Order', {
  orderNumber: {
    type: DataTypes.STRING,
    allowNull: true,
    unique: true,
  },
  totalAmount: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  paymentMethod: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  status: {
    type: DataTypes.ENUM('PENDING', 'PREPARING', 'SHIPPING', 'DELIVERED', 'PAID', 'FAILED'),
    defaultValue: 'PENDING',
  },
  timeline: {
    type: DataTypes.JSON,
    allowNull: true,
  },
  deliveryPersonName: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  deliveryPersonPhone: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  estimatedDeliveryAt: {
    type: DataTypes.DATE,
    allowNull: true,
  },
  deliveryLatitude: {
    type: DataTypes.DECIMAL,
    allowNull: true,
  },
  deliveryLongitude: {
    type: DataTypes.DECIMAL,
    allowNull: true,
  }
});

module.exports = Order;
