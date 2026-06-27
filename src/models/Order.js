const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Order = sequelize.define('Order', {
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
  }
});

module.exports = Order;
